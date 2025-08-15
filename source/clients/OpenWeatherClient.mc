using Toybox.Application;
using Toybox.Background;
using Toybox.System;
using Toybox.Communications;

import Toybox.Lang;

//! OpenWeather (Background) Client
//!
//! Uses OpenWeather Current Weather API
//! @see https://openweathermap.org/current
//!
//! @note Where possible, code is placed in the foreground client, to avoid
//! bloating the background service memory usage.
(:background)
class OpenWeatherClient {
    static const DATA_TYPE = "Weather";
    const CLIENT_NAME = "OWM";

    //! Uses OpenWeather Current Weather API
    //! https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}
    const API_CURRENT_WEATHER = "https://api.openweathermap.org/data/2.5/weather";

    //! Consumer callback for returning formatted data
    private var _callback as Method(type as String, responseCode as Number, data as Dictionary<String, Lang.Any>) as Void;

    //! Public entry method to make background request to get data from remote service
    function requestData(callback as Method(type as String, responseCode as Number, data as Dictionary<String, Lang.Any>) as Void) as Void {
        var app = Application.getApp();
        var api_key = app.getProperty("openweather_api");
        var lat = app.getProperty("LastLocationLat");
        var lon = app.getProperty("LastLocationLon");

        // Save callback method
        self._callback = callback;

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


//! OpenWeather (Foreground) client support 
//!
//! @note Where possible, code is placed in the foreground client, to avoid
//! bloating the background service memory usage.
public class OpenWeatherHelper extends BaseClientHelper {

   function initialize() {
        BaseClientHelper.initialize(OpenWeatherClient.DATA_TYPE);

        // Update weather every 15 minutes
        _update_interval_secs = 15 * SECONDS_PER_MINUTE;
   }

   function needsDataUpdate() as Boolean {
        // Location must be available
        var lat = Application.getApp().getProperty("LastLocationLat");
        var lon = Application.getApp().getProperty("LastLocationLon");
        if ((lat == null) || (lon == null)) {
            return false;
        }

        // Get the default api key for new users    
        var default_key = Keys.getOpenWeatherDefaultKey();
        Application.AppBase.setProperty("owm_api_2", default_key);

        // Check based on default behavior with retries
        return BaseClientHelper.needsDataUpdate();
    }
}
