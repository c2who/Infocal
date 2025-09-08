import Toybox.Test;
import Toybox.Lang;

(:test)
function testTimeToRecoveryField(logger as Logger) as Boolean {
    var field = new TimeToRecoveryField(36);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 36, "Field ID should be 36");

    // max_val should be 96.0
    Test.assertEqualMessage(field.max_val(), 96.0, "max_val should return 96.0");

    // cur_val returns -1.0 or non-negative
    var curVal = field.cur_val();
    Test.assertMessage(curVal >= -1.0, "cur_val should be >= -1.0");

    // cur_label boundary and normal
    Test.assertEqualMessage(field.cur_label(-1.0), "--", "cur_label should return '--' when cur_val < 0");
    Test.assertEqualMessage(field.cur_label(5.0), "RT 5H", "cur_label should format 'RT 5H' when cur_val >= 0");

    // bar_data
    Test.assertEqualMessage(field.bar_data(), true, "bar_data should be true");

    return true;
}
