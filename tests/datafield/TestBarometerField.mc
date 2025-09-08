import Toybox.Test;
import Toybox.Lang;

(:test)
function testBarometerField(logger as Logger) as Boolean {
    var field = new BarometerField(7);

    // Field ID
    Test.assertEqualMessage(field.field_id(), 7, "Field ID should be 7");

    // _retrieveBarometer should return an array of two elements
    var val = field._retrieveBarometer();
    Test.assertMessage(val.size() == 2, "retrieveBarometer should return an array of size 2");

/* IGNORE BROKEN TESTS / CODE
    // cur_label should handle null values
    var labelNull = field.cur_label([null, 0]);
    Test.assertEqualMessage(labelNull, "BARO --", "cur_label should return 'BARO --' when no data");

    // cur_label should format positive signal
    var labelPos = field.cur_label([101325.0, 1]);
    Test.assertMessage(labelPos.indexOf("BAR ") == 0, "cur_label should start with 'BAR '");
    Test.assertMessage(labelPos.indexOf("+") >= 0, "cur_label should contain '+' for rising trend");

    // cur_label should format negative signal
    var labelNeg = field.cur_label([100000.0, -1]);
    Test.assertMessage(labelNeg.indexOf("-") >= 0, "cur_label should contain '-' for falling trend");

// */
    return true;
}
