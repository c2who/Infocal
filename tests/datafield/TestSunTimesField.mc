import Toybox.Lang;
import Toybox.Test;

(:test)
function testSunTimesField(logger as Test.Logger) as Boolean {
    var field = new SunTimesField(32);

    Test.assertEqualMessage(field.field_id(), 32, "Field ID '" + field.field_id() + "' should be 32");

    // Test cur_label method - this field only implements cur_label
    var curLabel = field.cur_label(50.0);
    Test.assertMessage(curLabel != null, "Current label '" + curLabel + "' should not be null");

    return true;
}
