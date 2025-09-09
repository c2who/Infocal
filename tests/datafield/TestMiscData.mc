import Toybox.Lang;
import Toybox.Test;

(:test)
function testCTextField(logger as Test.Logger) as Boolean {
    var field = new CTextField(21);

    Test.assertEqualMessage(field.field_id(), 21, "Field ID '" + field.field_id() + "' should be 21");

    // Test that methods execute without throwing exceptions
    try {
        var curLabel = field.cur_label(50.0);
        Test.assertMessage(true, "CTextField methods executed successfully without exceptions");
    } catch (ex) {
        Test.assertMessage(false, "CTextField methods threw exception: " + ex.getErrorMessage());
    }

    return true;
}
