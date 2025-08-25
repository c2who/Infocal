using Toybox.Application;
using Toybox.Background;
import Toybox.System;
using Toybox.Math;

import Toybox.Application;
import Toybox.Lang;

//! Background Service
//! Container for all background service requests.
//!
//! Limitations:
//! @note Service may be terminated at any time to free memory for foreground
//!       applications!
//! @note Service will also be terminated automatically if does not exit properly
//!       within 30 seconds of opening!
//! @note Service has a ~8KiB payload limit (including overhead) on Background.exit(payload)
//!       If exceeded Background process will throw Unhandled Exception
//!       "Data provided to Background.exit() is too large", and
//!       App.onBackgroundData() is never called!
//!
//! @see  https://developer.garmin.com/connect-iq/core-topics/backgrounding/
//! @see  https://developer.garmin.com/connect-iq/connect-iq-faq/how-do-i-create-a-connect-iq-background-service/
//! @see  https://forums.garmin.com/developer/connect-iq/f/discussion/7550/data-too-large-for-background-process
//! @see  https://developer.garmin.com/connect-iq/api-docs/Toybox/Background.html#exit-instance_function
//!
//! @seealso  https://forums.garmin.com/developer/connect-iq/b/news-announcements/posts/optimal-monkey-c
(:background)
class BackgroundService extends System.ServiceDelegate {
  // Clients
  private var _iqAirClient as IQAirClient?;
  private var _weatherClient as OpenWeatherClient?;

  function initialize() {
    System.ServiceDelegate.initialize();
  }

  //! Background Service Entry Point!
  //! Read pending web requests, and call appropriate web request function.
  //!
  //! @note   Due to the very small available background memory on many devices:
  //!         - make only one web request
  function onTemporalEvent() {
    var stats = System.getSystemStats();
    debug_print(:background, "Mem: $1$ / $2$", [
      stats.freeMemory,
      stats.totalMemory,
    ]);

    // If there are any undelivered background events, deliver them
    var data = Background.getBackgroundData();
    if (data != null) {
      debug_print(:background, "Undelivered: $1$", data);
      Background.exit(data);
    }

    // Else, Process one pending request
    var pendingWebRequests =
      Application.getApp().getProperty("PendingWebRequests") as
      Dictionary<String, Lang.Any>?;
    if (pendingWebRequests != null && pendingWebRequests.size() > 0) {
      // Use random pending client selection, to avoid starving others
      var random = Math.rand();
      var i = random % pendingWebRequests.size();
      var type = pendingWebRequests.keys()[i];

      if (OpenWeatherClient.DATA_TYPE.equals(type)) {
        if (_weatherClient == null) {
          _weatherClient = new OpenWeatherClient();
        }
        _weatherClient.requestData(method(:onReceiveClientData));
      } else if (IQAirClient.DATA_TYPE.equals(type)) {
        if (_iqAirClient == null) {
          _iqAirClient = new IQAirClient();
        }
        _iqAirClient.requestData(method(:onReceiveClientData));
      } else {
        debug_print(:background, "Unknown: $1$", pendingWebRequests);
        Background.exit(null);
      }
    } else {
      debug_print(:background, "Pending: $1$", pendingWebRequests);
      Background.exit(null);
    }
  }

  //! Receives client data and evaluate exiting background service
  //!
  //! @note Data passed to Background.exit() has a ~8KiB limit (including overhead)
  //!       If exceeded Background process will throw Unhandled Exception
  //!       "Data provided to Background.exit() is too large", and
  //!       App.onBackgroundData() is never called!
  //! @see  https://forums.garmin.com/developer/connect-iq/f/discussion/7550/data-too-large-for-background-process
  function onReceiveClientData(
    type as String,
    responseCode as Number,
    data as Dictionary<String, PropertyValueType>
  ) as Void {
    // Avoid circular references
    _weatherClient = null;
    _iqAirClient = null;

    debug_print(:background, "Bkgd: $1$", data);
    Background.exit(data);
  }
}
