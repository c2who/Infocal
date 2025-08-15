using Toybox.Application as App;
using Toybox.Background;
using Toybox.Communications;
using Toybox.System;

import Toybox.Lang;

//! Base (Background) Client
//!
//! @note Where possible, code is placed in the foreground client, to avoid
//! bloating the background service memory usage.
(:background)
class BaseClient {
    //! Make HTTP request (over phone bluetooth connection)
    //!
    //! @see https://developer.garmin.com/connect-iq/api-docs/Toybox/Communications.html#makeWebRequest-instance_function
    static function makeWebRequest(url, params, callback) as Void {
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
//!         "clientTs"    client response time
//!         "code"        HTTP response code
class BaseClientHelper {
    const SECONDS_PER_MINUTE = 60;

    protected var _type;

    // Defaults
    protected var _max_retries = 3;
    protected var _retry_backoff_minutes = 30;
    protected var _update_interval_secs = 30 * SECONDS_PER_MINUTE;

    function initialize(type as String) {
        self._type = type;
    }

    //! Determines if the current data needs to be updated
    //! @internal This method _must_ be called every minute to avoid missing the retry remain=0 roll-over
    function needsDataUpdate() as Boolean {
        // Check data valid and recent (within last 30 minutes)
        // Note: We use clientTs as we do not *know* how often weather data is updated (typically hourly)
        var app = Application.getApp();
        var data = app.getProperty(_type);
        var retries = app.getProperty(_type + Constants.DATA_TYPE_RETRIES_SUFFIX);

        if ( (data == null) || (data["clientTs"] == null) ) {
            // new system, no data is valid
            return true;

        } else if ((retries != null) && (retries > _max_retries)) {
            // FIXED: If API is not responding after retries, back off (retry every 30 minutes)
            // Note: Calculation must be performed in minutes (not seconds) as we only evaluate this every minute
            var remain = ((Time.now().value() - data["clientTs"]) / SECONDS_PER_MINUTE) % _retry_backoff_minutes;
            return (remain == 0);

        } else if (data["clientTs"] < (Time.now().value() - _update_interval_secs)) {
            // Data age is > update interval
            return true;
        } else {
            // Data still valid
            return false;
        }
    }

    function onBackgroundData(data as Dictionary?) {
        // Store data
        var app = App.getApp();
        if ((data != null) && (data["code"] == 200)) {
            // Valid data
            app.setProperty(_type, data);
            app.setProperty(_type + Constants.DATA_TYPE_ERROR_SUFFIX, null);
            app.setProperty(_type + Constants.DATA_TYPE_RETRIES_SUFFIX, null);
        } else {
            // return error to the caller, and update retries count
            var retries = app.getProperty(_type + Constants.DATA_TYPE_RETRIES_SUFFIX);
            retries = (retries == null) ? 1 : (retries+1);

            app.setProperty(_type + Constants.DATA_TYPE_ERROR_SUFFIX, data);
            app.setProperty(_type + Constants.DATA_TYPE_RETRIES_SUFFIX, retries);
        }
    }

    //! Decode the makeWebRequest callback responseCode.
    //! @param  responseCode The server response code or a BLE_* error type
    //!
    //! @see https://developer.garmin.com/connect-iq/api-docs/Toybox/Communications.html
    static function getCommunicationsErrorCodeText(responseCode as Number) as String {
        try {
            switch (responseCode) {
                case 401: // Unauthorized
                case 403: // Forbidden
                case 429: // Too Many Requests (often due to api key quota)
                    return "API KEY";
                    break;
                default:
                    return Lang.format("ERR $1$", responseCode);
            }

        } catch (ex) {
            System.println((ex.getErrorMessage()));
            return "ERR";
        }
    }
}
