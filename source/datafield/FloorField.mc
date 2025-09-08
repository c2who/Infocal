import Toybox.ActivityMonitor;
import Toybox.Lang;

/* FLOORS CLIMBED */
class FloorField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function max_val() {
      var activityInfo = ActivityMonitor.getInfo();
      if (activityInfo has :floorsClimbedGoal) {
         return activityInfo.floorsClimbedGoal.toFloat();
      } else {
         return 1.0;
      }
   }

   function cur_val() {
      var activityInfo = ActivityMonitor.getInfo();
      if (activityInfo has :floorsClimbed) {
         return activityInfo.floorsClimbed.toFloat();
      } else {
         return 0.0;
      }
   }

   function max_label(value) {
      return value.format("%d");
   }

   function cur_label(value) {
      if (value == null) {
         return "FLOOR --";
      }
      return Lang.format("FLOOR $1$", [value.format("%d")]);
   }

   function bar_data() {
      return true;
   }
}
