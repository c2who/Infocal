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
      var date_formatter = Properties.getValue("date_format");

      var DAYS_OF_THE_WEEK = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

      var MONTHS_OF_THE_YEAR = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];

      if (date_formatter == 0) {
         // ddd d mmm
         var day = null;
         var day_of_week = null;
         var month = null;
         if (Properties.getValue("force_date_english")) {
            day = date.day.format("%d");
            day_of_week = DAYS_OF_THE_WEEK[date.day_of_week - 1];
            month = MONTHS_OF_THE_YEAR[date.month - 1];
         } else {
            var medium_date = Gregorian.info(now, Time.FORMAT_MEDIUM);
            day = date.day.format("%d");
            day_of_week = medium_date.day_of_week.toUpper();
            month = medium_date.month;
         }
         return Lang.format("$1$ $2$ $3$", [day_of_week, day, month]);
      } else if (date_formatter == 1) {
         // dd.mm
         return Lang.format("$1$.$2$", [date.day.format("%d"), date.month.format("%d")]);
      } else if (date_formatter == 2) {
         // mm.dd
         return Lang.format("$1$.$2$", [date.month.format("%d"), date.day.format("%d")]);
      } else if (date_formatter == 3) {
         // dd.mm.yyyy
         var year = date.year;
         var yy = year / 100.0;
         yy = Math.round((yy - yy.toNumber()) * 100.0);
         return Lang.format("$1$.$2$.$3$", [date.day.format("%d"), date.month.format("%d"), yy.format("%d")]);
      } else if (date_formatter == 4) {
         // mm.dd.yyyy
         var year = date.year;
         var yy = year / 100.0;
         yy = Math.round((yy - yy.toNumber()) * 100.0);
         return Lang.format("$1$.$2$.$3$", [date.month.format("%d"), date.day.format("%d"), yy.format("%d")]);
      } else if (date_formatter == 5 || date_formatter == 6) {
         // dd mmm
         var day = null;
         var month = null;
         if (Properties.getValue("force_date_english")) {
            day = date.day;
            month = MONTHS_OF_THE_YEAR[date.month - 1];
         } else {
            var medium_date = Gregorian.info(now, Time.FORMAT_MEDIUM);
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
         return Lang.format("$1$ $2$", [DAYS_OF_THE_WEEK[date.day_of_week - 1], date.day.format("%d")]);
      }
   }

   static function convertCoorX(radians, radius) {
      return center_x + radius * Math.cos(radians);
   }

   static function convertCoorY(radians, radius) {
      return center_y + radius * Math.sin(radians);
   }

   static function toKValue(value, alwaysConvert as Boolean) {
      if (!alwaysConvert and value <= 10000) {
         return value.format("%d");
      } else {
         var valK = value / 1000.0;
         return valK.format("%0.1f");
      }
   }

   static function getKString(value) {
      if (value <= 10000) {
         return "";
      } else {
         return "K";
      }
   }
}
