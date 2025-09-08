import Toybox.Test;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;

(:test)
function testTemparatureField(logger as Logger) as Boolean {
    var field = new TemparatureField(28);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 28, "Field ID should be 28");

    // cur_label should return a non-empty string or '--'
    var label = field.cur_label(0.0);
    Test.assertMessage(label instanceof String, "cur_label should return a String");
    Test.assertMessage(label.length() > 0, "cur_label should not be empty");

    return true;
}
