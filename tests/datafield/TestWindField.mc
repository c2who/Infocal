import Toybox.Test;
import Toybox.Lang;
import Toybox.System;
import Toybox.Application;

(:test)
function testWindField(logger as Logger) as Boolean {
    var field = new WindField(39);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 39, "Field ID should be 39");

    // cur_label without data should return '--'
    Storage.setValue("Weather", null);
    Test.assertEqualMessage(field.cur_label(0.0), "--", "cur_label should return '--' when no data");

    // With dummy data
    var weather = {:wind_speed => 10.0, :wind_direct => 90.0} as Dictionary<String, PropertyValueType>;
    Storage.setValue("Weather", weather);
    var label = field.cur_label(0.0);
    Test.assertMessage(label.length() > 0, "cur_label should return non-empty string when data present");

    return true;
}
