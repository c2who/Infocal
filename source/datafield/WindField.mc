import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

/* WIND */
class WindField extends BaseDataField {

   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      //var need_minimal = Properties.getValue("minimal_data");
      var weather_data = Storage.getValue("Weather") as Dictionary<String, PropertyValueType>?;
      var wind_direction_mapper = [
         "N",
         "NNE",
         "NE",
         "ENE",
         "E",
         "ESE",
         "SE",
         "SSE",
         "S",
         "SSW",
         "SW",
         "WSW",
         "W",
         "WNW",
         "NW",
         "NNW",
      ] as Array<String>;

      if (weather_data != null) {
         var settings = System.getDeviceSettings();
         var speed = weather_data["wind_speed"] * 3.6; // kph
         var direct = weather_data["wind_direct"];

         var direct_corrected = direct + 11.25; // move degrees to int spaces (North from 348.75-11.25 to 360(min)-22.5(max))
         direct_corrected =
            direct_corrected < 360 ? direct_corrected : direct_corrected - 360; // move North from 360-371.25 back to 0-11.25 (final result is North 0(min)-22.5(max))
         var direct_idx = (direct_corrected / 22.5).toNumber(); // now calculate direction array position: int([0-359.99]/22.5) will result in 0-15 (correct array positions)

         var directLabel = wind_direction_mapper[direct_idx % wind_direction_mapper.size()];
         var unit = "k";
         if (settings.distanceUnits == System.UNIT_STATUTE) {
            speed *= 0.621371;
            unit = "m";
         }
         return directLabel + " " + speed.format("%0.1f") + unit;
      } else {
         return "--";
      }
   }
}
