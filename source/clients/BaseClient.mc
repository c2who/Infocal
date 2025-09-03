using Toybox.Background;
using Toybox.Communications;
using Toybox.System;
using Toybox.Time;

import Toybox.Application;
import Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Math;

//! Base (Background) Client
//!
//! @note Where possible, code is placed in the foreground client, to avoid
//! bloating the background service memory usage.
(:background)
class BaseClient {
    typedef CommunicationCallbackMethod as Method(responseCode as Number, data as Dictionary?) as Void;
    typedef ClientCallbackMethod as Method(type as String, responseCode as Number, data as Dictionary<PropertyKeyType, PropertyValueType>) as Void;

    //! Consumer callback for returning formatted data
    protected var _callback as ClientCallbackMethod;

    //! Constructor.
    //! @param  callback    Consumer callback for returning formatted data
    function initialize(callback as ClientCallbackMethod) {
        self._callback = callback;
    }

    //! Public entry method to make background request to get data from remote service
    //! @note   Override in concrete class to build web request(s)
    public function requestData() as Void {
        // Override in concrete class
    }

    //! Make HTTP GET request (over phone bluetooth connection)
    //!
    //! @param url      host url
    //! @param params   search parameters, to append to the full url
    //! @param headers  header parameters
    //!
    //! @see https://developer.garmin.com/connect-iq/api-docs/Toybox/Communications.html#makeWebRequest-instance_function
    protected function makeGetRequest(
        url as String,
        params as Dictionary?,
        headers as Dictionary?,
        callback as CommunicationCallbackMethod) as Void {

        // If no headers, assume url encoded request
        if ((headers == null) || (headers.size() == 0)) {
            headers = {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
            };
        }

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => headers as Dictionary<Object,Object>,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
        };
        Communications.makeWebRequest(url, params as Dictionary<Object,Object> or Null, options, callback);
    }

    //! Make HTTP POST request (over phone bluetooth connection)
    //!
    //! @note POST parameters go in the body
    //! @see https://developer.garmin.com/connect-iq/api-docs/Toybox/Communications.html#makeWebRequest-instance_function
    protected function makePostRequest(
        url as String,
        params as Dictionary?,
        headers as Dictionary?,
        callback as CommunicationCallbackMethod) as Void {

        // If no headers, assume url encoded request
        if ((headers == null) || (headers.size() == 0)) {
            headers = {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
            };
        }

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => headers,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
        };

        debug_print(:client, "$1$: params=$2$, options=$3$", [url, params, options]);
        Communications.makeWebRequest(url, params as Dictionary<Object,Object> or Null, options, callback);
   }

   protected function encodeParams(params as Dictionary<String,String>) as String {
    var str = "?";
    var keys =  params.keys();
    for (var i=0; i < keys.size(); i++) {
        var key = keys[i];
        var val = params.get(key) as String;
        var join = (i==0) ? "" : "&";
        str += join + Communications.encodeURL(key) + "=" + Communications.encodeURL(val);
    }
    return str;
    }
}

//! Base Client (Foreground) Helper
//!
//! @note Standard data filed names should be as follows:
//!         "clientTs"    Client response time
//!         "code"        HTTP response code
class BaseClientHelper {

    //! Determines if the current data needs to be updated
    //! @internal This method _must_ be called every minute to avoid missing the retry remain=0 roll-over
    public static function calcNeedsDataUpdate(type as String, update_interval_secs as Number) as Boolean {
        // Check data valid and recent (within last 30 minutes)
        // Note: We use clientTs as we do not *know* how often weather data is updated (typically hourly)
        var data = Storage.getValue(type) as Dictionary<String, PropertyValueType>?;
        var error = Storage.getValue(type + Globals.DATA_TYPE_ERROR_SUFFIX) as Dictionary<String, PropertyValueType>?;
        var retries = Storage.getValue(type + Globals.DATA_TYPE_RETRIES_SUFFIX) as Number?;

        // Find the last data response time (valid or error)
        var lastTime = ((data != null) ? data["clientTs"] : (error != null) ? error["clientTs"] : null) as Number?;

        if  (lastTime == null) {
            // new system, no data is valid
            return true;

        } else if ((retries != null) && (error != null) && (error["clientTs"] != null)) {
            // Request encountered error(s) - use linear back-off to avoid more errors [5..60 minutes]
            var lastErrorTs = error["clientTs"] as Number;
            var backoffTime = min(5 * retries, 60) * Gregorian.SECONDS_PER_MINUTE;
            return (Time.now().value() - lastErrorTs) > backoffTime;

        } else if ((data == null) || (data["clientTs"] as Number < (Time.now().value() - update_interval_secs))) {
            // (No Valid data) or (Valid Data age is > update interval)
            return true;
        } else {
            // Data still valid
            return false;
        }
    }

    //! Persist (store) the data received from a client
    public static function storeData(data as Dictionary<PropertyKeyType, PropertyValueType>) as Void {
        var responseCode = data["code"] as Number;
        var type = data["type"] as String;
        data.put("clientTs", Time.now().value());

        if (responseCode == 200) {
            // Valid data
            Storage.setValue(type, data);
            Storage.deleteValue(type + Globals.DATA_TYPE_ERROR_SUFFIX);
            Storage.deleteValue(type + Globals.DATA_TYPE_RETRIES_SUFFIX);
        } else {
            // return error to the caller, and update retries count
            var retries = Storage.getValue(type + Globals.DATA_TYPE_RETRIES_SUFFIX) as Number?;
            retries = (retries == null) ? 1 : (retries+1);

            Storage.setValue(type + Globals.DATA_TYPE_ERROR_SUFFIX, data);
            Storage.setValue(type + Globals.DATA_TYPE_RETRIES_SUFFIX, retries);

            debug_print(:client, "$1$: $2$, retry=$3$", [type, responseCode, retries]);
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
                    // Because updates are slower without an API KEY, tell user
                    // to get an api key if they start encountering errors
                    return Lang.format("API KEY/$1$", [responseCode]);
            }

        } catch (ex) {
            debug_print(:client, "ex: $1$", ex.getErrorMessage());
            return "ERR EX";
        }
    }
}
