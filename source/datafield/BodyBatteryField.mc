import Toybox.Lang;
import Toybox.SensorHistory;

/* BODY BATTERY */
class BodyBatteryField extends BaseDataField {
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
      var sample = Toybox.SensorHistory.getBodyBatteryHistory({
         :period => 1,
      }).next();
      if (sample != null && sample.data != null) {
         currentBodyBattery = sample.data;
      }
   }
   return currentBodyBattery.toFloat();
}
