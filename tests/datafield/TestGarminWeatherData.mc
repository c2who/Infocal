import Toybox.Lang;
import Toybox.Test;

(:test)
function testTemparatureGarminField(logger as Test.Logger) as Boolean {
    var field = new TemparatureGarminField(16);

    Test.assertEqualMessage(field.field_id(), 16, "Field ID '" + field.field_id() + "' should be 16");

    // Test that methods execute without throwing exceptions
    try {
        var curLabel = field.cur_label(50.0);
        Test.assertMessage(true, "TemparatureGarminField methods executed successfully without exceptions");
    } catch (ex) {
        Test.assertMessage(false, "TemparatureGarminField methods threw exception: " + ex.getErrorMessage());
    }

    return true;
}

(:test)
function testTemperatureHLGarminField(logger as Test.Logger) as Boolean {
    var field = new TemperatureHLGarminField(17);

    Test.assertEqualMessage(field.field_id(), 17, "Field ID '" + field.field_id() + "' should be 17");

    // Test that methods execute without throwing exceptions
    try {
        var curLabel = field.cur_label(50.0);
        Test.assertMessage(true, "TemperatureHLGarminField methods executed successfully without exceptions");
    } catch (ex) {
        Test.assertMessage(false, "TemperatureHLGarminField methods threw exception: " + ex.getErrorMessage());
    }

    return true;
}

(:test)
function testWeatherGarminField(logger as Test.Logger) as Boolean {
    var field = new WeatherGarminField(18);

    Test.assertEqualMessage(field.field_id(), 18, "Field ID '" + field.field_id() + "' should be 18");

    // Test that methods execute without throwing exceptions
    try {
        var curLabel = field.cur_label(50.0);
        Test.assertMessage(true, "WeatherGarminField methods executed successfully without exceptions");
    } catch (ex) {
        Test.assertMessage(false, "WeatherGarminField methods threw exception: " + ex.getErrorMessage());
    }

    return true;
}

(:test)
function testPrecipitationGarminField(logger as Test.Logger) as Boolean {
    var field = new PrecipitationGarminField(19);

    Test.assertEqualMessage(field.field_id(), 19, "Field ID '" + field.field_id() + "' should be 19");

    // Test that methods execute without throwing exceptions
    try {
        var curLabel = field.cur_label(50.0);
        Test.assertMessage(true, "PrecipitationGarminField methods executed successfully without exceptions");
    } catch (ex) {
        Test.assertMessage(false, "PrecipitationGarminField methods threw exception: " + ex.getErrorMessage());
    }

    return true;
}
