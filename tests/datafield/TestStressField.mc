import Toybox.Test;
import Toybox.Lang;

(:test)
function testStressField(logger as Logger) as Boolean {
    var field = new StressField(27);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 27, "Field ID should be 27");

    // min_val and max_val
    Test.assertEqualMessage(field.min_val(), 0.0, "min_val should return 0.0");
    Test.assertEqualMessage(field.max_val(), 100.0, "max_val should return 100.0");

    // cur_val non-negative
    Test.assertMessage(field.cur_val() >= 0.0, "cur_val should be non-negative");

    // cur_label boundary and normal
    Test.assertEqualMessage(field.cur_label(1.0), "STRESS --", "cur_label should return 'STRESS --' when value <= 1");
    Test.assertEqualMessage(field.cur_label(50.0), "STRESS 50", "cur_label should return 'STRESS 50' for normal values");

    // bar_data
    Test.assertEqualMessage(field.bar_data(), true, "bar_data should be true");

    return true;
}
