import Toybox.ActivityMonitor;
import Toybox.Lang;

/* ACTIVE VIGOROUS MINUTES (WEEK) */
class ActiveVigorousField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function max_val() {
      var activityInfo = ActivityMonitor.getInfo();
      return activityInfo.activeMinutesWeekGoal.toFloat();
  }

   function cur_val() {
      var activityInfo = ActivityMonitor.getInfo();
      return activityInfo.activeMinutesWeek.vigorous.toFloat();
   }

   function max_label(value) {
      return value.format("%d");
   }

   function cur_label(value) {
      return Lang.format("VACT $1$", [value.format("%d")]);
   }

   function bar_data() {
      return true;
   }
}
