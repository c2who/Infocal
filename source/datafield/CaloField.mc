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
      return (activityInfo.calories != null) ? activityInfo.calories.toFloat() : 0.0;
   }

   function max_label(value) {
      return Globals.toKValue(value);
   }

   function cur_label(value as Float) as String {
      var activeCalories = active_calories(value).toFloat();
      var need_minimal = Properties.getValue("minimal_data");
      var dispTotal = (value < 1000) ? value.format("%d") : Globals.toKValue(value);
      var dispActive = (activeCalories < 1000) ? activeCalories.format("%d") : Globals.toKValue(activeCalories);

      if (value <= 0) {
         return need_minimal ? "C --" : "--";
      } else  if (field_id() == FIELD_TYPE_CALORIES) {
         if (need_minimal) {
            return Lang.format("C $1$-$2$", [ dispTotal, dispActive ]);
         } else {
            return Lang.format("$1$-$2$", [ dispTotal, dispActive ]);
         }
      } else {
         // FIELD_TYPE_CALORIES_ACTIVE
         if (need_minimal) {
            return Lang.format("CAL +$1$", [ dispActive ]);
         } else {
            return Lang.format("+$1$", [ dispActive ]);
         }
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
