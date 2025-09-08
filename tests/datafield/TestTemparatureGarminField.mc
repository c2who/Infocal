import Toybox.Test;
import Toybox.Lang;
import Toybox.System;
import Toybox.Weather;

(:test)
function testTemparatureGarminField(logger as Logger) as Boolean {
    var field = new TemparatureGarminField(32);
    // Field ID
    Test.assertEqualMessage(field.field_id(), 32, "Field ID should be 32");

    // cur_label should return a non-empty string without throwing
    var label = field.cur_label(0.0);
    Test.assertMessage(label instanceof String, "cur_label should return a String");
    Test.assertMessage(label.length() > 0, "cur_label should return a non-empty string");

    return true;
}
