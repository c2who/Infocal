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
    protected var _retry_backoff_seconds = 30 * SECONDS_PER_MINUTE;
    protected var _max_age_seconds = 30 * SECONDS_PER_MINUTE;

    function initialize(type as String) {
        _type = type;
    }

    //! Determines if the current data needs to be updated
    function needsDataUpdate() as Boolean {
        var type = _type;

        // Check data valid and recent (within last 30 minutes)
        // Note: We use clientTs as we do not *know* how often weather data is updated (typically hourly)
        var app = Application.getApp();
        var data = app.getProperty(type);
        var retries = app.getProperty(type + Constants.DATA_TYPE_RETRIES_SUFFIX);

        if ( (data == null) || (data["clientTs"] == null) ) {
            // new system, no data is valid
            return true;

        } else if ((retries != null) && (retries > _max_retries)) {
            // FIXED: If API is not responding after retries, back off (retry every 30 minutes)
            var remain = (Time.now().value() - data["clientTs"]) % _retry_backoff_seconds;
            return (remain == 0);

        } else if (data["clientTs"] < (Time.now().value() - _max_age_seconds)) {
            // Data is > 30mins old
            return true;
        } else {
            // Data still valid
            return false;
        }
    }

    function onBackgroundData(type as String, data as Dictionary<String, Lang.Any>) {
        if (!_type.equals(type)) {
            throw new InvalidValueException(type);
        }
        
        // Store data
        var app = App.getApp();
        if ((data != null) && (data["code"] == 200)) {
            // Valid data
            app.setProperty(type, data);
            app.setProperty(type + Constants.DATA_TYPE_ERROR_SUFFIX, null);
            app.setProperty(type + Constants.DATA_TYPE_RETRIES_SUFFIX, null);
        } else {
            // return error to the caller, and update retries count
            var retries = app.getProperty(type + Constants.DATA_TYPE_RETRIES_SUFFIX);
            retries = (retries == null) ? 1 : (retries+1);

            app.setProperty(type + Constants.DATA_TYPE_ERROR_SUFFIX, data);
            app.setProperty(type + Constants.DATA_TYPE_RETRIES_SUFFIX, retries);
        }
    }
}