import Toybox.ActivityMonitor;
import Toybox.Lang;

/* ACTIVE MODERATE MINUTES (WEEK) */
class ActiveModerateField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function max_val() {
      var activityInfo = ActivityMonitor.getInfo();
      return activityInfo.activeMinutesWeekGoal.toFloat();
   }

   function cur_val() {
      var activityInfo = ActivityMonitor.getInfo();
      return activityInfo.activeMinutesWeek.moderate.toFloat();
   }

   function max_label(value) {
      return value.format("%d");
   }

   function cur_label(value) {
      return Lang.format("MACT $1$", [value.format("%d")]);
   }

   function bar_data() {
      return true;
   }
}
