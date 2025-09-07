using Toybox.Background;
using Toybox.Activity;
using Toybox.System;
using Toybox.Time;
using Toybox.Math;

import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// In-memory current location.
// Previously persisted in App.Storage, but now persisted in Object Store due to #86 workaround for App.Storage firmware bug.
// Persistence allows weather and sunrise/sunset features to be used after watch face restart, even if watch no longer has current
// location available.
var gLocation as [Float, Float]?;

//! Watchface Application entry point
//! @note App class is used in (:background) context; class should only contain
//!       code necessary to start foreground and background instances.
(:background)
class InfocalApp extends AppBase {
   private var _View as InfocalView?;
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
   (:typecheck(disableBackgroundCheck))
   function getInitialView() as [Views] or [Views, InputDelegates] {
      var view = new InfocalView();
      _View = view;

      if( Toybox.WatchUi.WatchFace has :onPartialUpdate ) {
         return [ view, new InfocalViewDelegate(view) ];
      } else {
         return [ view ];
      }
   }

   //! Called when the application settings have been changed by Garmin Connect Mobile (GCM) *while while the app is running*.
   //!
   //! Override this method to change app behavior when settings change.
   //! @note This is typically used to call for an update to the WatchUi.requestUpdate()
   (:typecheck(disableBackgroundCheck))
   function onSettingsChanged() {
      if (_View != null) { _View.onSettingsChanged(); }
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
   (:typecheck(disableBackgroundCheck))
   function onBackgroundData(pt as PersistableType) {
      debug_print(:background, "Data: $1$", pt);
      var data = pt as Dictionary<PropertyKeyType, PropertyValueType>;
      var type = data["type"] as String?;

      // DEFECT 2025.8.11: Background Data from previous version (schema) is nested dictionary
      // (This is a one-off error for delayed background data delivery after upgrade, and can be discarded)
      if (type != null) {
         // New data received: clear pendingWebRequests flag for the received data type
         // (Save list of any remaining background requests)
         var pendingWebRequests = Storage.getValue("PendingWebRequests") as Dictionary<PropertyKeyType, PropertyValueType>?;
         if (pendingWebRequests != null) {
            pendingWebRequests.remove(type);
            Storage.setValue("PendingWebRequests", pendingWebRequests);
         }

         BaseClientHelper.storeData(data);
      }
      WatchUi.requestUpdate();
   }
}
