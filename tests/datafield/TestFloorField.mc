import Toybox.Test;
import Toybox.Lang;
import Toybox.ActivityMonitor;

(:test)
function testFloorField(logger as Logger) as Boolean {
    var field = new FloorField(19);
    Test.assertEqualMessage(field.field_id(), 19, "Field ID should be 19");

    // max_val and cur_val should be non-negative
    var maxVal = field.max_val();
    Test.assertMessage(maxVal >= 0.0, "max_val should be non-negative");
    var curVal = field.cur_val();
    Test.assertMessage(curVal >= 0.0, "cur_val should be non-negative");

    // max_label formats integer
    Test.assertEqualMessage(field.max_label(5.0), "5", "max_label should format '5'");

    // cur_label handles null and non-null
    Test.assertEqualMessage(field.cur_label(null), "FLOOR --", "cur_label should return 'FLOOR --' when value is null");
    Test.assertEqualMessage(field.cur_label(3.0), "FLOOR 3", "cur_label should return 'FLOOR 3' for non-null value");

    // bar_data
    Test.assertEqualMessage(field.bar_data(), true, "bar_data should be true");

    return true;
}
