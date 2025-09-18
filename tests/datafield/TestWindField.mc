import Toybox.Lang;
import Toybox.Test;

(:test)
function testWindField(logger as Test.Logger) as Boolean {
    var field = new WindField(39);

    Test.assertEqualMessage(field.field_id(), 39, "Field ID '" + field.field_id() + "' should be 39");

    // Test cur_label method - this field only implements cur_label
    var curLabel = field.cur_label(50.0);
    Test.assertMessage(curLabel != null, "Current label '" + curLabel + "' should not be null");

    return true;
}
