import Toybox.ActivityMonitor;
import Toybox.Lang;
import Toybox.Test;

(:test)
function testActiveField(logger as Logger) as Boolean {
    // Initialize field with ID 1
    var field = new ActiveField(1);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 1, "Field ID should be 1");

    // max_val and cur_val should be non-negative
    var maxVal = field.max_val();
    Test.assertMessage(maxVal >= 0.0, "max_val should be non-negative");

    var curVal = field.cur_val();
    Test.assertMessage(curVal >= 0.0, "cur_val should be non-negative");

    // max_label should format integer values
    Test.assertEqualMessage(field.max_label(5.0), "5", "max_label should format integer value '5'");

    // cur_label should format with prefix
    Test.assertEqualMessage(field.cur_label(7.0), "ACT 7", "cur_label should format as 'ACT 7'");

    // bar_data
    Test.assertEqualMessage(field.bar_data(), true, "bar_data should be true");

    return true;
}
