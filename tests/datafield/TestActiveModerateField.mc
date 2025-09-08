import Toybox.Test;
import Toybox.Lang;

(:test)
function testActiveModerateField(logger as Logger) as Boolean {
    // Initialize field with ID 2
    var field = new ActiveModerateField(2);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 2, "Field ID should be 2");

    // max_val and cur_val should be non-negative
    var maxVal = field.max_val();
    Test.assertMessage(maxVal >= 0.0, "max_val should be non-negative");

    var curVal = field.cur_val();
    Test.assertMessage(curVal >= 0.0, "cur_val should be non-negative");

    // max_label should format integer values
    Test.assertEqualMessage(field.max_label(10.0), "10", "max_label should format integer value '10'");

    // cur_label should format with prefix
    Test.assertEqualMessage(field.cur_label(5.0), "MACT 5", "cur_label should format as 'MACT 5'");

    // bar_data
    Test.assertEqualMessage(field.bar_data(), true, "bar_data should be true");

    return true;
}
