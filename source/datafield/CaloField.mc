import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;

/* CALORIES */
class CaloField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function max_val() {
      return 3000.0;
   }

   function cur_val() {
      var activityInfo = ActivityMonitor.getInfo();
      return activityInfo.calories.toFloat();
   }

   function max_label(value) {
      var valKp = Globals.toKValue(value);
      return Lang.format("$1$K", [valKp]);
   }

   function cur_label(value as Float) as String {
      var activeCalories = active_calories(value);
      var need_minimal = Properties.getValue("minimal_data");

      if (field_id() == FIELD_TYPE_CALORIES) {
         if (need_minimal) {
            return Lang.format("$1$-$2$", [
               value.format("%d"),
               activeCalories.format("%d"),
            ]);
         } else {
            var valKp = Globals.toKValue(value);
            return Lang.format("$1$K-$2$", [valKp, activeCalories.format("%d")]);
         }
      } else {
         // FIELD_TYPE_CALORIES_ACTIVE
         return Lang.format("CAL+ $1$", [ activeCalories.format("%d") ]);
      }
   }

   function active_calories(value as Float) as Number {
      var now = Time.now();
      var date = Gregorian.info(now, Time.FORMAT_SHORT);

      var profile = UserProfile.getProfile();
      var age = (date.year - profile.birthYear).toFloat();
      var weight = profile.weight.toFloat() / 1000.0;
      var height = profile.height.toFloat();
      //		var bmr = 0.01*weight + 6.25*height + 5.0*age + bonus; // method 1
      var bmr = -6.1 * age + 7.6 * height + 12.1 * weight + 9.0; // method 2
      var current_segment = (date.hour * 60.0 + date.min).toFloat() / 1440.0;
      //		var nonActiveCalories = 1.604*bmr*current_segment; // method 1
      var nonActiveCalories = 1.003 * bmr * current_segment; // method 2
      var activeCalories = value - nonActiveCalories;
      activeCalories = (activeCalories > 0 ? activeCalories : 0).toNumber();
      return activeCalories;
   }

   function bar_data() as Boolean {
      return true;
   }
}
