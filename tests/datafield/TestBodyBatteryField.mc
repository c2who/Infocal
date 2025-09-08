import Toybox.Test;
import Toybox.Lang;

(:test)
function testBodyBatteryField(logger as Logger) as Boolean {
    var field = new BodyBatteryField(9);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 9, "Field ID should be 9");

    // min_val and max_val bounds
    Test.assertEqualMessage(field.min_val(), 0.0, "min_val should return 0.0");
    Test.assertEqualMessage(field.max_val(), 100.0, "max_val should return 100.0");

    // cur_val should return a Float >= 0.0
    var curVal = field.cur_val();
    Test.assertMessage(curVal >= 0.0, "cur_val should be non-negative");

    // min_label and max_label format correctly
    Test.assertEqualMessage(field.min_label(5.0), "5", "min_label should format integer '5'");
    Test.assertEqualMessage(field.max_label(7.0), "7", "max_label should format integer '7'");

    // cur_label boundary and normal formatting
    Test.assertEqualMessage(field.cur_label(1.0), "BODY --", "cur_label should return 'BODY --' when value <= 1");
    Test.assertEqualMessage(field.cur_label(50.0), "BODY 50", "cur_label should return 'BODY 50' for normal values");

    // bar_data should return true
    Test.assertEqualMessage(field.bar_data(), true, "bar_data should be true");

    return true;
}
