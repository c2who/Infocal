using Toybox.Math;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;

import Toybox.Application;
import Toybox.Lang;

//! Encapsulate (foreground) globals
//! @note minimize the number of classes, as each class _definition_ adds 120 bytes!
public class Globals {
    static const DATA_TYPE_ERROR_SUFFIX = ".Error";
    static const DATA_TYPE_RETRIES_SUFFIX = ".Retries";

    static function getFormattedDate() as String {
      var now = Time.now();
      var date = Gregorian.info(now, Time.FORMAT_SHORT);
      var day = date.day as Number;
      var month = date.month as Number;
      var day_of_week = date.day_of_week as Number;
      var date_formatter = Properties.getValue("date_format") as Number;

      var DAYS_OF_THE_WEEK = [
         "SUN",
         "MON",
         "TUE",
         "WED",
         "THU",
         "FRI",
         "SAT",
      ];

      var MONTHS_OF_THE_YEAR = [
         "JAN",
         "FEB",
         "MAR",
         "APR",
         "MAY",
         "JUN",
         "JUL",
         "AUG",
         "SEP",
         "OCT",
         "NOV",
         "DEC",
      ];

      if (date_formatter == 0) {
         // ddd d
         if (Properties.getValue("force_date_english")) {
            return Lang.format("$1$ $2$", [
               DAYS_OF_THE_WEEK[day_of_week-1],
               day,
            ]);
         } else {
            var long_date = Gregorian.info(now, Time.FORMAT_MEDIUM);
            var day_str = long_date.day_of_week as String;
            return Lang.format("$1$ $2$", [
               day_str.toUpper(),
               day,
            ]);
         }
      } else if (date_formatter == 1) {
         // dd.mm
         return Lang.format("$1$.$2$", [ day, month ]);
      } else if (date_formatter == 2) {
         // mm.dd
         return Lang.format("$1$.$2$", [ month, day ]);
      } else if (date_formatter == 3) {
         // dd.mm.yy
         var yy = date.year % 100;
         return Lang.format("$1$.$2$.$3$", [ day, month, yy ]);
      } else if (date_formatter == 4) {
         // mm.dd.yy
         var yy = date.year % 100;
         return Lang.format("$1$.$2$.$3$", [ month, day, yy ]);
      } else if (date_formatter == 5 || date_formatter == 6) {
         // dd mmm / mmm dd
         var month_str = "";
         if (Properties.getValue("force_date_english")) {
            month_str = MONTHS_OF_THE_YEAR[month-1];
         } else {
            var medium_date = Gregorian.info(now, Time.FORMAT_MEDIUM);
            month_str = medium_date.month;
         }
         if (date_formatter == 5) {
            // dd mmm
            return Lang.format("$1$ $2$", [day, month_str]);
         } else {
            // mmm dd
            return Lang.format("$1$ $2$", [month_str, day]);
         }
      } else {
         // Invalid use format 0: "ddd d"
         return Lang.format("$1$ $2$", [
            DAYS_OF_THE_WEEK[day_of_week-1],
            day,
         ]);
      }
   }

   static function convertCoorX(radians as Float, radius as Number) as Float {
        return (center_x + radius * Math.cos(radians)) as Float;
    }

    static function convertCoorY(radians as Float, radius as Number) as Float {
        return (center_y + radius * Math.sin(radians)) as Float;
    }

    static function toKValue(value as Float) as String {
        var valK = value / 1000.0;
        return valK.format("%0.1f");
    }
}
