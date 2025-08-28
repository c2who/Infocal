using Toybox.Background;
using Toybox.Communications;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;

import Toybox.Application;
import Toybox.Lang;

//! Base (Background) Client
//!
//! @note Where possible, code is placed in the foreground client, to avoid
//! bloating the background service memory usage.
(:background)
class BaseClient {
   //! Consumer callback for returning formatted data
   protected var _callback as (Method(type as String, responseCode as Number, data as Dictionary<String, PropertyValueType>) as Void)?;

   //! Public entry method to make background request to get data from remote service
   //! @param  callback    Consumer callback for returning formatted data
   //! @note   Override in concrete class to build web request(s)
   public function requestData(cb as (Method(type as String, responseCode as Number, data as Dictionary<String, PropertyValueType>) as Void)) as Void {
      // Save callback method
      self._callback = cb;
   }

   //! Make HTTP request (over phone bluetooth connection)
   //!
   //! @see https://developer.garmin.com/connect-iq/api-docs/Toybox/Communications.html#makeWebRequest-instance_function
   protected function makeWebRequest(url, params, callback) as Void {
      var options = {
         :method => Communications.HTTP_REQUEST_METHOD_GET,
         :headers => {
            "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
         },
         :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      };

      Communications.makeWebRequest(url, params, options, callback);
   }
}

//! Base Client (Foreground) Helper
//!
//! @note Standard data filed names should be as follows:
//!         "clientTs"    Client response time
//!         "code"        HTTP response code
class BaseClientHelper {
   // Defaults
   private static var _max_retries = 3;
   private static var _retry_backoff_minutes = 30;

   //! Determines if the current data needs to be updated
   //! @internal This method _must_ be called every minute to avoid missing the retry remain=0 roll-over
   public static function calcNeedsDataUpdate(type as String, update_interval_secs as Number) as Boolean {
      // Check data valid and recent (within last 30 minutes)
      // Note: We use clientTs as we do not *know* how often weather data is updated (typically hourly)
      var data = Storage.getValue(type) as Dictionary<String, Number>;
      var error = Storage.getValue(type + Globals.DATA_TYPE_ERROR_SUFFIX);
      var retries = Storage.getValue(type + Globals.DATA_TYPE_RETRIES_SUFFIX);

      // Find the last data response time (valid or error)
      var lastTime = data != null ? data["clientTs"] : error != null ? error["clientTs"] : null;

      if (lastTime == null) {
         // new system, no data is valid
         return true;
      } else if (retries != null && retries > _max_retries) {
         // FIXED: If API is not responding after retries, back off (retry every 30 minutes)
         // Note: Calculation must be performed in minutes (not seconds) as we only evaluate this every minute
         var remain = ((Time.now().value() - lastTime) / Gregorian.SECONDS_PER_MINUTE) % _retry_backoff_minutes;
         return remain == 0;
      } else if (data == null || data["clientTs"] < Time.now().value() - update_interval_secs) {
         // (No Valid data) or (Valid Data age is > update interval)
         return true;
      } else {
         // Data still valid
         return false;
      }
   }

   //! Persist (store) the data received from a client
   public static function storeData(data as Dictionary<String, Number>) as Void {
      var responseCdoe = data["code"];
      var type = data["type"];
      data.put("clientTs", Time.now().value());

      if (responseCdoe == 200) {
         // Valid data
         Storage.setValue(type, data);
         Storage.deleteValue(type + Globals.DATA_TYPE_ERROR_SUFFIX);
         Storage.deleteValue(type + Globals.DATA_TYPE_RETRIES_SUFFIX);
      } else {
         // return error to the caller, and update retries count
         var retries = Storage.getValue(type + Globals.DATA_TYPE_RETRIES_SUFFIX);
         retries = retries == null ? 1 : retries + 1;

         Storage.setValue(type + Globals.DATA_TYPE_ERROR_SUFFIX, data);
         Storage.setValue(type + Globals.DATA_TYPE_RETRIES_SUFFIX, retries);
      }
   }

   //! Decode the makeWebRequest callback responseCode.
   //! @param  responseCode The server response code or a BLE_* error type
   //!
   //! @see https://developer.garmin.com/connect-iq/api-docs/Toybox/Communications.html
   public static function getCommunicationsErrorCodeText(responseCode as Number) as String {
      // Fixed: Enduro throws unhandled exception (Enduro 28.02, Venu 2 19.05)
      try {
         switch (responseCode.toNumber()) {
            case 401: // Unauthorized
            case 403: // Forbidden
            case 429: // Too Many Requests (often due to api key quota)
               return "API KEY";

            default:
               return Lang.format("ERR $1$", [responseCode]);
         }
      } catch (ex) {
         debug_print(:exception, "ex: $1$", ex.getErrorMessage());
         return "ERR";
      }
   }
}
