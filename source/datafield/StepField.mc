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
      return Globals.toKValue(value);
   }

   function cur_label(value) {
      var need_minimal = Properties.getValue("minimal_data");
      var dispStep = (value < 1000) ? value.format("%d") : Globals.toKValue(value);
      if (need_minimal) {
            return Lang.format("$1$", [ dispStep ]);
      } else {
         return Lang.format("STEP $1$", [dispStep]);
      }
   }

   function bar_data() {
      return true;
   }
}
