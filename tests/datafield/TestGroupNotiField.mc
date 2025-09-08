import Toybox.Application;
import Toybox.Test;
import Toybox.Lang;
import Toybox.System;

(:test)
function testGroupNotiField(logger as Logger) as Boolean {
    var field = new GroupNotiField(24);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 24, "Field ID should be 24");

    // cur_label when phone not connected ends with '-D'
    Storage.setValue("phoneConnected", false);
    Storage.setValue("notificationCount", 3);
    Storage.setValue("alarmCount", 2);
    var label = field.cur_label(0.0);
    Test.assertMessage(label.equals("-D"), "cur_label should end with '-D' when phoneDisconnected");

    // cur_label when phone connected ends with '-C'
    Storage.setValue("phoneConnected", true);
    label = field.cur_label(0.0);
    Test.assertMessage(label.equals("-C"), "cur_label should end with '-C' when phoneConnected");

    return true;
}
