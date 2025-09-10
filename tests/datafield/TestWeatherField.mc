import Toybox.Application;
import Toybox.Lang;
import Toybox.Test;
import Toybox.Time;

(:test)
function testWeatherField(logger as Test.Logger) as Boolean {
    var field = new WeatherField(37);

    Test.assertEqualMessage(field.field_id(), 37, "Field ID '" + field.field_id() + "' should be 37");

    // Create mock data that would pass BaseClientHelper.isValidData check
    var mockData = {
        "temp" => 20,
        "icon" => "01d",
        "des" => "Clear sky",
        "clientTs" => Time.now().value() // Current timestamp to ensure it's valid
    };

    // Store the mock data temporarily
    Storage.setValue(OpenWeatherClient.DATA_TYPE, mockData);

    // Test cur_label method - this field only implements cur_label
    var curLabel = field.cur_label(50.0);
    Test.assertMessage(curLabel != null, "Current label '" + curLabel + "' should not be null");

    // Clean up - remove the test data
    Storage.deleteValue(OpenWeatherClient.DATA_TYPE);

    return true;
}

(:test)
function testWeatherFieldCurIcon(logger as Test.Logger) as Boolean {
    var field = new WeatherField(37);

    // Define expected icon mappings from the weather_icon_mapper
    var expectedIconMappings = {
         "01d" => 61453.toChar(), // "",
         "02d" => 61442.toChar(), // "",
         "03d" => 61505.toChar(), // "",
         "04d" => 61459.toChar(), // "",
         "09d" => 61466.toChar(), // "",
         "10d" => 61448.toChar(), // "",
         "11d" => 61470.toChar(), // "",
         "13d" => 61467.toChar(), // "",
         "50d" => 61539.toChar(), // "",

         "01n" => 61486.toChar(), // "",
         "02n" => 61574.toChar(), // "",
         "03n" => 61505.toChar(), // "",
         "04n" => 61459.toChar(), // "",
         "09n" => 61466.toChar(), // "",
         "10n" => 61480.toChar(), // "",
         "11n" => 61470.toChar(), // "",
         "13n" => 61467.toChar(), // "",
         "50n" => 61539.toChar(), // "",
    } as Dictionary<String, Char>;

    // Define all valid weather icon codes from the weather_icon_mapper
    var validIconCodes = [
        "01d", "02d", "03d", "04d", "09d", "10d", "11d", "13d", "50d",
        "01n", "02n", "03n", "04n", "09n", "10n", "11n", "13n", "50n"
    ];

    // Test each valid icon code
    for (var i = 0; i < validIconCodes.size(); i++) {
        var iconCode = validIconCodes[i];

        // Create mock data that would pass BaseClientHelper.isValidData check
        var mockData = {
            "icon" => iconCode,
            "clientTs" => Time.now().value() // Current timestamp to ensure it's valid
        };

        // Store the mock data temporarily
        Storage.setValue(OpenWeatherClient.DATA_TYPE, mockData);

        // Test that cur_icon returns a valid character for this icon code
        var icon = field.cur_icon();
        Test.assertMessage(icon != null, "Icon should not be null for code '" + iconCode + "'");
        if (icon != null) {
            Test.assertMessage(icon instanceof Char, "Icon should be a Char for code '" + iconCode + "'");

            // Test that the returned icon matches the expected character value
            var expectedIcon = expectedIconMappings[iconCode];
            Test.assertEqualMessage(icon, expectedIcon, "Icon for code '" + iconCode + "' should match expected character value");
        }
    }

    // Clean up - remove the test data
    Storage.deleteValue(OpenWeatherClient.DATA_TYPE);

    // Test that cur_icon returns null when no valid data is available
    var iconWithNoData = field.cur_icon();
    Test.assertMessage(iconWithNoData == null, "Icon should be null when no valid data is available");

    return true;
}
