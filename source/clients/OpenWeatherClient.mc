using Toybox.Application;
using Toybox.Background;
using Toybox.Communications;
using Toybox.System;
using Toybox.Time.Gregorian as Time;

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
    static const DATA_TYPE = "Weather";
    const CLIENT_NAME = "OWM";

    //! Uses OpenWeather Current Weather API
    //! https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}
    const API_CURRENT_WEATHER = "https://api.openweathermap.org/data/2.5/weather";

    //! Public entry method to make background request to get data from remote service
    //! @param callback     Consumer callback for returning formatted data
    function requestData(callback as Method(type as String, responseCode as Number, data as Dictionary<String, Lang.Any>) as Void) as Void {
        BaseClient.requestData(callback);

        var app = Application.getApp();
        var api_key = app.getProperty("openweather_api");
        var lat = app.getProperty("LastLocationLat");
        var lon = app.getProperty("LastLocationLon");

        if ((api_key == null) || (api_key.length() == 0)) {
            api_key = app.getProperty("owm_api_2");;
        }

        var params = {
            "lat" => lat,
            "lon" => lon,
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
   //! @param  responseCdoe   responseCode: The server response code or a BLE_* error type
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
        if (responseCode == 200) {
            result = {
                "code" => responseCode,
                "lat" => data["coord"]["lat"],
                "lon" => data["coord"]["lon"],
                "dt" => data["dt"],
                "temp" => data["main"]["temp"],
                "temp_min" => data["main"]["temp_min"],
                "temp_max" => data["main"]["temp_max"],
                "humidity" => data["main"]["humidity"],
                "wind_speed" => data["wind"]["speed"],
                "wind_direct" => data["wind"]["deg"],
                "icon" => data["weather"][0]["icon"],
                "des" => data["weather"][0]["main"],
                "client" =>  CLIENT_NAME,
                "clientTs" => Time.now().value()
            };
        } else {
            // Error
            result = {
                "code" => responseCode.toNumber(),
                "client" =>  CLIENT_NAME,
                "clientTs" => Time.now().value()
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
        var lat = Application.getApp().getProperty("LastLocationLat");
        var lon = Application.getApp().getProperty("LastLocationLon");
        if ((lat == null) || (lon == null)) {
            return false;
        }

        // Set the default api key for new users
        var default_key = Keys.getOpenWeatherDefaultKey();
        Application.AppBase.setProperty("owm_api_2", default_key);

        // Update rate
        var update_interval_secs = 30 * Time.SECONDS_PER_MINUTE;   // 30 minutes

        // Check based on default behavior with retries
        return BaseClientHelper.calcNeedsDataUpdate(OpenWeatherClient.DATA_TYPE, update_interval_secs);
    }
}
