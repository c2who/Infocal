using Toybox.Application;
using Toybox.Math;
using Toybox.Time;
using Toybox.Time.Gregorian as Date;

import Toybox.Lang;

//! Encapsulate (foreground) globas
// TODO: Reduce number of Globals, Globals are bad!!!
//! @note minimize the number of classes, as each class _definition_ adds 120 bytes!
public class Globals {
    static const DATA_TYPE_ERROR_SUFFIX = ".Error";
    static const DATA_TYPE_RETRIES_SUFFIX = ".Retries";

    static function getFormattedDate() as String {
      var now = Time.now();
      var date = Date.info(now, Time.FORMAT_SHORT);
      var date_formatter = Application.getApp().getProperty("date_format");

      var DAYS_OF_THE_WEEK = [
         "MON",
         "TUE",
         "WED",
         "THU",
         "FRI",
         "SAT",
         "SUN",
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
         if (Application.getApp().getProperty("force_date_english")) {
            return Lang.format("$1$ $2$", [
               DAYS_OF_THE_WEEK[date.day_of_week-1],
               date.day.format("%d"),
            ]);
         } else {
            var long_date = Date.info(now, Time.FORMAT_MEDIUM);
            var day_of_week = long_date.day_of_week;
            return Lang.format("$1$ $2$", [
               day_of_week.toUpper(),
               date.day.format("%d"),
            ]);
         }
      } else if (date_formatter == 1) {
         // dd.mm
         return Lang.format("$1$.$2$", [
            date.day.format("%d"),
            date.month.format("%d"),
         ]);
      } else if (date_formatter == 2) {
         // mm.dd
         return Lang.format("$1$.$2$", [
            date.month.format("%d"),
            date.day.format("%d"),
         ]);
      } else if (date_formatter == 3) {
         // dd.mm.yyyy
         var year = date.year;
         var yy = year / 100.0;
         yy = Math.round((yy - yy.toNumber()) * 100.0);
         return Lang.format("$1$.$2$.$3$", [
            date.day.format("%d"),
            date.month.format("%d"),
            yy.format("%d"),
         ]);
      } else if (date_formatter == 4) {
         // mm.dd.yyyy
         var year = date.year;
         var yy = year / 100.0;
         yy = Math.round((yy - yy.toNumber()) * 100.0);
         return Lang.format("$1$.$2$.$3$", [
            date.month.format("%d"),
            date.day.format("%d"),
            yy.format("%d"),
         ]);
      } else if (date_formatter == 5 || date_formatter == 6) {
         // dd mmm
         var day = null;
         var month = null;
         if (Application.getApp().getProperty("force_date_english")) {
            day = date.day;
            month = MONTHS_OF_THE_YEAR[date.month-1];
         } else {
            var medium_date = Date.info(now, Time.FORMAT_MEDIUM);
            day = date.day;
            month = medium_date.month;
         }
         if (date_formatter == 5) {
            return Lang.format("$1$ $2$", [day.format("%d"), month]);
         } else {
            return Lang.format("$1$ $2$", [month, day.format("%d")]);
         }
      } else {
         // Invalid use format 0: "ddd d"
            return Lang.format("$1$ $2$", [
               DAYS_OF_THE_WEEK[date.day_of_week-1],
               date.day.format("%d"),
            ]);
      }
   }

   static function convertCoorX(radians, radius) {
        return center_x + radius * Math.cos(radians);
    }

    static function convertCoorY(radians, radius) {
        return center_y + radius * Math.sin(radians);
    }

    static function toKValue(value) {
        var valK = value / 1000.0;
        return valK.format("%0.1f");
    }
}
