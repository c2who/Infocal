import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Lang;

/* HEART RATE */
class HRField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function min_val() {
      return 50.0;
   }

   function max_val() {
      return 120.0;
   }

   function cur_val() {
      var heartRate = _retrieveHeartrate();
      return heartRate.toFloat();
   }

   function min_label(value) {
      return value.format("%d");
   }

   function max_label(value) {
      return value.format("%d");
   }

   function cur_label(value) {
      var heartRate = value;
      if (heartRate <= 1) {
         return "HR --";
      }
      return Lang.format("HR $1$", [heartRate.format("%d")]);
   }

   function bar_data() {
      return true;
   }
}

const HAS_HEART_RATE_HISTORY = (ActivityMonitor has :getHeartRateHistory) as Boolean;

function _retrieveHeartrate() as Number {
   var activity = Activity.getActivityInfo();
   if ((activity != null) && (activity.currentHeartRate != null)) {
      return activity.currentHeartRate;

   } else if (HAS_HEART_RATE_HISTORY) {
      var sample = ActivityMonitor.getHeartRateHistory(1, true).next();
      if ((sample != null) && (sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE)) {
         return sample.heartRate;
      } else {
         return 0; // sample invalid
      }

   } else {
      return 0; // no data
   }
}
