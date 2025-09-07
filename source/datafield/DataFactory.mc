import Toybox.Lang;

enum /* FIELD_TYPES */ {
   FIELD_TYPE_HEART_RATE = 0,
   FIELD_TYPE_BATTERY,
   FIELD_TYPE_CALORIES,
   FIELD_TYPE_DISTANCE,
   FIELD_TYPE_MOVE,
   FIELD_TYPE_STEP,
   FIELD_TYPE_ACTIVE,

   FIELD_TYPE_DATE,
   FIELD_TYPE_TIME,
   FIELD_TYPE_EMPTY,

   FIELD_TYPE_NOTIFICATIONS = 10,
   FIELD_TYPE_ALARMS,
   FIELD_TYPE_ELEVATION,
   FIELD_TYPE_TEMPERATURE,
   FIELD_TYPE_SUNRISE_SUNSET,
   FIELD_TYPE_FLOOR,
   FIELD_TYPE_GROUP_NOTI,
   FIELD_TYPE_DISTANCE_WEEK,
   FIELD_TYPE_BAROMETER,
   FIELD_TYPE_TIME_SECONDARY,
   FIELD_TYPE_PHONE_STATUS,
   FIELD_TYPE_COUNTDOWN,
   FIELD_TYPE_WEEKCOUNT,

   FIELD_TYPE_TEMPERATURE_OUT = 23,
   FIELD_TYPE_TEMPERATURE_HL,
   FIELD_TYPE_WEATHER,

   FIELD_TYPE_AMPM_INDICATOR = 26,
   FIELD_TYPE_CTEXT_INDICATOR,
   FIELD_TYPE_WIND,
   FIELD_TYPE_BODY_BATTERY,
   FIELD_TYPE_STRESS,
   FIELD_TYPE_BB_STRESS,

   FIELD_TYPE_TEMPERATURE_GARMIN = 32,
   FIELD_TYPE_PRECIPITATION_GARMIN,
   FIELD_TYPE_WEATHER_GARMIN,
   FIELD_TYPE_TEMPERATURE_HL_GARMIN,

   FIELD_TYPE_MODERATE = 36,
   FIELD_TYPE_VIGOROUS,
   FIELD_TYPE_AIR_QUALITY,
   FIELD_TYPE_TIME_TO_RECOVERY,
   FIELD_TYPE_CALORIES_ACTIVE = 40,
}

function buildFieldObject(type as Number) {
   if (type == FIELD_TYPE_HEART_RATE) {
      return new HRField(type);
   } else if (type == FIELD_TYPE_BATTERY) {
      return new BatteryField(type);
   } else if (type == FIELD_TYPE_CALORIES) {
      return new CaloField(type);
   } else if (type == FIELD_TYPE_DISTANCE) {
      return new DistanceField(type);
   } else if (type == FIELD_TYPE_MOVE) {
      return new MoveField(type);
   } else if (type == FIELD_TYPE_STEP) {
      return new StepField(type);
   } else if (type == FIELD_TYPE_ACTIVE) {
      return new ActiveField(type);
   } else if (type == FIELD_TYPE_MODERATE) {
      return new ActiveModerateField(type);
   } else if (type == FIELD_TYPE_VIGOROUS) {
      return new ActiveVigorousField(type);
   } else if (type == FIELD_TYPE_DATE) {
      return new DateField(type);
   } else if (type == FIELD_TYPE_TIME) {
      return new TimeField(type);
   } else if (type == FIELD_TYPE_EMPTY) {
      return new EmptyDataField(type);
   } else if (type == FIELD_TYPE_NOTIFICATIONS) {
      return new NotifyField(type);
   } else if (type == FIELD_TYPE_ALARMS) {
      return new AlarmField(type);
   } else if (type == FIELD_TYPE_ELEVATION) {
      return new ElevationField(type);
   } else if (type == FIELD_TYPE_TEMPERATURE) {
      return new TemparatureField(type);
   } else if (type == FIELD_TYPE_SUNRISE_SUNSET) {
      return new SunField(type);
   } else if (type == FIELD_TYPE_FLOOR) {
      return new FloorField(type);
   } else if (type == FIELD_TYPE_GROUP_NOTI) {
      return new GroupNotiField(type);
   } else if (type == FIELD_TYPE_DISTANCE_WEEK) {
      return new WeekDistanceField(type);
   } else if (type == FIELD_TYPE_BAROMETER) {
      return new BarometerField(type);
   } else if (type == FIELD_TYPE_TIME_SECONDARY) {
      return new TimeSecondaryField(type);
   } else if (type == FIELD_TYPE_PHONE_STATUS) {
      return new PhoneField(type);
   } else if (type == FIELD_TYPE_COUNTDOWN) {
      return new CountdownField(type);
   } else if (type == FIELD_TYPE_WEEKCOUNT) {
      return new WeekCountField(type);
   } else if (type == FIELD_TYPE_TEMPERATURE_OUT) {
      return new TemparatureOutField(type);
   } else if (type == FIELD_TYPE_TEMPERATURE_HL) {
      return new TemparatureHLField(type);
   } else if (type == FIELD_TYPE_WEATHER) {
      return new WeatherField(type);
   } else if (type == FIELD_TYPE_AMPM_INDICATOR) {
      return new AMPMField(type);
   } else if (type == FIELD_TYPE_CTEXT_INDICATOR) {
      return new CTextField(type);
   } else if (type == FIELD_TYPE_WIND) {
      return new WindField(type);
   } else if (type == FIELD_TYPE_BODY_BATTERY) {
      return new BodyBatteryField(type);
   } else if (type == FIELD_TYPE_STRESS) {
      return new StressField(type);
   } else if (type == FIELD_TYPE_BB_STRESS) {
      return new BodyBatteryStressField(type);
   } else if (type == FIELD_TYPE_TEMPERATURE_GARMIN) {
      return new TemparatureGarminField(type);
   } else if (type == FIELD_TYPE_PRECIPITATION_GARMIN) {
      return new PrecipitationGarminField(type);
   } else if (type == FIELD_TYPE_WEATHER_GARMIN) {
      return new WeatherGarminField(type);
   } else if (type == FIELD_TYPE_TEMPERATURE_HL_GARMIN) {
      return new TemperatureHLGarminField(type);
   } else if (type == FIELD_TYPE_AIR_QUALITY) {
      return new AirQualityField(type);
   } else if (type == FIELD_TYPE_TIME_TO_RECOVERY) {
      return new TimeToRecoveryField(type);
   } else if (type == FIELD_TYPE_CALORIES_ACTIVE) {
      return new CaloField(type);
   }

   return new EmptyDataField(FIELD_TYPE_EMPTY);
}

class BaseDataField {
   private var _field_id as Number;

   function initialize(id as Number) {
      _field_id = id;
   }

   function field_id() as Number {
      return _field_id;
   }

   function have_secondary() as Boolean {
      return false;
   }

   function min_val() as Float {
      return 0.0;
   }

   function max_val() as Float {
      return 100.0;
   }

   function cur_val() as Float {
      return 0.01;
   }

   function min_label(value as Float) as String {
      return "0";
   }

   function max_label(value as Float) as String {
      return "100";
   }

   function cur_label(value as Float) as String {
      return "0";
   }

   function need_draw() as Boolean {
      return true;
   }

   function bar_data() as Boolean {
      return false;
   }

}

class EmptyDataField {
   function initialize(id as Number) {
      _field_id = id;
   }

   private var _field_id;

   function field_id() as Number{
      return _field_id;
   }

   function need_draw() as Boolean {
      return false;
   }
}
