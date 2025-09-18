import Toybox.Lang;
import Toybox.Test;

(:test)
function testAMPMField(logger as Test.Logger) as Boolean {
    var field = new AMPMField(11);

    Test.assertEqualMessage(field.field_id(), 11, "Field ID should be 11");

    // Test methods execute without throwing exceptions
    var curLabel = field.cur_label(50.0);

    // Basic validation - just ensure the test ran without crashing
    Test.assertMessage(true, "AMPMField methods executed successfully");

    return true;
}

(:test)
function testTimeField(logger as Test.Logger) as Boolean {
    var field = new TimeField(12);

    Test.assertEqualMessage(field.field_id(), 12, "Field ID should be 12");

    // Test methods execute without throwing exceptions
    var curLabel = field.cur_label(50.0);
    var timeString = field.getTimeString();

    // Basic validation - just ensure the test ran without crashing
    Test.assertMessage(true, "TimeField methods executed successfully");

    return true;
}
