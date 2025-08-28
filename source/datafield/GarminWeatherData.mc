using Toybox.System;
using Toybox.Weather;

import Toybox.Application;
import Toybox.Lang;

//! TEMPERATURE GARMIN
//! @since API Level 3.2.0
class TemparatureGarminField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      if (Toybox has :Weather) {
         var label = "TEMP --";
         var garmin_weather = Weather.getCurrentConditions();
         if (garmin_weather != null) {
            var settings = System.getDeviceSettings();
            var unit = "°C";
            var temp = garmin_weather.temperature;
            if (temp != null) {
               if (settings.temperatureUnits == System.UNIT_STATUTE) {
                  temp = temp * (9.0 / 5) + 32; // Convert to Farenheit: ensure floating point division.
                  unit = "°F";
               }
               label = "TEMP " + temp.format("%d") + unit;
            }
         }
         return label;
      } else {
         return "API 3.2.0";
      }
   }
}

/* TEMPERATURE HIGH/LOW GARMIN */
//! @since API Level 3.2.0
class TemperatureHLGarminField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      if (Toybox has :Weather) {
         var need_minimal = Properties.getValue("minimal_data");
         var garmin_weather = Weather.getCurrentConditions();
         if (garmin_weather != null) {
            var settings = System.getDeviceSettings();
            var temp_min = garmin_weather.lowTemperature;
            var temp_max = garmin_weather.highTemperature;
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
      } else {
         return "API 3.2.0";
      }
   }
}

/* WEATHER GARMIN */
//! @since API Level 3.2.0
class WeatherGarminField extends BaseDataField {
   private const weather_condition_mapper =
      [
         "CLR", // 0
         "CLDY",
         "CLDY",
         "RAIN",
         "SNOW",
         "WNDY", // 5
         "TNDR",
         "SNOW",
         "FOG",
         "HAZY",
         "HAIL", // 10
         "SHWR",
         "TNDR",
         "RAIN",
         "RAIN",
         "RAIN", // 15
         "SNOW",
         "SNOW",
         "SNOW",
         "SNOW",
         "CLDY", // 20
         "SNOW",
         "CLDY",
         "CLR",
         "SHWR",
         "SHWR", // 25
         "SHWR",
         "SHWR",
         "TNDR",
         "MIST",
         "DUST", // 30
         "DRZZ",
         "TNDO",
         "SMOK",
         "ICE",
         "SAND", // 35
         "SQLL",
         "SAND",
         "ASH",
         "HAZE",
         "FAIR", // 40
         "HURR",
         "TROP",
         "SNOW",
         "SNOW",
         "RAIN", // 45
         "SNOW",
         "SNOW",
         "FLRR",
         "SLEET",
         "SLEET", // 50
         "SNOW",
         "CLDY",
         "WTHR",
      ] as Array<String>;

   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      if (Toybox has :Weather) {
         var garmin_weather = Weather.getCurrentConditions();
         var label = "WTHR --";
         if (garmin_weather != null) {
            var settings = System.getDeviceSettings();
            var unit = "°";
            var temp = garmin_weather.temperature;
            var cond = garmin_weather.condition;
            if (temp != null) {
               if (settings.temperatureUnits == System.UNIT_STATUTE) {
                  temp = temp * (9.0 / 5) + 32; // Convert to Farenheit: ensure floating point division.
                  unit = "°";
               }
               label = weather_condition_mapper[cond] + " " + temp.format("%d") + unit;
            }
         }
         return label;
      } else {
         return "API 3.2.0";
      }
   }
}

/* PRECIPITATION GARMIN */
//! @since API Level 3.2.0
class PrecipitationGarminField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      if (Toybox has :Weather) {
         var garmin_weather = Weather.getCurrentConditions();
         var label = "RAIN --";
         if (garmin_weather != null) {
            var rain = garmin_weather.precipitationChance;
            if (rain != null) {
               label = "RAIN " + rain.format("%d") + "%";
            }
         }
         return label;
      } else {
         return "API 3.2.0";
      }
   }
}
