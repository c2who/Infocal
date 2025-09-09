import Toybox.Lang;
import Toybox.Test;

(:test)
function testTimeToRecoveryField(logger as Test.Logger) as Boolean {
    var field = new TimeToRecoveryField(36);

    Test.assertEqualMessage(field.field_id(), 36, "Field ID '" + field.field_id() + "' should be 36");

    var maxValue = field.max_val();
    var curValue = field.cur_val();
    var maxLabel = field.max_label(100.0);
    var curLabel = field.cur_label(50.0);

    Test.assertMessage(maxValue != null, "Max value '" + maxValue + "' should not be null");
    Test.assertMessage(curValue != null, "Current value '" + curValue + "' should not be null");
    Test.assertMessage(maxLabel != null, "Max label '" + maxLabel + "' should not be null");
    Test.assertMessage(curLabel != null, "Current label '" + curLabel + "' should not be null");
    Test.assertEqualMessage(field.bar_data(), true, "Bar data '" + field.bar_data() + "' should be true");

    return true;
} 
