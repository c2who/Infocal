using Toybox.Application;
using Toybox.Background;
using Toybox.Activity;
using Toybox.System;
using Toybox.Time;
using Toybox.Math;

import Toybox.Lang;
import Toybox.WatchUi;

// In-memory current location.
// Previously persisted in App.Storage, but now persisted in Object Store due to #86 workaround for App.Storage firmware bug.
// Persistence allows weather and sunrise/sunset features to be used after watch face restart, even if watch no longer has current
// location available.
var gLocationLat = null;
var gLocationLon = null;

// FIXME: Move all code not required for (:background) runtime out of InfocalApp class
//        - background runtime is *very* memory limited, so must avoid issues on smaller devices
(:background)
class InfocalApp extends Application.AppBase {
   var _View;
   function initialize() {
      AppBase.initialize();
   }

   //! Method called at startup to allow handling of app initialization.
   //!
   //! Before the initial WatchUi.View is retrieved, onStart() is called.
   //! Application level settings can be initialized or retrieved from the object store before the initial View is created.
   //! This method must be overridden to handle your own app initialization.
   function onStart(state as Dictionary?) as Void {
   }

   //! Override to handle application cleanup upon termination.
   //!
   //! If the application needs to save data to the object store it should be done in this function.
   //! Once the function is complete, the application will terminate.
   function onStop(state as Dictionary?) as Void {
   }

   //! Override to provide the initial View and Input Delegate of the application.
   //! @note This method must be overridden in derived classes. If called, this function will cause the application to crash.
   function getInitialView() as [Views] or [Views, InputDelegates] {
      _View = new InfocalView();

      if( Toybox.WatchUi.WatchFace has :onPartialUpdate ) {
         return [ _View, new InfocalViewDelegate(_View) ];
      } else {
         return [ _View ];
      }
   }

   //! Called when the application settings have been changed by Garmin Connect Mobile (GCM) *while while the app is running*.
   //!
   //! Override this method to change app behavior when settings change.
   //! @note This is typically used to call for an update to the WatchUi.requestUpdate()
   function onSettingsChanged() {
      _View.onSettingsChanged();
   }

   //! Get a ServiceDelegate to run background tasks for this app.
   //! When a ServiceDelegate is retrieved, the following will occur:
   //! - The method triggered within the ServiceDelegate will be run
   //! - The background task will exit using Background.exit() or System.exit()
   //! @warn The background task will be automatically terminated after 30 seconds if it is not exited by these methods
   //!
   //! @see  https://developer.garmin.com/connect-iq/core-topics/backgrounding/
   //! @see  https://developer.garmin.com/connect-iq/connect-iq-faq/how-do-i-create-a-connect-iq-background-service/
   function getServiceDelegate() {
      return [new BackgroundService()];
   }

   //! Handle data passed from a ServiceDelegate to the application.
   //! @param  service_data  Dictionary of data returned from service delegate
   //!
   //! When the Background process terminates, a data payload may be available.
   //! - If the main application is active when this occurs, the data will be passed to the application's onBackgroundData() method.
   //! - If the main application is not active, the data will be saved until the next time the application is launched and
   //!   will be passed to the application after the onStart() method completes.
   //!
   //! @note This callback can be called from onStart() -- before the view is created!
   //!
   //! @see  https://developer.garmin.com/connect-iq/core-topics/backgrounding/
   //! @see  https://developer.garmin.com/connect-iq/connect-iq-faq/how-do-i-create-a-connect-iq-background-service/
   function onBackgroundData(data as Dictionary<String, Lang.Any>) {
      System.println("Foreground: " + data);

      // New data received: clear pendingWebRequests flag for the received data type
      // Save list of any remaining background requests
      var type = data["type"];
      var pendingWebRequests = getProperty("PendingWebRequests") as Dictionary<String, Lang.Any>?;
      if (pendingWebRequests == null) {
         pendingWebRequests = {};
      }

      // DEFECT 2025.8.11: Background Data from previous version (schema) is nested dictionary
      // (This is a one-off error for delayed background data delivery after upgrade, and can be discarded)
      if (type != null) {
         pendingWebRequests.remove(type);
         setProperty("PendingWebRequests", pendingWebRequests);
         BaseClientHelper.storeData(data);
      }
      WatchUi.requestUpdate();
   }
}
