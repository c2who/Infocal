/*
 * Heartbeat.mc
 *
 * A lightweight diagnostic "heartbeat" for the watch face app.
 *
 * Provides anonymized product usage, product health, and service
 * availability monitoring.
 *
 * Privacy & GDPR Compliant:
 * - The heartbeat sends an anonymized id, device part number, firmware version,
 *   current software version, ciq version, language, and country.
 * - No peronally-identifiable information or IP addresses are ever collected or stored.
 * - Data is processed and retained only for the purpose of anonymized product usage,
 *   product health, and service availability monitoring.
 */

using Toybox.Background;
using Toybox.Math;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;

import Toybox.Application;
import Toybox.Lang;

//! Heartbeat (Background) Client
//!
//! Uses Heartbeat API
//! @see https://github.com/blueacorn/Infocal-worker
//!
//! @note Where possible, code is placed in the foreground client, to avoid
//! bloating the background service memory usage.
(:background)
class HeartbeatClient extends BaseClient {

    public static const DATA_TYPE = "Heartbeat";

    //! Uses Heartbeat API
    //! https://infocal-worker.blueacorn.workers.dev/heartbeat?uid={uid}&part={part}&fw={fw}
    //! headers: { "X-Auth" : "<CLIENT_TOKEN>" }
    const API_HEARTBEAT = "https://infocal-worker.blueacorn.workers.dev/heartbeat";

    function initialize(callback as BaseClient.ClientCallbackMethod) {
        BaseClient.initialize(callback);
    }

    //! Public entry method to make background request to get data from remote service
    //! @param callback     Callback for decoding the response
    function requestData() as Void {

        var token = Storage.getValue("token") as String?;
        var uid = Storage.getValue("uid") as String?;
        var features = Storage.getValue("features") as String?;
        var device = System.getDeviceSettings();

        var params = {
            "uid"   => (uid != null) ? uid : "",
            "part"  => device.partNumber,
            "fw"    => Lang.format("$1$.$2$", device.firmwareVersion),
            "sw"    => APP_VERSION,
            "ciq"   => Lang.format("$1$.$2$.$3$", device.monkeyVersion),
            "lang"  => (device has :systemLanguage) ? device.systemLanguage.toString() : "",
            "feat"   => (features != null) ? features : "",
        };
        var searchParams = encodeParams(params);

        var headers = {
            "X-Auth" => token,
            "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
        };

        BaseClient.makePostRequest(
            API_HEARTBEAT + searchParams,
            null,
            headers,
            method(:onHeartbeatResponse)
        );
    }

    //! Callback handler for makeWebRequest. Decodes response and flatten (extract) data we need.
    //!
    //! @param  responseCode   the server response code or a BLE_* error type
    //! @param  data           the content if the request was successful, or null
    //!
    //! @note Large API payload can cause out-of-memory errors when processing network response
    //!       on devices with lower available memory (NETWORK_RESPONSE_OUT_OF_MEMORY = -403).
    //!       It is imperative that the code/data size of background task is kept
    //!       as small as possible!
    //! @see  https://developer.garmin.com/connect-iq/api-docs/Toybox/Communications.html
    function onHeartbeatResponse(responseCode as Number, data as Dictionary?) as Void {
        var result = {
            "type" => DATA_TYPE,
            "code" => responseCode.toNumber(),
            "sw" => (data != null) ? data["sw"] : null,
        };
        _callback.invoke(DATA_TYPE, responseCode, result as Dictionary<PropertyKeyType, PropertyValueType>);
    }
}

//! Heartbeat (Foreground) client helper
//!
//! @note Where possible, code is placed in the foreground client, to avoid
//!       bloating the background service memory usage.
public class HeartbeatHelper {

    public static function needsDataUpdate() as Boolean {

        // set client token and uid for background service
        var token = Keys.getWorkerToken();
        Storage.setValue("token", token);
        setUniqueId();

        // Check if we need to udpate due to changed software version
        var data = Storage.getValue(HeartbeatClient.DATA_TYPE) as Dictionary<String, PropertyValueType>?;
        if ((data == null) || (data["sw"] == null) || (!APP_VERSION.equals(data["sw"]))) {
            // software version changed, so we need to send a heartbeat
            return true;
        }

        // Check if we need to update (once per day)
        var update_interval_secs = 1 * Gregorian.SECONDS_PER_DAY;
        return BaseClientHelper.calcNeedsDataUpdate(HeartbeatClient.DATA_TYPE, update_interval_secs);
    }

    //! Generate a random unique id
    //! Uses `settings.unique_identifier` if available; otherwise generates a unique id with entropy
    static function setUniqueId() as Void {
        var uid = Storage.getValue("uid") as String?;
        if (uid == null) {
            var s = System.getDeviceSettings();
            if ((s has :uniqueIdentifier) && (s.uniqueIdentifier != null)) {
                // Use application unique id, API 2.4.1+
                uid = s.uniqueIdentifier;
            } else {
                // Create a unique per-install identifier
                var partNum   = (s.partNumber != null) ? s.partNumber : "";
                var fw        = (s.firmwareVersion != null) ? Lang.format("$1$.$2$", s.firmwareVersion) : "";
                var now = Time.now().value();
                var rnd = Math.rand();

                // Hash values
                var part1 = fnv1a32AsString(partNum + fw);
                var part2 = fnv1a32AsString(now.toString());
                var part3 = fnv1a32AsString(rnd.toString());

                // Concatenate parts
                uid = part1 + part2 + part3;
            }
            Storage.setValue("uid", uid);
        }
    }
}
