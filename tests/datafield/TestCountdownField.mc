import Toybox.Application;
import Toybox.Test;
import Toybox.Time;
import Toybox.System;
import Toybox.Lang;

(:test)
function testCountdownField(logger as Logger) as Boolean {
    var field = new CountdownField(15);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 15, "Field ID should be 15");

    // No countdown_date set
    Storage.setValue("countdown_date", null);
    Test.assertEqualMessage(field.cur_label(0.0), "NOT SET", "cur_label should return 'NOT SET' when no date");

    // Set countdown_date to today
    var today = Time.today().value() + System.getClockTime().timeZoneOffset;
    Storage.setValue("countdown_date", today as Number);
    Test.assertEqualMessage(field.cur_label(0.0), "TODAY", "cur_label should return 'TODAY' when date is today");

    return true;
}
