import Toybox.Test;
import Toybox.Lang;
import Toybox.System;

(:test)
function testBatteryField(logger as Logger) as Boolean {
    var field = new BatteryField(8);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 8, "Field ID should be 8");

    // Test min_val and max_val
    Test.assertEqualMessage(field.min_val(), 0.0, "min_val should return 0.0");
    Test.assertEqualMessage(field.max_val(), 100.0, "max_val should return 100.0");

    // Test cur_val range
    var curVal = field.cur_val();
    Test.assertMessage(curVal >= 0.0 and curVal <= 100.0, "cur_val should be between 0.0 and 100.0");

    // Test min_label and max_label
    Test.assertEqualMessage(field.min_label(curVal), "b", "min_label should return 'b'");
    Test.assertEqualMessage(field.max_label(curVal), "P", "max_label should return 'P'");

    // Test cur_label does not throw and returns non-empty string
    var label = field.cur_label(curVal);
    Test.assertMessage(label instanceof String, "cur_label should return a String");
    Test.assertMessage(label.length() > 0, "cur_label should return a non-empty string");

    // Test bar_data
    Test.assertEqualMessage(field.bar_data(), true, "bar_data should be true");

    return true;
}
