using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;

import Toybox.Application;
import Toybox.Lang;

//! Air Quality Data Field
class AirQualityField extends BaseDataField {

   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var data = Application.getApp().getProperty(IQAirClient.DATA_TYPE) as Dictionary<String, PropertyValueType>;

      // Check if data is Invalid, or too old (> 360 minutes (6 hours))
      if (  (data == null)
         || (data.get("clientTs") == null)
         || (data["clientTs"] < (Time.now().value() - (360 * Gregorian.SECONDS_PER_MINUTE)))) {

         // Display error(if any) or no-computed-data
         var error = Application.getApp().getProperty(IQAirClient.DATA_TYPE + Globals.DATA_TYPE_ERROR_SUFFIX) as Dictionary<String, PropertyValueType>;
         if (error != null) {
            var responseCode = error.get("code") as Number;
            return BaseClientHelper.getCommunicationsErrorCodeText(responseCode);
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
