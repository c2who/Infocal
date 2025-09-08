import Toybox.Test;
import Toybox.Lang;

(:test)
function testTimeField(logger as Logger) as Boolean {
    var field = new TimeField(12);
    Test.assertEqualMessage(field.field_id(), 12, "Field ID should be 12");

    var timeStr = field.cur_label(0.0);
    Test.assertMessage(timeStr.equals(":"), "cur_label should equal ':'");

    return true;
}
