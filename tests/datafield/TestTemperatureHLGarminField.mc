import Toybox.Test;
import Toybox.Lang;
import Toybox.System;
import Toybox.Weather;

(:test)
function testTemperatureHLGarminField(logger as Logger) as Boolean {
    var field = new TemperatureHLGarminField(33);
    Test.assertEqualMessage(field.field_id(), 33, "Field ID should be 33");

    // cur_label without Weather API
    if (!(Toybox has :Weather)) {
        Test.assertEqualMessage(field.cur_label(0.0), "API 3.2.0", "cur_label should return 'API 3.2.0' without Weather API");
    } else {
        var label = field.cur_label(0.0);
        Test.assertMessage(label.length() > 0, "cur_label should return non-empty string when Weather API available");
    }

    return true;
}
