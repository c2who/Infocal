import Toybox.Lang;
import Toybox.Test;

(:test)
function testWeekCountField(logger as Logger) as Boolean {
    var field = new WeekCountField(14);
    Test.assertEqualMessage(field.field_id(), 14, "Field ID should be 14");

    var label = field.cur_label(0.0);
    Test.assertMessage(label.equals("WEEK "), "cur_label should equal 'WEEK '");

    return true;
}
