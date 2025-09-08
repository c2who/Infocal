import Toybox.Test;
import Toybox.Lang;
import Toybox.System;
import Toybox.Application;

(:test)
function testTemparatureOutField(logger as Logger) as Boolean {
    var field = new TemparatureOutField(30);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 30, "Field ID should be 30");

    // No weather data scenario
    Storage.setValue("Weather", null);
    Test.assertEqualMessage(field.cur_label(0.0), "--", "cur_label should return '--' when no data in minimal mode");

    // With weather data
    var weather = {:temp => 25} as Dictionary<String, PropertyValueType>;
    Storage.setValue("Weather", weather);
    var label = field.cur_label(0.0);
    Test.assertMessage(label.equals("25"), "cur_label should include temperature value when data present");

    return true;
}
