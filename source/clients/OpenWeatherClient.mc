using Toybox.Background;
using Toybox.Communications;
using Toybox.System;
using Toybox.Time.Gregorian;

import Toybox.Application;
import Toybox.Lang;

//! OpenWeather (Background) Client
//!
//! Uses OpenWeather Current Weather API
//! @see https://openweathermap.org/current
//!
//! @note Where possible, code is placed in the foreground client, to avoid
//! bloating the background service memory usage.
(:background)
class OpenWeatherClient extends BaseClient {
    public static const DATA_TYPE = "Weather";

    //! Uses OpenWeather Current Weather API
    //! https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}
    const API_CURRENT_WEATHER = "https://api.openweathermap.org/data/2.5/weather";

    function initialize() {
        BaseClient.initialize();
    }

    //! Public entry method to make background request to get data from remote service
    //! @param callback     Consumer callback for returning formatted data
    function requestData(callback as Method(type as String, responseCode as Number, data as Dictionary<String, PropertyValueType>) as Void) as Void {
        BaseClient.requestData(callback);

        var api_key = Storage.getValue("owm_api_key");
        var location = Storage.getValue("LastLocation") as Array<Float>?;

        var params = {
            "lat" => (location != null) ? location[0] : null,
            "lon" => (location != null) ? location[1] : null,
            "appid" => api_key,
            "units" => "metric", // Celsius.
        };

        BaseClient.makeWebRequest(
            API_CURRENT_WEATHER,
            params,
            method(:onReceiveOpenWeatherData)
        );
    }

   //! Callback handler for makeWebRequest. Decodes response and flatten (extract) data we need.
   //!
   //! @param  responseCode   the server response code or a BLE_* error type
   //! @param  data           the content if the request was successful, or null
   //!
   //! @note Large API payload can cause out-of-memory errors when processing network response
   //!       on devices with lower available memory (NETWORK_RESPONSE_OUT_OF_MEMORY = -403).
   //!       It is imperative that the code/data size of background task is kept
   //!       as small as possible!
   //! @see  https://developer.garmin.com/connect-iq/api-docs/Toybox/Communications.html
   function onReceiveOpenWeatherData(responseCode as Number, data as Dictionary?) {
        var result;

        // Useful data only available if result was successful.
        // Filter and flatten data response for data that we actually need.
        // Reduces runtime memory spike in main app.
        if ((responseCode == 200) && (data != null)) {
            result = {
                "type" =>     DATA_TYPE,
                "code" =>     responseCode,
                //"lat" => data["coord"]["lat"],
                //"lon" => data["coord"]["lon"],
                //"dt" => data["dt"],
                "temp" => data["main"]["temp"],
                "temp_min" => data["main"]["temp_min"],
                "temp_max" => data["main"]["temp_max"],
                "humidity" => data["main"]["humidity"],
                "wind_speed" => data["wind"]["speed"],
                "wind_direct" => data["wind"]["deg"],
                "icon" => data["weather"][0]["icon"],
                "des" => data["weather"][0]["main"]
            };
        } else {
            // Error
            result = {
                "type" =>     DATA_TYPE,
                "code" =>     responseCode.toNumber(),
            };
        }

        // Send formatted result to registered callback
        _callback.invoke(DATA_TYPE, responseCode, result);
    }
}


//! OpenWeather (Foreground) client helper
//!
//! @note Where possible, code is placed in the foreground client, to avoid
//! bloating the background service memory usage.
public class OpenWeatherClientHelper {

    public static function needsDataUpdate() as Boolean {
        // Location must be available
        var location = Storage.getValue("LastLocation") as Array<Float>?;
        if (location == null) {
            return false;
        }

        var update_interval_secs = 30 * Gregorian.SECONDS_PER_MINUTE;   // 30 minutes
        var user_key = Properties.getValue("openweather_api");

        // Set the api key used by the service client (user key, or default key for new users)
        if ((user_key != null) && (user_key.length() > 0)) {
            Storage.setValue("owm_api_key", user_key);
        } else {
            // Set the default api key for new users
            var default_key = Keys.getOpenWeatherDefaultKey();
            Storage.setValue("owm_api_key", default_key);
        }

        // Check based on default behavior with retries
        return BaseClientHelper.calcNeedsDataUpdate(OpenWeatherClient.DATA_TYPE, update_interval_secs);
    }
}
