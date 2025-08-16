using Toybox.Application;
using Toybox.Background;
using Toybox.Communications;
using Toybox.System;
using Toybox.Time.Gregorian as Time;

import Toybox.Lang;

//! IQAir (Background) Client for Air Quality Index (AQI) Service
//!
//! @note Uses "Get nearest city data" to read AQI data
//!
//! @see https://www.iqair.com/ca/air-pollution-data-api
//! @see https://api-docs.iqair.com/?version=latest#5ea0dcc1-78c3-4939-aa80-6d4929646b82
(:background)
class IQAirClient extends BaseClient {

   private const CLIENT_NAME = "IQAir";
   public static const DATA_TYPE = "AirQuality";

   //! Uses "Get nearest city data" API to read AQI data
   //! (IP geolocation) http://api.airvisual.com/v2/nearest_city?key={{YOUR_API_KEY}}
   //! (GPS coordinates) http://api.airvisual.com/v2/nearest_city?lat={{LATITUDE}}&lon={{LONGITUDE}}&key={{YOUR_API_KEY}}
   const API_NEAREST_CITY_URL = "https://api.airvisual.com/v2/nearest_city";

   //! Public entry method to make background request to get data from remote service
   //! @param callback     Consumer callback for returning formatted data
   function requestData(callback as Method(type as String, responseCode as Number, data as Dictionary<String, Lang.Any>) as Void) as Void {
      BaseClient.requestData(callback);

      var app = Application.getApp();
      var api_key = app.getProperty("iqair_api");
      var lat = app.getProperty("LastLocationLat");
      var lon = app.getProperty("LastLocationLon");

      // Use default api key if first-time user has not added their owm api key yet
      if ((api_key == null) || (api_key.length() == 0)) {
         api_key = app.getProperty("iqair_api_2");
      }

      var params = {
         "key" => api_key
      };

      if ((lat != null) && (lon != null)) {
         // Use location data (else uses IP geolocation)
         params["lat"] = lat;
         params["lon"] = lon;
      }

      BaseClient.makeWebRequest(
         API_NEAREST_CITY_URL,
         params,
         method(:onReceiveAirQualityData)
      );
   }

   //! onReceiveAirQualityData
   //!
   //! @param  responseCode   the server response code or a BLE_* error type
   //! @param  data           the content if the request was successful, or null
   //!
   //! @note Large API payload can cause out-of-memory errors when processing network response
   //!       on devices with lower available memory (NETWORK_RESPONSE_OUT_OF_MEMORY = -403).
   //!       It is imperative that the code/data size of background task is kept
   //!       as small as possible!
   //! @see  https://developer.garmin.com/connect-iq/api-docs/Toybox/Communications.html
   function onReceiveAirQualityData(responseCode as Number, data as Dictionary?) {
      var result;

      // Useful data only available if result was successful.
      // Filter and flatten data response for data that we actually need.
      // Avoid runtime memory issues in background.
      if ((responseCode == 200) && (data != null)) {
         result = {
            "type" =>     DATA_TYPE,
            "code" =>     responseCode,
            //"client" =>   CLIENT_NAME,
            //"clientTs" => Time.now().value(),
            //"status" => data["status"],
            //"city" =>   data["data"]["city"],
            //"country" =>data["data"]["country"],
            //"lat" =>    data["data"]["location"]["coordinates"][1],
            //"lon" =>    data["data"]["location"]["coordinates"][0],
            //"ts2" =>     data["data"]["current"]["pollution"]["ts"],
            "aqius" =>  data["data"]["current"]["pollution"]["aqius"],
            //"mainus" => data["data"]["current"]["pollution"]["mainus"],
            //"aqicn" =>  data["data"]["current"]["pollution"]["aqicn"],
            //"maincn" => data["data"]["current"]["pollution"]["maincn"]
         };
      } else {
         // Error
         //var hasData = ((data!=null) && (data.hasKey("status")) && data.hasKey("data") && data["data"].hasKey("message"));
         result = {
            "type" =>     DATA_TYPE,
            "code" =>     responseCode.toNumber(),
            //"client" =>   CLIENT_NAME,
            //"clientTs" => Time.now().value(),
            //"status" =>  hasData ? data["status"] : responseCode.toString(),
            //"message" => hasData ? data["data"]["message"] : "HTTP Error " + responseCode.toString()
         };
      }

      // Send formatted result to registered callback
      _callback.invoke(DATA_TYPE, responseCode, result);
   }

}

//! IQAir (Foreground) client helper
//!
//! @note Where possible, code is placed in the foreground client, to avoid
//! bloating the background service memory usage.
public class IQAirClientHelper {

   public static function needsDataUpdate() as Boolean {
      // Set the default api key for new users
      var default_key = Keys.getIQAirDefaultKey();
      Application.AppBase.setProperty("iqair_api_2", default_key);

      // Set the update interval based on if user has their own api key (more quota)
      var update_interval_secs;
      var user_key = Application.AppBase.getProperty(("iqair_api"));
      if ((user_key == null) || (user_key.length() == 0)) {
          update_interval_secs = 6 * Time.SECONDS_PER_HOUR;       // 6 hours
      } else {
          update_interval_secs = 30 * Time.SECONDS_PER_MINUTE;    // 30 minutes
      }

      return BaseClientHelper.calcNeedsDataUpdate(IQAirClient.DATA_TYPE, update_interval_secs);
   }
}
