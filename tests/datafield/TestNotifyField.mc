import Toybox.Test;
import Toybox.Lang;
import Toybox.System;

(:test)
function testNotifyField(logger as Logger) as Boolean {
    var field = new NotifyField(22);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 22, "Field ID should be 22");

    // cur_label should format notification count
    var label = field.cur_label(2.0);
    // Expect prefix "NOTIF "
    Test.assertMessage(label.equals("NOTIF 2"), "cur_label should equal 'NOTIF '");

    return true;
}
