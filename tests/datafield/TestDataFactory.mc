import Toybox.Lang;
import Toybox.Test;

(:test)
function testDataFactory(logger as Test.Logger) as Boolean {
    // Test buildFieldObject function with several known field types
    var hrField = buildFieldObject(FIELD_TYPE_HEART_RATE);
    Test.assertMessage(hrField != null, "Heart Rate field should be created");

    var batteryField = buildFieldObject(FIELD_TYPE_BATTERY);
    Test.assertMessage(batteryField != null, "Battery field should be created");

    var caloField = buildFieldObject(FIELD_TYPE_CALORIES);
    Test.assertMessage(caloField != null, "Calorie field should be created");

    // Test BaseDataField
    var baseField = new BaseDataField(42);
    Test.assertEqualMessage(baseField.field_id(), 42, "Base field ID should be 42");
    Test.assertEqualMessage(baseField.min_val(), 0.0, "Base field min_val should be 0.0");
    Test.assertEqualMessage(baseField.max_val(), 100.0, "Base field max_val should be 100.0");
    Test.assertEqualMessage(baseField.bar_data(), false, "Base field bar_data should be false");

    // Test EmptyDataField
    var emptyField = new EmptyDataField(99);
    Test.assertEqualMessage(emptyField.field_id(), 99, "Empty field ID should be 99");
    Test.assertEqualMessage(emptyField.need_draw(), false, "Empty field need_draw should be false");

    return true;
}
