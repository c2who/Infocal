import Toybox.Application;
import Toybox.Lang;
import Toybox.Test;
import Toybox.Time;

(:test)
function testAirQualityField(logger as Logger) as Boolean {
    var field = new AirQualityField(4);

    // No data scenario: no data stored
    Storage.setValue(IQAirClient.DATA_TYPE, null);
    Storage.setValue(IQAirClient.DATA_TYPE + Globals.DATA_TYPE_ERROR_SUFFIX, null);
    Test.assertEqualMessage(field.cur_label(0.0), "AI --", "cur_label should return 'AI --' when no data");

    // Valid data scenario: recent data with aqius
    var timestamp = Time.now().value() as Number;
    var data = {:clientTs => timestamp, :aqius => 42} as Dictionary<String, PropertyValueType>;
    Storage.setValue(IQAirClient.DATA_TYPE, data);
    var label = field.cur_label(0.0);
    Test.assertEqualMessage(label, "AI 42", "cur_label should return 'AI 42' for valid data");

    return true;
}
