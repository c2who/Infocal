import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;

/* DISTANCE FOR WEEK */
class WeekDistanceField extends BaseDataField {

   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function min_val() {
      return 50.0;
   }

   function max_val() {
      var datas = _retriveWeekValues();
      return datas[1];
   }

   function cur_val() {
      var datas = _retriveWeekValues();
      return datas[0];
   }

   function cur_label(value) {
      var datas = _retriveWeekValues();
      var total_distance = datas[0];

      var need_minimal = Properties.getValue("minimal_data");
      var settings = System.getDeviceSettings();

      var value2 = total_distance;
      var kilo = value2 / 100000;

      var unit = "Km";
      if (settings.distanceUnits == System.UNIT_METRIC) {
      } else {
         kilo *= 0.621371;
         unit = "Mi";
      }

      if (need_minimal) {
         return Lang.format("$1$ $2$", [kilo.format("%0.1f"), unit]);
      } else {
         var valKp = Globals.toKValue(kilo * 1000);
         return Lang.format("DIS $1$$2$", [valKp, unit]);
      }
   }

   function day_of_week(activity) {
      var moment = activity.startOfDay;
      var date = Gregorian.info(moment, Time.FORMAT_SHORT);
      return date.day_of_week;
   }

   function today_of_week() {
      var now = Time.now();
      var date = Gregorian.info(now, Time.FORMAT_SHORT);
      return date.day_of_week;
   }

   function _retriveWeekValues() as Array<Float> {
      var settings = System.getDeviceSettings();
      var firstDayOfWeek = settings.firstDayOfWeek;

      var activities = [];
      var activityInfo = ActivityMonitor.getInfo();
      activities.add(activityInfo);

      if (today_of_week() != firstDayOfWeek) {
         if (ActivityMonitor has :getHistory) {
            var his = ActivityMonitor.getHistory();
            for (var i = 0; i < his.size(); i++) {
               var activity = his[i];
               activities.add(activity);
               if (day_of_week(activity) == firstDayOfWeek) {
                  break;
               }
            }
         }
      }

      var total = 0.0;
      for (var i = 0; i < activities.size(); i++) {
         total += activities[i].distance;
      }
      return [total, 10.0];
   }

   function bar_data() {
      return true;
   }
}
