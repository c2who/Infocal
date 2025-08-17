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

   static const DAYS_OF_THE_WEEK = {
         Date.DAY_MONDAY => "MON",
         Date.DAY_TUESDAY => "TUE",
         Date.DAY_WEDNESDAY => "WED",
         Date.DAY_THURSDAY => "THU",
         Date.DAY_FRIDAY => "FRI",
         Date.DAY_SATURDAY => "SAT",
         Date.DAY_SUNDAY => "SUN",
      };
   static const MONTHS_OF_THE_YEAR = {
         Date.MONTH_JANUARY => "JAN",
         Date.MONTH_FEBRUARY => "FEB",
         Date.MONTH_MARCH => "MAR",
         Date.MONTH_APRIL => "APR",
         Date.MONTH_MAY => "MAY",
         Date.MONTH_JUNE => "JUN",
         Date.MONTH_JULY => "JUL",
         Date.MONTH_AUGUST => "AUG",
         Date.MONTH_SEPTEMBER => "SEP",
         Date.MONTH_OCTOBER => "OCT",
         Date.MONTH_NOVEMBER => "NOV",
         Date.MONTH_DECEMBER => "DEC",
      };

    static function getFormattedDate() as String {
      var now = Time.now();
      var date = Date.info(now, Time.FORMAT_SHORT);
      var date_formatter = Application.getApp().getProperty("date_format");

      if (date_formatter == 0) {
         // ddd d
         if (Application.getApp().getProperty("force_date_english")) {
            var day_of_week = date.day_of_week;
            return Lang.format("$1$ $2$", [
               DAYS_OF_THE_WEEK[day_of_week],
               date.day.format("%d"),
            ]);
         } else {
            var long_date = Date.info(now, Time.FORMAT_LONG);
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
            month = MONTHS_OF_THE_YEAR[date.month];
         } else {
            var medium_date = Date.info(now, Time.FORMAT_MEDIUM);
            day = medium_date.day;
            month = MONTHS_OF_THE_YEAR[medium_date.month];
         }
         if (date_formatter == 5) {
            return Lang.format("$1$ $2$", [day.format("%d"), month]);
         } else {
            return Lang.format("$1$ $2$", [month, day.format("%d")]);
         }
      } else {
         // Invalid use format 0: "ddd d"
         var day_of_week = date.day_of_week;
            return Lang.format("$1$ $2$", [
               DAYS_OF_THE_WEEK[day_of_week],
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
