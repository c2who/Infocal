using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;

import Toybox.Application;
import Toybox.Lang;

//! Air Quality Data Field
class AirQualityField extends BaseDataField {

   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var data = Storage.getValue(IQAirClient.DATA_TYPE) as Dictionary<String, PropertyValueType>;

      // Check if data is Invalid, or too old (> 6 hours)
      if (  (data == null)
         || (data.get("clientTs") == null)
         || (data["clientTs"] < (Time.now().value() - (6 * Gregorian.SECONDS_PER_HOUR)))) {

         // Display error(if any) or no-computed-data
         var error = Storage.getValue(IQAirClient.DATA_TYPE + Globals.DATA_TYPE_ERROR_SUFFIX) as Dictionary<String, PropertyValueType>;
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
