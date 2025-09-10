import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;

/* WEATHER */
class WeatherField extends BaseDataField {

   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function cur_icon() as Char? {
      var data = Storage.getValue(OpenWeatherClient.DATA_TYPE) as Dictionary<String, PropertyValueType>?;
      var weather_icon_mapper  = {
         "01d" => 61453.toChar(), // "",
         "02d" => 61442.toChar(), // "",
         "03d" => 61505.toChar(), // "",
         "04d" => 61459.toChar(), // "",
         "09d" => 61466.toChar(), // "",
         "10d" => 61448.toChar(), // "",
         "11d" => 61470.toChar(), // "",
         "13d" => 61467.toChar(), // "",
         "50d" => 61539.toChar(), // "",

         "01n" => 61486.toChar(), // "",
         "02n" => 61574.toChar(), // "",
         "03n" => 61505.toChar(), // "",
         "04n" => 61459.toChar(), // "",
         "09n" => 61466.toChar(), // "",
         "10n" => 61480.toChar(), // "",
         "11n" => 61470.toChar(), // "",
         "13n" => 61467.toChar(), // "",
         "50n" => 61539.toChar(), // "",
      } as Dictionary<String, Char>;

      if (BaseClientHelper.isValidData(data, 6 * Gregorian.SECONDS_PER_HOUR)) {
         return weather_icon_mapper[ data["icon"] ];
      } else {
         return null;
      }
   }

   function cur_label(value) as String {
      // WEATHER
      var data = Storage.getValue(OpenWeatherClient.DATA_TYPE) as Dictionary<String, PropertyValueType>?;

      // Check if data valid and not too old (<= 6 hours)
      if (BaseClientHelper.isValidData(data, 6 * Gregorian.SECONDS_PER_HOUR)) {

         var settings = System.getDeviceSettings();
         var temp = data["temp"];
         var unit = "°C";

         // Convert to Farenheit: ensure floating point division.
         if (settings.temperatureUnits == System.UNIT_STATUTE) {
            temp = temp * (9.0 / 5.0) + 32;
            unit = "°F";
         }
         value = temp.format("%d") + unit;

         var description = data.get("des");
         if (description != null) {
            return description + " " + value;
         } else {
            return value;
         }
      } else {
         // Display error(if any) or no-computed-data
         var error = Storage.getValue(OpenWeatherClient.DATA_TYPE + Globals.DATA_TYPE_ERROR_SUFFIX) as Dictionary<String, PropertyValueType>?;

         if (gLocation == null) {
            return "NO LOCN";
         } else if (error != null) {
            var responseCode = error.get("code") as Number;
            return BaseClientHelper.getCommunicationsErrorCodeText(responseCode);
         } else {
            // No Data
            return "--";
         }
      }
   }
}
