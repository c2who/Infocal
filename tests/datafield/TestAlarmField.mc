import Toybox.Test;
import Toybox.Lang;
import Toybox.System;

(:test)
function testAlarmField(logger as Logger) as Boolean {
    var field = new AlarmField(5);
    // Field ID
    Test.assertEqualMessage(field.field_id(), 5, "Field ID should be 5");

    // cur_label should not throw and return a non-empty string
    var label = field.cur_label(0.0);
    Test.assertMessage(label instanceof String, "cur_label should return a String");
    Test.assertMessage(label.length() > 0, "cur_label should return a non-empty string");

    // label should start with 'ALAR'
    Test.assertMessage(label.equals("ALAR"), "cur_label should start with 'ALAR'");

    return true;
}
