using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time.Gregorian as Time;

import Toybox.Lang;

//! Air Quality Data Field
class AirQualityField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var need_minimal = App.getApp().getProperty("minimal_data");
      var data = App.getApp().getProperty(IQAirClient.DATA_TYPE);

      // Check if data is Invalid, or too old (> 90 minutes)
      if (  (data == null) 
         || (data["clientTs"] == null)
         || (data["clientTs"] < (Time.now().value() - (90 * Time.SECONDS_PER_MINUTE)))) {
         
         // Display error(if any) or no-computed-data
         var error = App.getApp().getProperty(IQAirClient.DATA_TYPE + $.DATA_TYPE_ERROR_SUFFIX);
         if (error != null) {
            // Error
            return Lang.format("ERR $1$", [ error["code"] ]);
         } else {
            // No Data
            if (need_minimal) {
               return "--";
            } else {
               return "AI --";
            }
         }
      } else {
         // display valid data
         var aqius = data["aqius"];

         if (need_minimal) {
            return aqius.toString();
         } else {
            // NOTE: Cannot use "AQI" as "Q" is missing from arc text font!
            return Lang.format("AI $1$", [ aqius ]);
         }
      }
   }

   //! Determines if the current data needs to be updateds
   static function needsDataUpdate() as Boolean {

      // Check data valid and recent (within last 30 minutes)
      // Note: We use clientTs as we do not *know* how often weather data is updated (typically hourly)
      var data = App.AppBase.getProperty(IQAirClient.DATA_TYPE);
      if (  (data == null) 
         || (data["clientTs"] == null)
         || (data["clientTs"] < (Time.now().value() - (30 * Time.SECONDS_PER_MINUTE)))) {
         return true;
      }

      // Check if location changed
      // FIXME: If NearestCity API returns "city" further than 10 miles away, Air Quality API will be continuously requested 
      //        (every 5 mins - potentially burning thru the license api call quota)
      if (  (
               // Current location data valid
               (gLocationLat != null) && (gLocationLon != null)
            ) && (
               // Existing data not for this location.
               // Not a great test, as a degree of longitude varies betwee 69 (equator) and 0 (pole) miles, but simpler than
               // true distance calculation. 0.145 degree of latitude is 10 mile.
               // Note as API is using "Nearest City" we use 10 mile resolution before faster update
               ((gLocationLat - data["lat"]).abs() > 0.145) ||
               ((gLocationLon - data["lon"]).abs() > 0.145)
            )
      ) {
         return true;
      }

      // Data still valid
      return false;
   }
}
