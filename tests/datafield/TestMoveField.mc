import Toybox.Test;
import Toybox.Lang;
import Toybox.ActivityMonitor;

(:test)
function testMoveField(logger as Logger) as Boolean {
    var field = new MoveField(25);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 25, "Field ID should be 25");

    // Test min_val and max_val
    Test.assertMessage(field.min_val() <= field.max_val(), "min_val should be <= max_val");

    // Test cur_val
    var curVal = field.cur_val();
    Test.assertMessage(curVal >= field.min_val() and curVal <= field.max_val(), "cur_val should be within specified bounds");

    // Test labels
    Test.assertEqualMessage(field.min_label(1.0), "1", "min_label should format '1'");
    Test.assertEqualMessage(field.max_label(2.0), "2", "max_label should format '2'");
    Test.assertEqualMessage(field.cur_label(3.0), "MOVE 3", "cur_label should format 'MOVE 3'");

    return true;
}
