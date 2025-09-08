import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Lang;

/* STEPS */
class StepField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function max_val() {
      return ActivityMonitor.getInfo().stepGoal.toFloat();
   }

   function cur_val() {
      var currentStep = ActivityMonitor.getInfo().steps;
      return currentStep.toFloat();
   }

   function max_label(value) {
      var valKp = Globals.toKValue(value);
      return Lang.format("$1$K", [valKp]);
   }

   function cur_label(value) {
      var need_minimal = Properties.getValue("minimal_data");
      var currentStep = value;
      if (need_minimal) {
         if (currentStep > 999) {
            return currentStep.format("%d");
         } else {
            return Lang.format("STEP $1$", [currentStep.format("%d")]);
         }
      } else {
         var valKp = Globals.toKValue(currentStep);
         return Lang.format("STEP $1$K", [valKp]);
      }
   }

   function bar_data() {
      return true;
   }
}
