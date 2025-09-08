import Toybox.Test;
import Toybox.Lang;
import Toybox.ActivityMonitor;

(:test)
function testCaloField(logger as Logger) as Boolean {
    var field = new CaloField(16);
    Test.assertEqualMessage(field.field_id(), 16, "Field ID should be 16");

    // Test max_val
    Test.assertEqualMessage(field.max_val(), 3000.0, "max_val should return 3000.0");

    // Test cur_val returns a non-negative number
    var curVal = field.cur_val();
    Test.assertMessage(curVal >= 0, "cur_val should return a non-negative number");

    // Test max_label formats value in K correctly
    var maxLabel = field.max_label(1500.0);
    Test.assertMessage(maxLabel instanceof String && maxLabel.equals("1500K"), "max_label equals '1500K' for input 1500.0");

    // Test cur_label returns a string without exception
    var label = field.cur_label(curVal);
    Test.assertMessage(label instanceof String && label.length() > 0, "cur_label should return a non-empty string");

    // Test active_calories returns a non-negative number
    var activeCal = field.active_calories(1000.0);
    Test.assertMessage(activeCal >= 0, "active_calories should return a non-negative number");

    // Test bar_data
    Test.assertEqualMessage(field.bar_data(), true, "bar_data should be true");

    return true;
}
