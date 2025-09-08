import Toybox.Test;
import Toybox.Lang;

(:test)
function testBuildFieldObjectMapping(logger as Logger) as Boolean {
    // Heart Rate field
    var hr = buildFieldObject(0);
    Test.assertEqualMessage(hr.field_id(), 0, "Field ID should be 0 for heart rate");
    Test.assertMessage(hr instanceof HRField, "Should return HRField for type 0");

    // Calories field
    var cal = buildFieldObject(2);
    Test.assertEqualMessage(cal.field_id(), 2, "Field ID should be 2 for calories");
    Test.assertMessage(cal instanceof CaloField, "Should return CaloField for type 2");

    // Air Quality field
    var aqi = buildFieldObject(38);
    Test.assertEqualMessage(aqi.field_id(), 38, "Field ID should be 38 for air quality");
    Test.assertMessage(aqi instanceof AirQualityField, "Should return AirQualityField for type 38");

    // Invalid type defaults to EmptyDataField
    var empty = buildFieldObject(-1);
    Test.assertEqualMessage(empty.field_id(), -1, "Field ID should be -1 for invalid type");
    Test.assertMessage(empty instanceof EmptyDataField, "Should return EmptyDataField for invalid type");

    return true;
}
