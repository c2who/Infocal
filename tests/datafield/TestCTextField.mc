import Toybox.Test;
import Toybox.Lang;

(:test)
function testCTextField(logger as Logger) as Boolean {
    var field = new CTextField(24);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 24, "Field ID should be 24");

    // cur_label returns a string
    var label = field.cur_label(0.0); // FIXME
    Test.assertMessage(label instanceof String, "cur_label should return a String");
    Test.assertMessage(label.length() > 0, "cur_label should return a non-empty string");

    return true;
}
