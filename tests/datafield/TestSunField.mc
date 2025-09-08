import Toybox.Test;
import Toybox.Lang;

(:test)
function testSunField(logger as Logger) as Boolean {
    var field = new SunField(14);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 14, "Field ID should be 14");

    // cur_label when no location should return 'SUN --'
    Test.assertEqualMessage(field.cur_label(0.0), "SUN --", "cur_label should return 'SUN --' when location unset");

    return true;
}
