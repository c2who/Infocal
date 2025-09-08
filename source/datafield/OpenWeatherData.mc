using Toybox.System;
using Toybox.Time.Gregorian;

import Toybox.Application;
import Toybox.Lang;

/* TEMPERATURE HIGH/LOW */
class TemparatureHLField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      // WEATHER
      var need_minimal = Properties.getValue("minimal_data");
      var weather_data = Storage.getValue("Weather") as Dictionary<String, PropertyValueType>;
      if (weather_data != null) {
         var settings = System.getDeviceSettings();
         var temp_min = weather_data["temp_min"];
         var temp_max = weather_data["temp_max"];
         //var unit = "°C";
         if (settings.temperatureUnits == System.UNIT_STATUTE) {
            temp_min = temp_min * (9.0 / 5) + 32; // Convert to Farenheit: ensure floating point division.
            temp_max = temp_max * (9.0 / 5) + 32; // Convert to Farenheit: ensure floating point division.
            //unit = "°F";
         }
         if (need_minimal) {
            return Lang.format("$1$ $2$", [temp_max.format("%d"), temp_min.format("%d")]);
         } else {
            return Lang.format("H $1$ L $2$", [temp_max.format("%d"), temp_min.format("%d")]);
         }
      } else {
         if (need_minimal) {
            return "--";
         } else {
            return "H - L -";
         }
      }
   }
}

/* TEMPERATURE OUTSIDE */
class TemparatureOutField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      // WEATHER
      var need_minimal = Properties.getValue("minimal_data");
      var weather_data = Storage.getValue("Weather") as Dictionary<String, PropertyValueType>;
      if (weather_data != null) {
         var settings = System.getDeviceSettings();
         var temp = weather_data["temp"];
         var unit = "°C";
         if (settings.temperatureUnits == System.UNIT_STATUTE) {
            temp = temp * (9.0 / 5) + 32; // Convert to Farenheit: ensure floating point division.
            unit = "°F";
         }
         value = temp.format("%d") + unit;

         if (need_minimal) {
            return value;
         } else {
            return Lang.format("TEMP $1$", [value]);
         }
      } else {
         if (need_minimal) {
            return "--";
         } else {
            return "TEMP --";
         }
      }
   }
}

/* WEATHER */
class WeatherField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function cur_icon() {
      var weather_data = Storage.getValue("Weather") as Dictionary<String, PropertyValueType>?;
      var weather_icon_mapper =
         ({
            "01d" => "",
            "02d" => "",
            "03d" => "",
            "04d" => "",
            "09d" => "",
            "10d" => "",
            "11d" => "",
            "13d" => "",
            "50d" => "",

            "01n" => "",
            "02n" => "",
            "03n" => "",
            "04n" => "",
            "09n" => "",
            "10n" => "",
            "11n" => "",
            "13n" => "",
            "50n" => "",
         }) as Dictionary<String, String>;

      if (weather_data != null) {
         return weather_icon_mapper[weather_data["icon"]];
      } else {
         return null;
      }
   }

   function cur_label(value) as String {
      // WEATHER
      //var need_minimal = Properties.getValue("minimal_data");
      var data = Storage.getValue(OpenWeatherClient.DATA_TYPE) as Dictionary<String, PropertyValueType>?;

      // Check if data is Invalid, or too old (> 6 hours)
      if (data == null || data.get("clientTs") == null || data["clientTs"] < Time.now().value() - 6 * Gregorian.SECONDS_PER_HOUR) {
         // Display error(if any) or no-computed-data
         var error = Storage.getValue(OpenWeatherClient.DATA_TYPE + Globals.DATA_TYPE_ERROR_SUFFIX) as Dictionary<String, PropertyValueType>?;

         if (gLocation == null) {
            return "NO LOCN";
         } else if (error != null) {
            var responseCode = error.get("code") as Number;
            return BaseClientHelper.getCommunicationsErrorCodeText(responseCode);
         } else {
            // No Data
            return "--";
         }
      } else {
         var settings = System.getDeviceSettings();
         var temp = data["temp"];
         var unit = "°C";

         // Convert to Farenheit: ensure floating point division.
         if (settings.temperatureUnits == System.UNIT_STATUTE) {
            temp = temp * (9.0 / 5.0) + 32;
            unit = "°F";
         }
         value = temp.format("%d") + unit;

         var description = data.get("des");
         if (description != null) {
            return description + " " + value;
         } else {
            return value;
         }
      }
   }
}

/* WIND */
class WindField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      //var need_minimal = Properties.getValue("minimal_data");
      var weather_data = Storage.getValue("Weather") as Dictionary<String, PropertyValueType>?;
      var wind_direction_mapper = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"] as Array<String>;

      if (weather_data != null) {
         var settings = System.getDeviceSettings();
         var speed = weather_data["wind_speed"] * 3.6; // kph
         var direct = weather_data["wind_direct"];

         var direct_corrected = direct + 11.25; // move degrees to int spaces (North from 348.75-11.25 to 360(min)-22.5(max))
         direct_corrected = direct_corrected < 360 ? direct_corrected : direct_corrected - 360; // move North from 360-371.25 back to 0-11.25 (final result is North 0(min)-22.5(max))
         var direct_idx = (direct_corrected / 22.5).toNumber(); // now calculate direction array position: int([0-359.99]/22.5) will result in 0-15 (correct array positions)

         var directLabel = wind_direction_mapper[direct_idx % wind_direction_mapper.size()];
         var unit = "k";
         if (settings.distanceUnits == System.UNIT_STATUTE) {
            speed *= 0.621371;
            unit = "m";
         }
         return directLabel + " " + speed.format("%0.1f") + unit;
      } else {
         return "--";
      }
   }
}
