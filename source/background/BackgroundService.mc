using Toybox.Background;
using Toybox.System;
using Toybox.Application;

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
//! @see https://developer.garmin.com/connect-iq/core-topics/backgrounding/
//! @see  https://developer.garmin.com/connect-iq/connect-iq-faq/how-do-i-create-a-connect-iq-background-service/
//! @see  https://forums.garmin.com/developer/connect-iq/f/discussion/7550/data-too-large-for-background-process
(:background)
class BackgroundService extends System.ServiceDelegate {

   //! Minimum amount of free memory needed per background request
   //! @note newer devices (e.g. Vivoactive4) can handle multiple web requests in background,
   //!       but older devices (e.g. Fenix 6X) throw too large exception if memory gets too low / payload on exit too big.
   //! @see  https://forums.garmin.com/developer/connect-iq/f/discussion/7550/data-too-large-for-background-process
   private const BACKGROUND_REQUEST_MEM_MIN = 4000; // FIXME: Tune to allow max # of requests based on your payload

   // Cached results
   private var _results = {} as Dictionary<String, Dictionary<String, Lang.Any>>;

   // List of result (types) still pending
   private var _pendingResults as Array<String> = [];

   // Clients
   private var _iqAirClient as IQAirClient?;
   private var _weatherClient as OpenWeatherClient?;

   function initialize() {
      System.ServiceDelegate.initialize();
   }

   //! Background Service Entry Point!
   //! Read pending web requests, and call appropriate web request function.
   function onTemporalEvent() {
      var pendingWebRequests = Application.getApp().getProperty("PendingWebRequests") as Dictionary?;
      var err_background_oom = Application.getApp().getProperty("err_background_oom");
      var stats = System.getSystemStats();
      var free_mem = stats.freeMemory;
      System.println("Total memory: " + stats.totalMemory);
      System.println("Free memory:  " + stats.freeMemory);

      // Defensive coding: ensure pending results queue is empty
      _pendingResults = [];

       if (pendingWebRequests != null) {
         var keys = pendingWebRequests.keys();
         for (var r=0; r < keys.size(); r++) {
            var type = keys[r];

            // Check enough memory to handle additional payload
            if (r > 0) {
               if (  (err_background_oom != null)
                  || (BACKGROUND_REQUEST_MEM_MIN * r+1 > free_mem) ) {
                  System.println("Deferring type: " + type);
                  break; // exit for
               }
            }

            if (OpenWeatherClient.DATA_TYPE.equals( type )) {
               requestOpenWeatherData();
               _pendingResults.add(type);

            } else if (IQAirClient.DATA_TYPE.equals( type )) {
               requestIQAirData();
               _pendingResults.add(type);

            } else {
               System.println("Unknown type: " + type);
            }
         }
      }
   }

   function requestOpenWeatherData() as Void {
      if (_weatherClient == null) {
         _weatherClient = new OpenWeatherClient();
      }
      _weatherClient.requestData(method(:onReceiveClientData));
   }

   function requestIQAirData() as Void {
      if (_iqAirClient == null) {
         _iqAirClient = new IQAirClient();
      }
      _iqAirClient.requestData(method(:onReceiveClientData));
   }

   //! Receives client data and evaluate exiting background service
   //!
   //! @note Data passed to Background.exit() has a ~8KiB limit (including overhead)
   //!       If exceeded Background process will throw Unhandled Exception
   //!       "Data provided to Background.exit() is too large", and
   //!       App.onBackgroundData() is never called!
   //! @see  https://forums.garmin.com/developer/connect-iq/f/discussion/7550/data-too-large-for-background-process
   function onReceiveClientData(type as String, responseCode as Number, data as Dictionary<String, Lang.Any>) as Void {
      // Save data
      _results[type] = data;

      var stats = System.getSystemStats();
      var free_mem = stats.freeMemory;
      System.println("Total memory: " + stats.totalMemory);
      System.println("Free memory:  " + stats.freeMemory);

      // Optimization: Free memory for other callbacks
      if (OpenWeatherClient.DATA_TYPE.equals( type )) {
         _weatherClient = null;
      } else if (IQAirClient.DATA_TYPE.equals( type )) {
         _iqAirClient = null;
      } else {
         System.println("Unknown type: " + type);
      }

      // Exit background service and return results when all requests complete
      _pendingResults.remove(type);
      if (_pendingResults.size() == 0) {
         try {
            System.println(_results);
            Background.exit(_results);
         } catch (ex) {
            //Doh! Device has limited memory/payload size - permanently disable multi-payload and return error
            System.println("Exception: " + ex.getErrorMessage());
            //Application.getApp().setProperty("err_background_oom", true); // FIXME: Only devices with API 3.2.0 Storage can write in background!
            Background.exit( {} );
         }
      }
   }

}
