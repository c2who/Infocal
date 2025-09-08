import Toybox.Test;
import Toybox.Lang;
import Toybox.System;
import Toybox.ActivityMonitor;
import Toybox.Time;
import Toybox.Time.Gregorian;

(:test)
function testWeekDistanceField(logger as Logger) as Boolean {
    var field = new WeekDistanceField(38);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 38, "Field ID should be 38");

    // cur_val and max_val should be non-negative
    Test.assertMessage(field.cur_val() >= 0.0, "cur_val should be non-negative");
    Test.assertMessage(field.max_val() >= 0.0, "max_val should be non-negative");

    // cur_label returns non-empty string
    var label = field.cur_label(0.0);
    Test.assertMessage(label.length() > 0, "cur_label should return a non-empty string");

    // bar_data
    Test.assertEqualMessage(field.bar_data(), true, "bar_data should be true");

    return true;
}
