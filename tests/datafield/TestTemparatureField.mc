import Toybox.Lang;
import Toybox.Test;

(:test)
function testTemparatureField(logger as Test.Logger) as Boolean {
    var field = new TemparatureField(33);

    Test.assertEqualMessage(field.field_id(), 33, "Field ID '" + field.field_id() + "' should be 33");

    var maxValue = field.max_val();
    var curValue = field.cur_val();
    var maxLabel = field.max_label(100.0);
    var curLabel = field.cur_label(50.0);

    Test.assertMessage(maxValue != null, "Max value '" + maxValue + "' should not be null");
    Test.assertMessage(curValue != null, "Current value '" + curValue + "' should not be null");
    Test.assertMessage(maxLabel != null, "Max label '" + maxLabel + "' should not be null");
    Test.assertMessage(curLabel != null, "Current label '" + curLabel + "' should not be null");
    Test.assertEqualMessage(field.bar_data(), false, "Bar data '" + field.bar_data() + "' should be false");

    return true;
}
