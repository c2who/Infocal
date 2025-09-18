import Toybox.Lang;
import Toybox.Test;

(:test)
function testCaloField(logger as Test.Logger) as Boolean {
    var field = new CaloField(10);

    Test.assertEqualMessage(field.field_id(), 10, "Field ID should be 10");

    // Test methods execute without throwing exceptions
    var maxValue = field.max_val();
    var curValue = field.cur_val();
    var maxLabel = field.max_label(100.0);
    var curLabel = field.cur_label(50.0);
    var barData = field.bar_data();

    // Basic validation - just ensure the test ran without crashing
    Test.assertMessage(true, "CaloField methods executed successfully");

    return true;
}
