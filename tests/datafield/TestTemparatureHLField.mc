import Toybox.Test;
import Toybox.Lang;
import Toybox.System;
import Toybox.Application;

(:test)
function testTemparatureHLField(logger as Logger) as Boolean {
    var field = new TemparatureHLField(29);
    Test.assertEqualMessage(field.field_id(), 29, "Field ID should be 29");

    // No weather data scenario
    Storage.setValue("Weather", null);
    Test.assertEqualMessage(field.cur_label(0.0), "--", "cur_label should return '--' when no data in minimal mode");

    // Simulate stored weather data
    var weather = {:temp_min => 10, :temp_max => 20} as Dictionary<String, PropertyValueType>;
    Storage.setValue("Weather", weather);
    // Depending on minimal_data property
    Test.assertMessage(field.cur_label(0.0).length() > 0, "cur_label should return non-empty string when data present");

    return true;
}
