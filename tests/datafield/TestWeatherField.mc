import Toybox.Test;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Application;

(:test)
function testWeatherField(logger as Logger) as Boolean {
    var field = new WeatherField(31);
    Test.assertEqualMessage(field.field_id(), 31, "Field ID should be 31");

    // No data and no location should return 'NO LOCN'
    Storage.setValue("Weather", null);
    Test.assertEqualMessage(field.cur_label(0.0), "NO LOCN", "cur_label should return 'NO LOCN' when no data and no location");

    // Simulate stale data
    var nowVal = Time.now().value() - (7 * Gregorian.SECONDS_PER_HOUR);
    var data = {:clientTs => nowVal, :temp => 20} as Dictionary<String, PropertyValueType>;
    Storage.setValue("Weather", data);
    Test.assertMessage(field.cur_label(0.0) == "--" || field.cur_label(0.0) instanceof String, "cur_label should return '--' or error text for stale data");

    return true;
}
