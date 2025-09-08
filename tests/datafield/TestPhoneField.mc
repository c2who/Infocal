import Toybox.Test;
import Toybox.Lang;
import Toybox.System;

(:test)
function testPhoneField(logger as Logger) as Boolean {
    var field = new PhoneField(23);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 23, "Field ID should be 23");

    // cur_label should return 'CONN' or '--'
    var label = field.cur_label(0.0);
    Test.assertMessage(label == "CONN" or label == "--", "cur_label should be 'CONN' or '--'");

    return true;
}
