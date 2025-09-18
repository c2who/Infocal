import Toybox.Lang;
import Toybox.Test;

(:test)
function testMoveField(logger as Test.Logger) as Boolean {
    var field = new MoveField(22);

    Test.assertEqualMessage(field.field_id(), 22, "Field ID '" + field.field_id() + "' should be 22");

    // Test that methods execute without throwing exceptions
    try {
        var maxValue = field.max_val();
        var curValue = field.cur_val();
        var maxLabel = field.max_label(100.0);
        var curLabel = field.cur_label(50.0);
        var barData = field.bar_data();
        Test.assertMessage(true, "MoveField methods executed successfully without exceptions");
    } catch (ex) {
        Test.assertMessage(false, "MoveField methods threw exception: " + ex.getErrorMessage());
    }

    return true;
}
