import Toybox.Application;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;

/* ELEVATION */
class ElevationField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var need_minimal = Properties.getValue("minimal_data");
      value = 0;
      // #67 Try to retrieve altitude from current activity, before falling back on elevation history.
      // Note that Activity::Info.altitude is supported by CIQ 1.x, but elevation history only on select CIQ 2.x
      // devices.
      var settings = System.getDeviceSettings();
      var activityInfo = Activity.getActivityInfo();
      var elevation = activityInfo.altitude;
      if (
         elevation == null &&
         Toybox has :SensorHistory &&
         Toybox.SensorHistory has :getElevationHistory
      ) {
         var sample = SensorHistory.getElevationHistory({
            :period => 1,
            :order => SensorHistory.ORDER_NEWEST_FIRST,
         }).next();
         if (sample != null && sample.data != null) {
            elevation = sample.data;
         }
      }
      if (elevation != null) {
         var unit = "";
         // Metres (no conversion necessary).
         if (settings.elevationUnits == System.UNIT_METRIC) {
            unit = "m";
            // Feet.
         } else {
            elevation *= 3.28084; /* FT_PER_M */
            unit = "ft";
         }

         value = elevation.format("%d");
         if (need_minimal) {
            return value;
         } else {
            var temp = Lang.format("ELE $1$$2$", [value, unit]);
            if (temp.length() > 10) {
               return Lang.format("$1$$2$", [value, unit]);
            }
            return temp;
         }
      } else {
         if (need_minimal) {
            return "--";
         } else {
            return "ELE --";
         }
      }
   }
}
