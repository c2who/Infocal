import Toybox.Test;
import Toybox.ActivityMonitor;
import Toybox.System;
import Toybox.Lang;

(:test)
function testDistanceField(logger as Logger) as Boolean {
    var field = new DistanceField(17);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 17, "Field ID should be 17");

    // Test max_val
    Test.assertEqualMessage(field.max_val(), 300000.0, "max_val should return 300000.0");

    // Test cur_val returns non-negative
    var curVal = field.cur_val();
    Test.assertMessage(curVal >= 0.0, "cur_val should be non-negative");

    // Test max_label formats with 'K'
    var maxLabel = field.max_label(200000.0);
    Test.assertMessage(maxLabel.equals("200000K"), "max_label should equal '200000K'");

    // Test cur_label formats with 'K'
    var curLabel = field.cur_label(150000.0);
    Test.assertMessage(curLabel.equals("150000K"), "cur_label should equal '150000K'");

    // Test cur_label returns non-empty string
    var label = field.cur_label(150000.0);
    Test.assertMessage(label.length() > 0, "cur_label should return a non-empty string");

    return true;
}
