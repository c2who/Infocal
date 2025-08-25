using Toybox.Activity;
using Toybox.ActivityMonitor;

import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

/* BATTERY */
class BatteryField extends BaseDataField {
  private var _hasBatteryInDays = (System.Stats has :batteryInDays) as Boolean; // API 3.3.0

  function initialize(id) {
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
      return Lang.format("$1$ HRS", [total_hours.format("%0.1f")]);
    } else if (total_hours >= 99 * 24) {
      return "99+ DAYS";
    } else {
      total_hours = total_hours.toNumber();
      var days = total_hours / 24;
      var hrs = total_hours % 24;
      var days_str = days > 1 ? "DAYS" : "DAY";
      if (hrs == 0) {
        return Lang.format("$1$ $2$", [days, days_str]);
      } else {
        return Lang.format("$1$ $2$ $3$H", [days, days_str, hrs]);
      }
    }
  }

  function cur_label(value) {
    var battery_format = Application.getApp().getProperty("battery_format");

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
        if (
          bat_last_pcnt != null &&
          bat_last_time != null &&
          bat_last_pcnt >= value
        ) {
          value = bat_last_pcnt;
          time_since = Time.now().value() - bat_last_time;
        }
        return format_hours(
          (value * bat_dchg1_time - time_since) / Gregorian.SECONDS_PER_HOUR
        );
      }
    }
  }

  function bar_data() {
    return true;
  }
}

/* HEART RATE */
class HRField extends BaseDataField {
  function initialize(id) {
    BaseDataField.initialize(id);
  }

  function min_val() {
    return 50.0;
  }

  function max_val() {
    return 120.0;
  }

  function cur_val() {
    var heartRate = _retrieveHeartrate();
    return heartRate.toFloat();
  }

  function min_label(value) {
    return value.format("%d");
  }

  function max_label(value) {
    return value.format("%d");
  }

  function cur_label(value) {
    var heartRate = value;
    if (heartRate <= 1) {
      return "HR --";
    }
    return Lang.format("HR $1$", [heartRate.format("%d")]);
  }

  function bar_data() {
    return true;
  }
}

function doesDeviceSupportHeartrate() {
  return ActivityMonitor has :INVALID_HR_SAMPLE;
}

function _retrieveHeartrate() {
  var currentHeartrate = 0.0;
  var activityInfo = Activity.getActivityInfo();
  var sample = activityInfo.currentHeartRate;
  if (sample != null) {
    currentHeartrate = sample;
  } else if (ActivityMonitor has :getHeartRateHistory) {
    sample = ActivityMonitor.getHeartRateHistory(
      1,
      /* newestFirst */ true
    ).next();
    if (
      sample != null &&
      sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE
    ) {
      currentHeartrate = sample.heartRate;
    }
  }
  return currentHeartrate.toFloat();
}

/* BODY BATTERY */
class BodyBatteryField extends BaseDataField {
  function initialize(id) {
    BaseDataField.initialize(id);
  }

  function min_val() {
    return 0.0;
  }

  function max_val() {
    return 100.0;
  }

  function cur_val() {
    var bodyBattery = _retrieveBodyBattery();
    return bodyBattery.toFloat();
  }

  function min_label(value) {
    return value.format("%d");
  }

  function max_label(value) {
    return value.format("%d");
  }

  function cur_label(value) {
    var bodyBattery = value;
    if (bodyBattery <= 1) {
      return "BODY --";
    }
    return Lang.format("BODY $1$", [bodyBattery.format("%d")]);
  }

  function bar_data() {
    return true;
  }
}

function _retrieveBodyBattery() {
  var currentBodyBattery = 0.0;
  if (
    Toybox has :SensorHistory &&
    Toybox.SensorHistory has :getBodyBatteryHistory
  ) {
    var iter = Toybox.SensorHistory.getBodyBatteryHistory({
      :period => 2, // Get last 2 entries
    });
    var sample = iter.next();
    while (sample != null) {
      if (sample.data != null && sample.data >= 0 && sample.data <= 100) {
        currentBodyBattery = sample.data;
        break;
      }
      sample = iter.next();
    }
  }
  return currentBodyBattery.toFloat();
}

/* STRESS */
class StressField extends BaseDataField {
  function initialize(id) {
    BaseDataField.initialize(id);
  }

  function min_val() {
    return 0.0;
  }

  function max_val() {
    return 100.0;
  }

  function cur_val() {
    var stress = _retrieveStress();
    return stress.toFloat();
  }

  function min_label(value) {
    return value.format("%d");
  }

  function max_label(value) {
    return value.format("%d");
  }

  function cur_label(value) {
    var stress = value;
    if (stress <= 1) {
      return "STRESS --";
    }
    return Lang.format("STRESS $1$", [stress.format("%d")]);
  }

  function bar_data() {
    return true;
  }
}

function _retrieveStress() {
  var currentStress = 0.0;
  if (Toybox has :SensorHistory && Toybox.SensorHistory has :getStressHistory) {
    var iter = Toybox.SensorHistory.getStressHistory({
      :period => 2, // Get last 2 entries
    });
    var sample = iter.next();
    while (sample != null) {
      if (sample.data != null && sample.data >= 0 && sample.data <= 100) {
        currentStress = sample.data;
        break;
      }
      sample = iter.next();
    }
  }
  return currentStress.toFloat();
}

/* BODY BATTERY/STRESS COMBINED */
class BodyBatteryStressField extends BaseDataField {
  function initialize(id) {
    BaseDataField.initialize(id);
  }

  function min_val() {
    return 0.0;
  }

  function max_val() {
    return 100.0;
  }

  function cur_val() {
    return 0.0;
  }

  function min_label(value) {
    return value.format("%d");
  }

  function max_label(value) {
    return value.format("%d");
  }

  function cur_label(value) {
    var bodyBattery = _retrieveBodyBattery();
    var bodyBatteryString = "--";
    if (bodyBattery > 1) {
      bodyBatteryString = bodyBattery.format("%d");
    }
    var stress = _retrieveStress();
    var stressString = "--";
    if (stress > 1) {
      stressString = stress.format("%d");
    }
    return Lang.format("B $1$ S $2$", [bodyBatteryString, stressString]);
  }

  function bar_data() {
    return false;
  }
}

/* ALTITUDE */
class AltitudeField extends BaseDataField {
  function initialize(id) {
    BaseDataField.initialize(id);
  }

  function cur_label(value) {
    var need_minimal = Application.getApp().getProperty("minimal_data");
    value = 0;
    // #67 Try to retrieve altitude from current activity, before falling back on elevation history.
    // Note that Activity::Info.altitude is supported by CIQ 1.x, but elevation history only on select CIQ 2.x
    // devices.
    var settings = System.getDeviceSettings();
    var activityInfo = Activity.getActivityInfo();
    var altitude = activityInfo.altitude;
    if (
      altitude == null &&
      Toybox has :SensorHistory &&
      Toybox.SensorHistory has :getElevationHistory
    ) {
      var sample = SensorHistory.getElevationHistory({
        :period => 1,
        :order => SensorHistory.ORDER_NEWEST_FIRST,
      }).next();
      if (sample != null && sample.data != null) {
        altitude = sample.data;
      }
    }
    if (altitude != null) {
      var unit = "";
      // Metres (no conversion necessary).
      if (settings.elevationUnits == System.UNIT_METRIC) {
        unit = "m";
        // Feet.
      } else {
        altitude *= /* FT_PER_M */ 3.28084;
        unit = "ft";
      }

      value = altitude.format("%d");
      value += unit;
      if (need_minimal) {
        return value;
      } else {
        var temp = Lang.format("ALTI $1$", [value]);
        if (temp.length() > 10) {
          return Lang.format("$1$", [value]);
        }
        return temp;
      }
    } else {
      if (need_minimal) {
        return "--";
      } else {
        return "ALTI --";
      }
    }
  }
}

/* ON DEVICE TEMPERATURE */
class TemparatureField extends BaseDataField {
  function initialize(id) {
    BaseDataField.initialize(id);
  }

  function cur_label(value) {
    var need_minimal = Application.getApp().getProperty("minimal_data");
    value = 0;
    var settings = System.getDeviceSettings();
    if (
      Toybox has :SensorHistory &&
      Toybox.SensorHistory has :getTemperatureHistory
    ) {
      var sample = SensorHistory.getTemperatureHistory(null).next();
      if (sample != null && sample.data != null) {
        var temperature = sample.data;
        if (settings.temperatureUnits == System.UNIT_STATUTE) {
          temperature = temperature * (9.0 / 5) + 32; // Convert to Farenheit: ensure floating point division.
        }
        value = temperature.format("%d") + "°";
        if (need_minimal) {
          return value;
        } else {
          return Lang.format("TEMP $1$", [value]);
        }
      } else {
        if (need_minimal) {
          return "--";
        } else {
          return "TEMP --";
        }
      }
    } else {
      if (need_minimal) {
        return "--";
      } else {
        return "TEMP --";
      }
    }
  }
}
/* ALARM */
class AlarmField extends BaseDataField {
  function initialize(id) {
    BaseDataField.initialize(id);
  }

  function cur_label(value) {
    var settings = System.getDeviceSettings();
    value = settings.alarmCount;
    return Lang.format("ALAR $1$", [value.format("%d")]);
  }
}

/* FLOORS CLIMBED */
class FloorField extends BaseDataField {
  function initialize(id) {
    BaseDataField.initialize(id);
  }

  function max_val() {
    var activityInfo = ActivityMonitor.getInfo();
    if (activityInfo has :floorsClimbedGoal) {
      return activityInfo.floorsClimbedGoal.toFloat();
    } else {
      return 1.0;
    }
  }

  function cur_val() {
    var activityInfo = ActivityMonitor.getInfo();
    if (activityInfo has :floorsClimbed) {
      return activityInfo.floorsClimbed.toFloat();
    } else {
      return 0.0;
    }
  }

  function max_label(value) {
    return value.format("%d");
  }

  function cur_label(value) {
    if (value == null) {
      return "FLOOR --";
    }
    return Lang.format("FLOOR $1$", [value.format("%d")]);
  }

  function bar_data() {
    return true;
  }
}

/* BAROMETER */
class BarometerField extends BaseDataField {
  function initialize(id) {
    BaseDataField.initialize(id);
  }

  function cur_val() {
    var presure_data = _retrieveBarometer();
    return presure_data;
  }

  function cur_label(value) {
    var value1 = value[0];
    var value2 = value[1];
    if (value1 == null) {
      return "BARO --";
    } else {
      var hector_pascal = value1 / 100.0;

      var unit = Application.getApp().getProperty("barometer_unit");
      if (unit == 1) {
        // convert to inHg
        hector_pascal = hector_pascal * 0.0295301;
      }
      var signal = "";
      if (value2 == 1) {
        signal = "+";
      } else if (value2 == -1) {
        signal = "-";
      }

      if (unit == 1) {
        return Lang.format("BAR $1$$2$", [
          hector_pascal.format("%0.2f"),
          signal,
        ]);
      }
      return Lang.format("BAR $1$$2$", [hector_pascal.format("%d"), signal]);
    }
  }

  // Create a method to get the SensorHistoryIterator object
  function _getIterator() {
    // Check device for SensorHistory compatibility
    if (
      Toybox has :SensorHistory &&
      Toybox.SensorHistory has :getPressureHistory
    ) {
      return Toybox.SensorHistory.getPressureHistory({});
    }
    return null;
  }

  // Create a method to get the SensorHistoryIterator object
  function _getIteratorDurate(hour) {
    // Check device for SensorHistory compatibility
    if (
      Toybox has :SensorHistory &&
      Toybox.SensorHistory has :getPressureHistory
    ) {
      var duration = new Time.Duration(hour * 3600);
      return Toybox.SensorHistory.getPressureHistory({
        "period" => duration,
        "order" => SensorHistory.ORDER_OLDEST_FIRST,
      });
    }
    return null;
  }

  function _retrieveBarometer() {
    var trend_iter = _getIteratorDurate(3); // 3 hour
    var trending = null;
    if (trend_iter != null) {
      // get 5 sample
      var sample = null;
      var num = 0.0;
      for (var i = 0; i < 5; i += 1) {
        sample = trend_iter.next();
        if (sample != null && sample has :data) {
          var d = sample.data;
          if (d != null) {
            if (trending == null) {
              trending = d;
              num += 1;
            } else {
              trending += d;
              num += 1;
            }
          }
        }
      }
      if (trending != null) {
        trending /= num;
      }
    }
    var iter = _getIterator();
    // Print out the next entry in the iterator
    if (iter != null) {
      var sample = iter.next();
      if (sample != null && sample has :data) {
        var d = sample.data;
        var c = 0;
        if (trending != null && d != null) {
          c = trending > d ? -1 : 1;
        }
        return [d, c];
      }
    }
    return [null, 0];
  }
}
