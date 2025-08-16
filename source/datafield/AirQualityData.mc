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
      var data = App.getApp().getProperty(IQAirClient.DATA_TYPE);

      // Check if data is Invalid, or too old (> 360 minutes (6 hours))
      if (  (data == null)
         || (data["clientTs"] == null)
         || (data["clientTs"] < (Time.now().value() - (360 * Time.SECONDS_PER_MINUTE)))) {

         // Display error(if any) or no-computed-data
         var error = App.getApp().getProperty(IQAirClient.DATA_TYPE + Constants.DATA_TYPE_ERROR_SUFFIX);
         if (error != null) {
            // Error
            return BaseClientHelper.getCommunicationsErrorCodeText(error["code"]);
         } else {
            // No Data
            return "AI --";
         }
      } else {
         // display valid data
         var aqius = data["aqius"];

         // FIXME: Cannot use "AQI" as "Q" is missing from arc text fonts!
         return Lang.format("AI $1$", [ aqius ]);
      }
   }
}
