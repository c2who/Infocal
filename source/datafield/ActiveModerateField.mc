import Toybox.ActivityMonitor;
import Toybox.Lang;

/* ACTIVE MODERATE MINUTES (WEEK) */
class ActiveModerateField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function max_val() {
      var activityInfo = ActivityMonitor.getInfo();
      return (activityInfo.activeMinutesWeekGoal != null) ? activityInfo.activeMinutesWeekGoal.toFloat() : 150.0;
   }

   function cur_val() {
      var activityInfo = ActivityMonitor.getInfo();
      return (activityInfo.activeMinutesWeek.moderate != null) ? activityInfo.activeMinutesWeek.moderate.toFloat() : 0.0;
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
