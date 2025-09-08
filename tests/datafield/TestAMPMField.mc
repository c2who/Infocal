import Toybox.Test;
import Toybox.Lang;
import Toybox.Lang;
import Toybox.System;

(:test)
function testAMPMField(logger as Logger) as Boolean {
    var field = new AMPMField(11);
    Test.assertEqualMessage(field.field_id(), 11, "Field ID should be 11");

    var label = field.cur_label(0.0);
    Test.assertMessage(label == "am" or label == "pm", "cur_label should return 'am' or 'pm'");

    return true;
}
