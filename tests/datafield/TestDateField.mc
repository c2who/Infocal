import Toybox.Test;
import Toybox.Lang;

(:test)
function testDateField(logger as Logger) as Boolean {
    var field = new DateField(13);
    Test.assertEqualMessage(field.field_id(), 13, "Field ID should be 13");

    var label = field.cur_label(0.0);
    Test.assertMessage(label.length() > 0, "cur_label should return a non-empty date string");

    return true;
}
