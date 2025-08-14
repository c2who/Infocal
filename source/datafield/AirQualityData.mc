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
         var error = App.getApp().getProperty(IQAirClient.DATA_TYPE + Constants.DATA_TYPE_ERROR_SUFFIX);
         if (error != null) {
            // Error
            return BaseClientHelper.getCommunicationsErrorCodeText(error["code"]);
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

}
