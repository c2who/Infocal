import Toybox.Application;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;

/* ON DEVICE TEMPERATURE */
class TemparatureField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var need_minimal = Properties.getValue("minimal_data");
      value = 0;
      var settings = System.getDeviceSettings();
      if (
         Toybox has :SensorHistory &&
         Toybox.SensorHistory has :getTemperatureHistory
      ) {
         var sample = SensorHistory.getTemperatureHistory(null).next();
         if (sample != null && sample.data != null) {
            var temperature = sample.data;
            if (settings.temperatureUnits == System.UNIT_STATUTE) {
               temperature = temperature * (9.0 / 5) + 32; // Convert to Farenheit: ensure floating point division.
            }
            value = temperature.format("%d") + "°";
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
      } else {
         if (need_minimal) {
            return "--";
         } else {
            return "TEMP --";
         }
      }
   }
}
