import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

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
