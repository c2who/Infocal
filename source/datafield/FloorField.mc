import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Lang;

/* FLOORS CLIMBED */
class FloorField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function max_val() {
      var activityInfo = ActivityMonitor.getInfo();
      if ((activityInfo has :floorsClimbedGoal) && (activityInfo.floorsClimbedGoal != null)) {
         return activityInfo.floorsClimbedGoal.toFloat();
      } else {
         return 1.0;
      }
   }

   function cur_val() {
      var activityInfo = ActivityMonitor.getInfo();
      if ((activityInfo has :floorsClimbed) && (activityInfo.floorsClimbed != null)) {
         return activityInfo.floorsClimbed.toFloat();
      } else {
         return 0.0;
      }
   }

   function max_label(value) {
      return value.format("%d");
   }

   function cur_label(value) {
      var need_minimal = Properties.getValue("minimal_data");
      var title = (need_minimal) ? "" : "FLR ";

      if ((value == null) || (value < 0)) {
         return Lang.format("$1$--", [title]);
      } else {
         return Lang.format("$1$$2$", [title, value.format("%d")]);
      }
   }

   function bar_data() {
      return true;
   }
}
