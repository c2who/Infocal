import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

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
            return Lang.format("$1$ $2$", [
               temp_max.format("%d"),
               temp_min.format("%d"),
            ]);
         } else {
            return Lang.format("H $1$ L $2$", [
               temp_max.format("%d"),
               temp_min.format("%d"),
            ]);
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
