using Toybox.Time.Gregorian;

import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

/* AM/PM INDICATOR */
class AMPMField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var clockTime = System.getClockTime();
      var hour = clockTime.hour;
      if (hour >= 12) {
         return "pm";
      } else {
         return "am";
      }
   }
}

/* TIME */
class TimeField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      return getTimeString();
   }

   function getTimeString() {
      var currentSettings = System.getDeviceSettings();
      var clockTime = System.getClockTime();
      var hour = clockTime.hour;
      var minute = clockTime.min;
      var mark = "";
      if (!currentSettings.is24Hour) {
         if (hour >= 12) {
            mark = "pm";
         } else {
            mark = "am";
         }
         hour = hour % 12;
         hour = hour == 0 ? 12 : hour;
      }
      return Lang.format("$1$:$2$ $3$", [hour, minute.format("%02d"), mark]);
   }
}

/* DATE */
class DateField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      return Globals.getFormattedDate();
   }
}

/* WEEK COUNT */
class WeekCountField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function julian_day(year, month, day) {
      var a = (14 - month) / 12;
      var y = year + 4800 - a;
      var m = month + 12 * a - 3;
      return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045;
   }

   function is_leap_year(year) {
      if (year % 4 != 0) {
         return false;
      } else if (year % 100 != 0) {
         return true;
      } else if (year % 400 == 0) {
         return true;
      }
      return false;
   }

   function iso_week_number(year, month, day) {
      var first_day_of_year = julian_day(year, 1, 1);
      var given_day_of_year = julian_day(year, month, day);

      var day_of_week = (first_day_of_year + 3) % 7; // days past thursday
      var week_of_year = (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;

      // week is at end of this year or the beginning of next year
      if (week_of_year == 53) {
         if (day_of_week == 6) {
            return week_of_year;
         } else if (day_of_week == 5 && is_leap_year(year)) {
            return week_of_year;
         } else {
            return 1;
         }
      } // week is in previous year, try again under that year
      else if (week_of_year == 0) {
         first_day_of_year = julian_day(year - 1, 1, 1);

         day_of_week = (first_day_of_year + 3) % 7;

         return (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;
      } // any old week of the year
      else {
         return week_of_year;
      }
   }

   function cur_label(value) {
      var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
      var week_num = iso_week_number(date.year, date.month, date.day);
      return Lang.format("WEEK $1$", [week_num]);
   }
}

/* COUNTDOWN */
class CountdownField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var countdown_date = Properties.getValue("countdown_date") as Lang.Number?;

      // BUG: Garmin ConnectIQ App Settings reset Date Picker to "" when using Groups and re-enter/save group
      //      Work-around: save a local copy when valid
      if (!(countdown_date instanceof Number)) {
         countdown_date = Storage.getValue("countdown_date") as Lang.Number?;
      } else {
         Storage.setValue("countdown_date", countdown_date);
      }

      if (!(countdown_date instanceof Number)) {
         return "NOT SET";
      } else {
         var timeZoneOffset = System.getClockTime().timeZoneOffset;
         var today_utc = Time.today().value() + timeZoneOffset;
         var diff = (countdown_date - today_utc) / 86400;
         if (diff == 0) {
            return "TODAY";
         } else {
            var days_str = diff.abs() > 1 ? "days" : "day";
            return Lang.format("$1$ $2$", [diff.toString(), days_str]);
         }
      }
   }
}

/* SECONDARY TIME */
class TimeSecondaryField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var currentSettings = System.getDeviceSettings();
      var clockTime = System.getClockTime();
      var to_utc_second = clockTime.timeZoneOffset;

      var target = Properties.getValue("utc_timezone");
      var shift_val = Properties.getValue("utc_shift") ? 0.5 : 0.0;
      var secondary_zone_delta = (target + shift_val) * 3600 - to_utc_second;

      var now = Time.now();
      var now_target_zone_delta = new Time.Duration(secondary_zone_delta.toNumber());
      var now_target_zone = now.add(now_target_zone_delta);
      var target_zone = Gregorian.info(now_target_zone, Time.FORMAT_SHORT);

      var hour = target_zone.hour;
      var minute = target_zone.min;
      var mark = "";
      if (!currentSettings.is24Hour) {
         if (hour >= 12) {
            mark = "pm";
         } else {
            mark = "am";
         }
         hour = hour % 12;
         hour = hour == 0 ? 12 : hour;
      }
      return Lang.format("$1$:$2$ $3$", [hour.format("%02d"), minute.format("%02d"), mark]);
   }
}
