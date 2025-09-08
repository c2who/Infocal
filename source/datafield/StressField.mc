import Toybox.Lang;
import Toybox.SensorHistory;

/* STRESS */
class StressField extends BaseDataField {
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
   if (
      Toybox has :SensorHistory &&
      Toybox.SensorHistory has :getStressHistory
   ) {
      var sample = Toybox.SensorHistory.getStressHistory({
         :period => 1,
      }).next();
      if (sample != null && sample.data != null) {
         currentStress = sample.data;
      }
   }
   return currentStress.toFloat();
}
