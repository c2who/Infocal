import Toybox.Test;
import Toybox.Lang;
import Toybox.System;

(:test)
function testElevationField(logger as Logger) as Boolean {
    var field = new ElevationField(18);
    Test.assertEqualMessage(field.field_id(), 18, "Field ID should be 18");

    // cur_label without history should return '--' or start with 'ELE '
    var label = field.cur_label(0.0);
    Test.assertMessage(label.equals("--") or label.equals("ELE"), "cur_label should return '--' or start with 'ELE '");

    return true;
}
