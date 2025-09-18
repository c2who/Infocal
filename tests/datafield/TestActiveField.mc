import Toybox.Lang;
import Toybox.Test;

(:test)
function testActiveField(logger as Test.Logger) as Boolean {
    var field = new ActiveField(1);

    Test.assertEqualMessage(field.field_id(), 1, "Field ID '" + field.field_id() + "' should be 1");

    var maxValue = field.max_val();
    var curValue = field.cur_val();
    var maxLabel = field.max_label(100.0);
    var curLabel = field.cur_label(50.0);
    var barData = field.bar_data();

    Test.assertMessage((maxValue != null) as Boolean, ("Max value '" + maxValue + "' should not be null") as String);
    Test.assertMessage((curValue != null) as Boolean, ("Current value '" + curValue + "' should not be null") as String);
    Test.assertMessage((maxLabel != null) as Boolean, ("Max label '" + maxLabel + "' should not be null") as String);
    Test.assertMessage((curLabel != null) as Boolean, ("Current label '" + curLabel + "' should not be null") as String);
    Test.assertEqualMessage(barData as Boolean, true, ("Bar data '" + barData + "' should be true") as String);

    return true;
}
