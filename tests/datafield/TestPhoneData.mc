import Toybox.Lang;
import Toybox.Test;

(:test)
function testNotifyField(logger as Test.Logger) as Boolean {
    var field = new NotifyField(23);

    Test.assertEqualMessage(field.field_id(), 23, "Field ID '" + field.field_id() + "' should be 23");

    // Test that methods execute without throwing exceptions
    try {
        var curLabel = field.cur_label(50.0);
        Test.assertMessage(true, "NotifyField methods executed successfully without exceptions");
    } catch (ex) {
        Test.assertMessage(false, "NotifyField methods threw exception: " + ex.getErrorMessage());
    }

    return true;
}

(:test)
function testPhoneField(logger as Test.Logger) as Boolean {
    var field = new PhoneField(24);

    Test.assertEqualMessage(field.field_id(), 24, "Field ID '" + field.field_id() + "' should be 24");

    // Test that methods execute without throwing exceptions
    try {
        var curLabel = field.cur_label(50.0);
        Test.assertMessage(true, "PhoneField methods executed successfully without exceptions");
    } catch (ex) {
        Test.assertMessage(false, "PhoneField methods threw exception: " + ex.getErrorMessage());
    }

    return true;
}

(:test)
function testGroupNotiField(logger as Test.Logger) as Boolean {
    var field = new GroupNotiField(25);

    Test.assertEqualMessage(field.field_id(), 25, "Field ID '" + field.field_id() + "' should be 25");

    // Test that methods execute without throwing exceptions
    try {
        var curLabel = field.cur_label(50.0);
        Test.assertMessage(true, "GroupNotiField methods executed successfully without exceptions");
    } catch (ex) {
        Test.assertMessage(false, "GroupNotiField methods threw exception: " + ex.getErrorMessage());
    }

    return true;
}
