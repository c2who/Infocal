import Toybox.Test;
import Toybox.Lang;

(:test)
function testActiveVigorousField(logger as Logger) as Boolean {
    // Initialize field with ID 3
    var field = new ActiveVigorousField(3);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 3, "Field ID should be 3");

    // max_val and cur_val should be non-negative
    var maxVal = field.max_val();
    Test.assertMessage(maxVal >= 0.0, "max_val should be non-negative");

    var curVal = field.cur_val();
    Test.assertMessage(curVal >= 0.0, "cur_val should be non-negative");

    // max_label should format integer values
    Test.assertEqualMessage(field.max_label(8.0), "8", "max_label should format integer value '8'");

    // cur_label should format with prefix
    Test.assertEqualMessage(field.cur_label(4.0), "VACT 4", "cur_label should format as 'VACT 4'");

    // bar_data
    Test.assertEqualMessage(field.bar_data(), true, "bar_data should be true");

    return true;
}
