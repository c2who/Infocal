import Toybox.ActivityMonitor;
import Toybox.Lang;

//! TimeToRecovery (API Level 3.3.0)
//! Time to recovery from the last activity, in hours. Value may be null.
class TimeToRecoveryField extends BaseDataField {
   private const _hasTimeToRecovery = (ActivityMonitor.Info has :timeToRecovery) as Boolean;

   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function max_val() as Float {
      return 96.0; // hours
   }

   function cur_val() as Float {
      // timeToRecovery can return null
      var time = (_hasTimeToRecovery) ? ActivityMonitor.getInfo().timeToRecovery : null;
      return (time != null) ? time.toFloat() : -1.0;
   }

   function max_label(value as Float) as String {
      return value.format("%d");
   }

   function cur_label(value as Float) as String {
      if (value < 0.0) {
         return "--";
      } else {
         return Lang.format("RT $1$H", [value.format("%d")]);
      }
   }

   function bar_data() as Boolean {
      return true;
   }
}