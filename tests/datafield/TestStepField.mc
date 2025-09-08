import Toybox.Test;
import Toybox.Lang;

(:test)
function testStepField(logger as Logger) as Boolean {
    var field = new StepField(26);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 26, "Field ID should be 26");

    // max_val should be non-negative
    Test.assertMessage(field.max_val() >= 0.0, "max_val should be non-negative");

    // cur_val should be non-negative
    Test.assertMessage(field.cur_val() >= 0.0, "cur_val should be non-negative");

    // max_label ends with 'K'
    Test.assertMessage(field.max_label(1000.0).equals("1000K"), "max_label should equal '1000K'");

    // cur_label minimal and full formats
    var minimal = field.cur_label(500.0);
    Test.assertMessage(minimal.length() > 0, "cur_label should return non-empty string");

    return true;
}
