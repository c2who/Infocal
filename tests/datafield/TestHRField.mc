import Toybox.Test;
import Toybox.Lang;

(:test)
function testHRField(logger as Logger) as Boolean {
    var field = new HRField(21);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 21, "Field ID should be 21");

    // Test min_val and max_val
    Test.assertEqualMessage(field.min_val(), 50.0, "min_val should return 50.0");
    Test.assertEqualMessage(field.max_val(), 120.0, "max_val should return 120.0");

    // cur_val should be non-negative
    var curVal = field.cur_val();
    Test.assertMessage(curVal >= 0.0, "cur_val should be non-negative");

    // cur_label boundary
    Test.assertEqualMessage(field.cur_label(1.0), "HR --", "cur_label should return 'HR --' when value <= 1");
    // cur_label normal
    Test.assertEqualMessage(field.cur_label(75.0), "HR 75", "cur_label should return 'HR 75' for normal values");

    // bar_data
    Test.assertEqualMessage(field.bar_data(), true, "bar_data should be true");

    return true;
}
