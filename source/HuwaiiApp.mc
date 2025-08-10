using Toybox.Application;
using Toybox.Background;
using Toybox.Activity as Activity;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Time;
using Toybox.Math;
using Toybox.Time.Gregorian as Date;

import Toybox.Lang;

// In-memory current location.
// Previously persisted in App.Storage, but now persisted in Object Store due to #86 workaround for App.Storage firmware bug.
// Persistence allows weather and sunrise/sunset features to be used after watch face restart, even if watch no longer has current
// location available.
var gLocationLat = null;
var gLocationLon = null;

function degreesToRadians(degrees) {
   return (degrees * Math.PI) / 180;
}

function radiansToDegrees(radians) {
   return (radians * 180) / Math.PI;
}

function convertCoorX(radians, radius) {
   return center_x + radius * Math.cos(radians);
}

function convertCoorY(radians, radius) {
   return center_y + radius * Math.sin(radians);
}

// FIXME: Move all code not required for (:background) runtime out of HuwaiiApp class
//        - background runtime is *very* memory limited, so must avoid issues on smaller devices
(:background)
class HuwaiiApp extends Application.AppBase {
   var _View;
   var _currentFieldIds as Array<Number> = {};

   static const days = {
         Date.DAY_MONDAY => "MON",
         Date.DAY_TUESDAY => "TUE",
         Date.DAY_WEDNESDAY => "WED",
         Date.DAY_THURSDAY => "THU",
         Date.DAY_FRIDAY => "FRI",
         Date.DAY_SATURDAY => "SAT",
         Date.DAY_SUNDAY => "SUN",
      };
   static const months = {
         Date.MONTH_JANUARY => "JAN",
         Date.MONTH_FEBRUARY => "FEB",
         Date.MONTH_MARCH => "MAR",
         Date.MONTH_APRIL => "APR",
         Date.MONTH_MAY => "MAY",
         Date.MONTH_JUNE => "JUN",
         Date.MONTH_JULY => "JUL",
         Date.MONTH_AUGUST => "AUG",
         Date.MONTH_SEPTEMBER => "SEP",
         Date.MONTH_OCTOBER => "OCT",
         Date.MONTH_NOVEMBER => "NOV",
         Date.MONTH_DECEMBER => "DEC",
      };


   function initialize() {
      AppBase.initialize();
   }

   // onStart() is called on application start up
   function onStart(state) {}

   // onStop() is called when your application is exiting
   function onStop(state) {}

   // Return the initial view of your application here
   function getInitialView() {
      updateCurrentDataFieldIds();
      _View = new HuwaiiView();
      return [_View];
   }

   function getView() {
      return _View;
   }

   function onSettingsChanged() {
      // triggered by settings change in GCM
      updateCurrentDataFieldIds();

      checkPendingWebRequests();
      
      _View.onSettingsChanged();
      WatchUi.requestUpdate(); // update the view to reflect changes
   }

   // Determine if any web requests are needed.
   // If so, set approrpiate pendingWebRequests flag for use by BackgroundService, then register for
   // temporal event.
   // Currently called on layout initialisation, when settings change, and on exiting sleep.
   function checkPendingWebRequests() {
      // Update last known location
      updateLastLocation();

      if (!(Sys has :ServiceDelegate)) {
         return;
      }

      // Check for need data / retry policy only if have data connection
      var settings = System.getDeviceSettings();
      if (!settings.phoneConnected) {
         return;
      }

      var pendingWebRequests = {};

      if (needWeatherDataUpdate()) {
         pendingWebRequests[$.DATA_TYPE_WEATHER] = true;
      }

      // If AirQuality data in used
      if (isAnyDataFieldsInUse( [FIELD_TYPE_AIR_QUALITY] )) {
         if (AirQualityField.needsDataUpdate()) {
            pendingWebRequests[IQAirClient.DATA_TYPE] = true;
         }
      }

      setProperty("PendingWebRequests", pendingWebRequests);

      // If there are any pending data requests (and phone is connected)
      var settings = System.getDeviceSettings();
      if (settings.phoneConnected && (pendingWebRequests.keys().size() > 0)) {
         // Register for background temporal event as soon as possible.
         var lastTime = Background.getLastTemporalEventTime();
         
         if (lastTime) {
            // Events scheduled for a time in the past trigger immediately.
            var nextTime = lastTime.add(new Time.Duration(5 * 60));
            Background.registerForTemporalEvent(nextTime);
         } else {
            Background.registerForTemporalEvent(Time.now());
         }
      }
   }

   //! Populates a list of all the data field ids in use
   function updateCurrentDataFieldIds() as Void {
      var fieldIds = [
         getComplicationSettingDataKey(12),
         getComplicationSettingDataKey(10),
         getComplicationSettingDataKey(2),
         getComplicationSettingDataKey(4),
         getComplicationSettingDataKey(6),
         getComplicationSettingDataKey(8),
         getBarDataComplicationSettingDataKey(0),
         getBarDataComplicationSettingDataKey(1),
         $.getGraphComplicationDataKey(0),
         $.getGraphComplicationDataKey(1)
      ];

      _currentFieldIds = fieldIds;
   }

   function isAnyDataFieldsInUse(fieldIds as Array<Number>) {
      for (var i =0; i < fieldIds.size(); i++) {
         var id = fieldIds[i];
         if (_currentFieldIds.indexOf(id) != -1) {
            return true;
         }
      }
      return false;
   }

   function updateLastLocation() as Void {
      // Attempt to update current location, to be used by Sunrise/Sunset, Weather, Air Quality.
      // If current location available from current activity, save it in case it goes "stale" and can not longer be retrieved.
      var location = Activity.getActivityInfo().currentLocation;
      if (location) {
         // Save current location to globals
         location = location.toDegrees(); // Array of Doubles.
         gLocationLat = location[0].toFloat();
         gLocationLon = location[1].toFloat();

         Application.getApp().setProperty("LastLocationLat", gLocationLat);
         Application.getApp().setProperty("LastLocationLon", gLocationLon);
      } else {
         // current location is not available, read stored value from Object Store, being careful not to overwrite a valid
         // in-memory value with an invalid stored one.
         var lat = Application.getApp().getProperty("LastLocationLat");
         var lon = Application.getApp().getProperty("LastLocationLon");
         if ((lat != null) && (lon != null)) {
            gLocationLat = lat;
            gLocationLon = lon;
         }
      }
   }

   function needWeatherDataUpdate() as Boolean {
      // OpenWeather data field must be shown.
      if (!isAnyDataFieldsInUse( [FIELD_TYPE_TEMPERATURE_HL, FIELD_TYPE_TEMPERATURE_OUT, FIELD_TYPE_WEATHER, FIELD_TYPE_WIND] )) {
         return false;
      }

      // Location must be available
      if ((gLocationLat == null) || (gLocationLon == null)) {
         return false;
      }

      var data = getProperty($.DATA_TYPE_WEATHER);

      if ((data == null) || (data["clientTs"] == null)) {
         // No existing data.
         return true;
      } else if (data["cod"] == 200) {
         // Successfully received weather data.
         // TODO: Consider requesting weather at sunrise/sunset to update weather icon.
         if (
            // Existing data is older than 15 mins.
            // Note: We use clientTs as we do not *know* how often weather data is updated (typically hourly)
            Time.now().value() > (data["clientTs"] + (15 * 60)) ||
            // Existing data not for this location.
            // Not a great test, as a degree of longitude varies betwee 69 (equator) and 0 (pole) miles, but simpler than
            // true distance calculation. 0.02 degree of latitude is just over a mile.
            (gLocationLat - data["lat"]).abs() > 0.02 ||
            (gLocationLon - data["lon"]).abs() > 0.02) {
            return true;
         }
      } else {
         // Retry on error
         return true;
      }
   }

   //! Get a ServiceDelegate to run background tasks for this app.
   //! When a ServiceDelegate is retrieved, the following will occur:
   //! - The method triggered within the ServiceDelegate will be run
   //! - The background task will exit using Background.exit() or System.exit()
   //! @warn The background task will be automatically terminated after 30 seconds if it is not exited by these methods
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
   function onBackgroundData(service_data) {
      var pendingWebRequests = getProperty("PendingWebRequests");
      if (pendingWebRequests == null) {
         pendingWebRequests = {};
      }

      var keys = service_data.keys();
      for(var i=0; i< keys.size(); i++) {
         var type = keys[i];
         var data = service_data[type];

         // New data received: clear pendingWebRequests flag and persist data.
         pendingWebRequests.remove(type);
         setProperty("PendingWebRequests", pendingWebRequests);
         setProperty(type, data);
      }

      // Save list of any remaining background requests
      setProperty("PendingWebRequests", pendingWebRequests);
      Ui.requestUpdate();
   }

   function getFormattedDate() {
      var now = Time.now();
      var date = Date.info(now, Time.FORMAT_SHORT);
      var date_formatter = Application.getApp().getProperty("date_format");
      if (date_formatter == 0) {
         if (Application.getApp().getProperty("force_date_english")) {
            var day_of_week = date.day_of_week;
            return Lang.format("$1$ $2$", [
               days[day_of_week],
               date.day.format("%d"),
            ]);
         } else {
            var long_date = Date.info(now, Time.FORMAT_LONG);
            var day_of_week = long_date.day_of_week;
            return Lang.format("$1$ $2$", [
               day_of_week.toUpper(),
               date.day.format("%d"),
            ]);
         }
      } else if (date_formatter == 1) {
         // dd/mm
         return Lang.format("$1$.$2$", [
            date.day.format("%d"),
            date.month.format("%d"),
         ]);
      } else if (date_formatter == 2) {
         // mm/dd
         return Lang.format("$1$.$2$", [
            date.month.format("%d"),
            date.day.format("%d"),
         ]);
      } else if (date_formatter == 3) {
         // dd/mm/yyyy
         var year = date.year;
         var yy = year / 100.0;
         yy = Math.round((yy - yy.toNumber()) * 100.0);
         return Lang.format("$1$.$2$.$3$", [
            date.day.format("%d"),
            date.month.format("%d"),
            yy.format("%d"),
         ]);
      } else if (date_formatter == 4) {
         // mm/dd/yyyy
         var year = date.year;
         var yy = year / 100.0;
         yy = Math.round((yy - yy.toNumber()) * 100.0);
         return Lang.format("$1$.$2$.$3$", [
            date.month.format("%d"),
            date.day.format("%d"),
            yy.format("%d"),
         ]);
      } else if (date_formatter == 5 || date_formatter == 6) {
         // dd mmm
         var day = null;
         var month = null;
         if (Application.getApp().getProperty("force_date_english")) {
            day = date.day;
            month = months[date.month];
         } else {
            var medium_date = Date.info(now, Time.FORMAT_MEDIUM);
            day = medium_date.day;
            month = months[medium_date.month];
         }
         if (date_formatter == 5) {
            return Lang.format("$1$ $2$", [day.format("%d"), month]);
         } else {
            return Lang.format("$1$ $2$", [month, day.format("%d")]);
         }
      }
   }

   function toKValue(value) {
      var valK = value / 1000.0;
      return valK.format("%0.1f");
   }
}
