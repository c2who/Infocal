import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

/* BATTERY */
class BatteryField extends BaseDataField {

   private var _hasBatteryInDays as Boolean = (System.Stats has :batteryInDays); // API 3.3.0

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
   private function format_days_hours(batInDays as Float) as String {
      if (batInDays < 1.0) {
         return Lang.format("$1$H", [Math.round(batInDays * 24).format("%d")]);
      } else if (batInDays >= 99.0) {
         return "99+D";
      } else {
         var total_hours = (batInDays * 24).toNumber();
         var days = total_hours / 24;
         var hrs =  total_hours % 24;
         if (hrs == 0) {
            return Lang.format("$1$D", [days]);
         } else {
            return Lang.format("$1$D $2$H", [days, hrs]);
         }
      }
   }

   function cur_label(value) {
      var battery_format = Properties.getValue("battery_format") as Number;
      var need_minimal = Properties.getValue("minimal_data");
      var title = (need_minimal) ? "" : "BAT ";

      if (battery_format == 0) {
         // Battery Percent
         return Lang.format("$1$$2$%", [ title, Math.round(value).toNumber() ]);
      } else {
         // Battery in Days formats
         var batInDays = getBatteryInDays(value);

         if (batInDays < 0.0) {
            // No computed data
            if (_hasBatteryInDays) {
               // API Level 3.3.0 battery in days not available
               return Lang.format("$1$--", [title]);
            } else {
               // Internal battery in days not yet available, waiting for data
               return Lang.format("$1$WAIT", [title]);
            }

         } else if (battery_format == 1) {
            // battery in days
            return Lang.format("$1$$2$D", [ title, Math.round(batInDays).toNumber() ]);

         } else {
            // Battery in days, hours
            return Lang.format("$1$$2$", [ title, format_days_hours(batInDays) ]);
         }
      }
   }

   //! @param value  battery in percent
   function getBatteryInDays(value as Float) as Float {
      if (_hasBatteryInDays) {
         // API Level 3.3.0 battery in days
         return System.getSystemStats().batteryInDays;
      } else {
         // Internal value for battery in days
         var bat_dchg1_time = Storage.getValue("bat_dchg1_time") as Number?;
         if (bat_dchg1_time == null) {
            return -1.0; // No computed data
         } else {
            // Calculate time left (in seconds), deducting time elapsed since last known battery% change
            // (this ensures display value decreases over the hour/day, even if battery% does not move)
            var time_since = 0;
            var bat_last_pcnt = Storage.getValue("bat_last_pcnt") as Float?;
            var bat_last_time = Storage.getValue("bat_last_time") as Number?;
            if ((bat_last_pcnt != null) && (bat_last_time != null) && (bat_last_pcnt >= value)) {
               // If battery % has reduced, calculate time in days, using this know state of charge point
               value = bat_last_pcnt;
               time_since = Time.now().value() - bat_last_time;
            }
            return ((value * bat_dchg1_time) - time_since) / Gregorian.SECONDS_PER_DAY;
         }
      }
   }

   function bar_data() {
      return true;
   }
}
