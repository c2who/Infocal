import Toybox.Lang;
import Toybox.Test;


(:test)
function testSolarIntensityField(logger as Logger) as Boolean {

    var field = new SolarIntensityField(41);

    Test.assertEqualMessage(field.field_id(), 41, "Field ID '" + field.field_id() + "' should be 41");
    Test.assertEqualMessage(field.max_val(), 100.0, "Max value '" + field.max_val() + "' should be 100.0");
    Test.assertEqualMessage(field.min_val(), 0.0, "Min value '" + field.min_val() + "' should be 0.0");
    Test.assertEqualMessage(field.min_label(field.min_val()), "0", "Min label '" + field.min_label(field.min_val()) + "' should be '0'");
    Test.assertEqualMessage(field.max_label(field.max_val()), "100", "Max label '" + field.max_label(field.max_val()) + "' should be '100'");
    Test.assertEqualMessage(field.bar_data(), true, "Bar data '" + field.bar_data() + "' should be true");

    var curValue = field.cur_val();
    Test.assertMessage(curValue >= -1.0 and curValue <= 100.0, "Current value '" + curValue + "' should be between -1.0 and 100.0");
    if (curValue < 0.0) {
        Test.assertEqualMessage(field.cur_label(curValue), "--", "Current label '" + field.cur_label(curValue) + "' should be '--' for invalid value");
    } else {
        Test.assertEqualMessage(field.cur_label(curValue), Lang.format("SI $1$%", [curValue.format("%d")]),
          "Current label '" + field.cur_label(curValue) + "' should match formatted value");
    }
    return true;
}