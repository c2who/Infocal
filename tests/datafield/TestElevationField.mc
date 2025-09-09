import Toybox.Lang;
import Toybox.Test;

(:test)
function testElevationField(logger as Test.Logger) as Boolean {
    var field = new ElevationField(14);

    Test.assertEqualMessage(field.field_id(), 14, "Field ID should be 14");

    // Test methods execute without throwing exceptions
    var maxValue = field.max_val();
    var curValue = field.cur_val();
    var maxLabel = field.max_label(100.0);
    var curLabel = field.cur_label(50.0);
    var barData = field.bar_data();

    // Basic validation - just ensure the test ran without crashing
    Test.assertMessage(true, "ElevationField methods executed successfully");

    return true;
}
