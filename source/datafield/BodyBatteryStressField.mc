import Toybox.Lang;
import Toybox.SensorHistory;

/* BODY BATTERY/STRESS COMBINED */
class BodyBatteryStressField extends BaseDataField {
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
