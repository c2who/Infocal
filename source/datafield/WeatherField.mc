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

   function cur_icon() {
      var weather_data = Storage.getValue("Weather") as Dictionary<String, PropertyValueType>?;
      var weather_icon_mapper  = {
         "01d" => "",
         "02d" => "",
         "03d" => "",
         "04d" => "",
         "09d" => "",
         "10d" => "",
         "11d" => "",
         "13d" => "",
         "50d" => "",

         "01n" => "",
         "02n" => "",
         "03n" => "",
         "04n" => "",
         "09n" => "",
         "10n" => "",
         "11n" => "",
         "13n" => "",
         "50n" => "",
      } as Dictionary<String, String>;

      if (weather_data != null) {
         return weather_icon_mapper[weather_data["icon"]];
      } else {
         return null;
      }
   }

   function cur_label(value) as String {
      // WEATHER
      //var need_minimal = Properties.getValue("minimal_data");
      var data = Storage.getValue(OpenWeatherClient.DATA_TYPE) as Dictionary<String, PropertyValueType>?;

      // Check if data is Invalid, or too old (> 6 hours)
      if (  (data == null)
         || (data.get("clientTs") == null)
         || (data["clientTs"] < (Time.now().value() - (6 * Gregorian.SECONDS_PER_HOUR)))) {

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
      } else {
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
      }
   }
}
