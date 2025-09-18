import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

/* DISTANCE */
class DistanceField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function max_val() {
      return 300000.0;
   }

   function cur_val() {
      var activityInfo = ActivityMonitor.getInfo();
      return (activityInfo.distance != null) ? activityInfo.distance.toFloat() : 0.0;
   }

   function max_label(value) {
      return Globals.toKValue(value / 100); // convert cm to km
   }

   function cur_label(value) {
      var need_minimal = Properties.getValue("minimal_data");
      var settings = System.getDeviceSettings();

      var value2 = value;
      var kilo = value2 / 100000;

      var unit = "Km";
      if (settings.distanceUnits == System.UNIT_METRIC) {
      } else {
         kilo *= 0.621371;
         unit = "Mi";
      }

      var dispDist = kilo.format("%0.1f");
      if (need_minimal) {
         return Lang.format("$1$$2$", [dispDist, unit]);
      } else {
         return Lang.format("DIS $1$$2$", [dispDist, unit]);
      }
   }

   function bar_data() {
      return true;
   }
}
