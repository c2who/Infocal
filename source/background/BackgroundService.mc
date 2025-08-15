using Toybox.Background;
using Toybox.System as Sys;
using Toybox.Communications as Comms;
using Toybox.Application as App;

import Toybox.Lang;

//! Background Service
//! Container for all background service requests.
//!
//! @note Service may be terminated at any time to free memory for foreground applications.
//! @note Service will also be terminated automatically if does not exit properly within 30 seconds of opening.
//!
//! @see https://developer.garmin.com/connect-iq/core-topics/backgrounding/
(:background)
class BackgroundService extends Sys.ServiceDelegate {

   // Cached results
   private var _results = {} as Dictionary<String, Dictionary<String, Lang.Any>>;

   // List of result (types) still pending
   private var _pendingResults as Array<String> = [];

   // Clients
   private var _iqAirClient as IQAirClient?;
   private var _weatherClient as OpenWeatherClient?;

   function initialize() {
      Sys.ServiceDelegate.initialize();
   }

   //! Background Service Entry Point!
   //! Read pending web requests, and call appropriate web request function.
   function onTemporalEvent() {
      var pendingWebRequests = App.getApp().getProperty("PendingWebRequests") as Array<String>;
      if (pendingWebRequests != null) {
         // Invoke clients as needed
         if (pendingWebRequests[OpenWeatherClient.DATA_TYPE] != null) {
            if (_weatherClient == null) {
               _weatherClient = new OpenWeatherClient();
            }
            _weatherClient.requestData(method(:onReceiveClientData));
            _pendingResults.add(OpenWeatherClient.DATA_TYPE);
         }

         if (pendingWebRequests[IQAirClient.DATA_TYPE] != null) {
            if (_iqAirClient == null) {
               _iqAirClient = new IQAirClient();
            }
            _iqAirClient.requestData(method(:onReceiveClientData));
            _pendingResults.add(IQAirClient.DATA_TYPE);
         }
      }
   }

   //! Receives client data and evaluate exiting background service
   function onReceiveClientData(type as String, responseCode as Number, data as Dictionary<String, Lang.Any>) as Void {
      // Save data
      _results[type] = data;

      // Exit background service and return results when all requests complete
      _pendingResults.remove(type);
      if (_pendingResults.size() == 0) {
         Background.exit(_results);
      }
   }

}
