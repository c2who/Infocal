import Toybox.ActivityMonitor;
import Toybox.Lang;

/* MOVE BAR */
class MoveField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function min_val() {
      return 0.0; //ActivityMonitor.MOVE_BAR_LEVEL_MIN.toFloat();
   }

   function max_val() {
      return 5.0; //ActivityMonitor.MOVE_BAR_LEVEL_MAX.toFloat();
   }

   function cur_val() {
      var activityInfo = ActivityMonitor.getInfo();
      var currentBar = (activityInfo.moveBarLevel != null) ? activityInfo.moveBarLevel.toFloat() : 0.0;
      return currentBar.toFloat();
   }

   function min_label(value) {
      return value.format("%d");
   }

   function max_label(value) {
      return Lang.format("$1$", [value.format("%d")]);
   }

   function cur_label(value) {
      return Lang.format("MOVE $1$", [value.format("%d")]);
   }

   function bar_data() {
      return true;
   }
}
