import Toybox.Lang;
import Toybox.System;

/* ALARM */
class AlarmField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var settings = System.getDeviceSettings();
      value = settings.alarmCount;
      return Lang.format("ALAR $1$", [value.format("%d")]);
   }
}
