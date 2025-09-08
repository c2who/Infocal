import Toybox.Test;
import Toybox.Lang;

(:test)
function testBodyBatteryStressField(logger as Logger) as Boolean {
    var field = new BodyBatteryStressField(10);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 10, "Field ID should be 10");

    // Test min_val, max_val, cur_val
    Test.assertEqualMessage(field.min_val(), 0.0, "min_val should return 0.0");
    Test.assertEqualMessage(field.max_val(), 100.0, "max_val should return 100.0");
    Test.assertEqualMessage(field.cur_val(), 0.0, "cur_val should return 0.0");

    // Test min_label and max_label formatting
    Test.assertEqualMessage(field.min_label(3.0), "3", "min_label should format integer '3'");
    Test.assertEqualMessage(field.max_label(7.0), "7", "max_label should format integer '7'");

    // Test cur_label default output when no history
    var label = field.cur_label(0.0);
    Test.assertEqualMessage(label, "B -- S --", "cur_label should default to 'B -- S --' when no data");

    // Test bar_data
    Test.assertEqualMessage(field.bar_data(), false, "bar_data should be false");

    return true;
}
