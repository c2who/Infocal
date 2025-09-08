import Toybox.Test;
import Toybox.Lang;
import Toybox.System;
import Toybox.Weather;

(:test)
function testPrecipitationGarminField(logger as Logger) as Boolean {
    var field = new PrecipitationGarminField(35);
    Test.assertEqualMessage(field.field_id(), 35, "Field ID should be 35");

    var label = field.cur_label(0.0);
    Test.assertMessage(label instanceof String, "cur_label should return a String");
    Test.assertMessage(label.length() > 0, "cur_label should not be empty");

    return true;
}
