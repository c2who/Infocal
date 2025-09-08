import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

/* BATTERY */
class BatteryField extends BaseDataField {

   private var _hasBatteryInDays = (System.Stats has :batteryInDays) as Boolean; // API 3.3.0

   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function min_val() {
      return 0.0;
   }

   function max_val() {
      return 100.0;
   }

   function cur_val() {
      return System.getSystemStats().battery;
   }

   function min_label(value) {
      return "b";
   }

   function max_label(value) {
      return "P";
   }

   //! Format hours as days/hours string
   private function format_hours(total_hours as Float) {
      if (total_hours < 24) {
         return Lang.format("$1$ HRS", [Math.round(total_hours).format("%d")]);
      } else if (total_hours >= 99 * 24) {
         return "99+ DAYS";
      } else {
         total_hours = total_hours.toNumber();
         var days = total_hours / 24;
         var hrs =  total_hours % 24;
         var days_str = (days > 1) ? "DAYS" : "DAY";
         if (hrs == 0) {
            return Lang.format("$1$ $2$", [days, days_str]);
         } else {
            return Lang.format("$1$ $2$ $3$H", [days, days_str, hrs]);
         }
      }
   }

   function cur_label(value) {
      var battery_format = Properties.getValue("battery_format");

      if (battery_format == 0) {
         // Battery Percent
         return Lang.format("BAT $1$%", [Math.round(value).toNumber()]);
      } else if (_hasBatteryInDays) {
         // API Level 3.3.0 battery in days
         return format_hours(System.getSystemStats().batteryInDays * 24);
      } else {
         // Internal value for battery in days
         var bat_dchg1_time = Storage.getValue("bat_dchg1_time") as Number?;
         if (bat_dchg1_time == null) {
            return "WAIT";
         } else {
            // Calculate time left (in seconds), deducting time elapsed since last known battery% change
            // (this ensures display value decreases over the hour/day, even if battery% does not move)
            var time_since = 0;
            var bat_last_pcnt = Storage.getValue("bat_last_pcnt") as Float?;
            var bat_last_time = Storage.getValue("bat_last_time") as Number?;
            if ((bat_last_pcnt != null) && (bat_last_time != null) && (bat_last_pcnt >= value)) {
               value = bat_last_pcnt;
               time_since = Time.now().value() - bat_last_time;
            }
            return format_hours( ((value * bat_dchg1_time) - time_since) / Gregorian.SECONDS_PER_HOUR );
         }
      }
   }

   function bar_data() {
      return true;
   }
}
