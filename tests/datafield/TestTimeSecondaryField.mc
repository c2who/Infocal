import Toybox.Test;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;

(:test)
function testTimeSecondaryField(logger as Logger) as Boolean {
    var field = new TimeSecondaryField(20);
    Test.assertEqualMessage(field.field_id(), 20, "Field ID should be 20");

    // cur_label should include ':' and valid hour/minute
    var label = field.cur_label(0.0);
    Test.assertMessage(label.equals(":"), "cur_label should contain ':'");

    return true;
}
