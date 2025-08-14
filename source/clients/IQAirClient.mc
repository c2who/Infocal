using Toybox.Application;
using Toybox.Background;
using Toybox.System;
using Toybox.Communications;

import Toybox.Lang;

//! IQAir (Background) Client for Air Quality Index (AQI) Service
//!
//! @note Uses "Get nearest city data" to read AQI data
//!
//! @see https://www.iqair.com/ca/air-pollution-data-api
//! @see https://api-docs.iqair.com/?version=latest#5ea0dcc1-78c3-4939-aa80-6d4929646b82
(:background)
class IQAirClient {

   const CLIENT_NAME = "IQAir";
   static const DATA_TYPE = "AirQuality";

   //! Uses "Get nearest city data" API to read AQI data
   //! (IP geolocation) http://api.airvisual.com/v2/nearest_city?key={{YOUR_API_KEY}}
   //! (GPS coordinates) http://api.airvisual.com/v2/nearest_city?lat={{LATITUDE}}&lon={{LONGITUDE}}&key={{YOUR_API_KEY}}
   const API_NEAREST_CITY_URL = "https://api.airvisual.com/v2/nearest_city";

   //! Consumer callback for returning formatted data
   private var _callback as Method(type as String, responseCode as Number, data as Dictionary<String, Lang.Any>) as Void;

   //! Public entry method to make background request to get data from remote service
   function requestData(callback as Method(type as String, responseCode as Number, data as Dictionary<String, Lang.Any>) as Void) as Void {
      var app = Application.getApp();
      var api_key = app.getProperty("iqair_api");
      var lat = app.getProperty("LastLocationLat");
      var lon = app.getProperty("LastLocationLon");

      // Save callback method
      self._callback = callback;

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
   //! @param  responseCdoe   responseCode: The server response code or a BLE_* error type
   //! @param  data           the content if the request was successful, or null
   function onReceiveAirQualityData(responseCode as Number, data as Dictionary?) {
      var result;

      // Useful data only available if result was successful.
      // Filter and flatten data response for data that we actually need.
      // Reduces runtime memory spike in main app.
      if (responseCode != 200) {
         // Error
         var hasData = ((data!=null) && (data.hasKey("status")) && data.hasKey("data") && data["data"].hasKey("message"));
         result = {
            "code" =>    responseCode,
            "status" =>  hasData ? data["status"] : responseCode.toString(),
            "message" => hasData ? data["data"]["message"] : "HTTP Error " + responseCode.toString(),
            "client" =>  CLIENT_NAME,
            "clientTs" => Time.now().value()
         };
      } else {
         // Success
         result = {
            "code" => responseCode,
            "status" => data["status"],
            "city" =>   data["data"]["city"],
            "country" =>data["data"]["country"],
            "lat" =>    data["data"]["location"]["coordinates"][1],
            "lon" =>    data["data"]["location"]["coordinates"][0],
            "ts" =>     data["data"]["current"]["pollution"]["ts"],
            "aqius" =>  data["data"]["current"]["pollution"]["aqius"],
            "mainus" => data["data"]["current"]["pollution"]["mainus"],
            "aqicn" =>  data["data"]["current"]["pollution"]["aqicn"],
            "maincn" => data["data"]["current"]["pollution"]["maincn"],
            "client" => CLIENT_NAME,
            "clientTs" => Time.now().value()
         };
      }

      // Send formatted result to registered callback
      _callback.invoke(DATA_TYPE, responseCode, result);
   }

}

//! IQAir (Foreground) client support 
//!
//! @note Where possible, code is placed in the foreground client, to avoid
//! bloating the background service memory usage.
public class IQAirClientHelper extends BaseClientHelper {

   function initialize() {
        BaseClientHelper.initialize(IQAirClient.DATA_TYPE);
   }

   function needsDataUpdate() as Boolean {
      // Get the default api key for new users
      var default_key = Keys.getIQAirDefaultKey();
      Application.AppBase.setProperty("iqair_api_2", default_key);

      // Update rate: default = 6 hours (360 minutes); user api key = 30 minutes
      var user_key = Application.AppBase.getProperty(("iqair_api"));
      if ((user_key == null) || (user_key.length() == 0)) {
          _update_interval_secs = 360 * SECONDS_PER_MINUTE;
      } else {
          _update_interval_secs = 30 * SECONDS_PER_MINUTE;
      }
      

      return BaseClientHelper.needsDataUpdate();
   }
}
