import Toybox.Test;
import Toybox.Lang;
import Toybox.System;
import Toybox.Weather;

(:test)
function testWeatherGarminField(logger as Logger) as Boolean {
    var field = new WeatherGarminField(34);
    Test.assertEqualMessage(field.field_id(), 34, "Field ID should be 34");

    var label = field.cur_label(0.0);
    // Should return a string, not null
    Test.assertMessage(label instanceof String, "cur_label should return a String");
    Test.assertMessage(label.length() > 0, "cur_label should not be empty");

    return true;
}
