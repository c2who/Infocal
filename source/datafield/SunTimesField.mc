import Toybox.Application;
import Toybox.Lang;
import Toybox.Weather;

using Toybox.Position;
using Toybox.System;
using Toybox.Time.Gregorian;

/* SUNRISE/SUNSET */
class SunTimesField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var sun_text = "SUN --";
      if (gLocation != null) {
         var location = new Position.Location({
            :latitude => gLocation[0].toDouble(),
            :longitude => gLocation[1].toDouble(),
            :format => :degrees,
         });
         var sunrise = Weather.getSunrise(location, Time.now());
         var sunset = Weather.getSunset(location, Time.now());

         if (sunrise != null && Time.now().lessThan(sunrise)) {
            // Before sunrise: next event is sunrise.
            sun_text = Lang.format("RISE $1$", [format_time(sunrise)]);
         } else if (sunset != null && Time.now().lessThan(sunset)) {
            // After sunrise, before sunset: next event is sunset.
            sun_text = Lang.format("SET $1$", [format_time(sunset)]);
         } else {
            // After sunset: next event is sunrise (tomorrow).
            var day = new Time.Duration(24 * 60 * 60);
            var sunriseTomorrow = Weather.getSunrise(location, Time.now().add(day));
            sun_text = Lang.format("RISE $1$", [format_time(sunriseTomorrow)]);
         }
      }
      return sun_text;
   }

   function format_time(time as Toybox.Time.Moment) as String {
      var timeInfo = Gregorian.info(time, Time.FORMAT_SHORT);
      return Lang.format("$1$:$2$", [timeInfo.hour.format("%02d"), timeInfo.min.format("%02d")]);
   }
}
