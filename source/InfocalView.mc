import Toybox.Application;
import Toybox.Graphics;
import Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

import Settings;

typedef DrawableInitOptions as { :identifier as Object, :locX as Numeric, :locY as Numeric, :width as Numeric, :height as Numeric, :visible as Boolean };

// Global font resources
var small_digi_font as FontType?;

var second_x as Number = 160;
var second_y as Number = 140;
var heart_x as Number = 80;
var center_x as Number = 0;
var center_y as Number = 0;

var second_font_height_half as Number = 7;
var second_clip_size as [Number, Number] = [0, 0];

// theming
var gbackground_color as Number = 0x000000;
var gmain_color as Number = 0xffffff;
var gaccent_color as Number = 0xff0000;
var garc_color as Number = 0x555555;
var gbar_color_indi as Number = 0xaaaaaa;
var gbar_color_back as Number = 0x550000;
var gbar_color_0 as Number = 0xffff00;
var gbar_color_1 as Number = 0x0000ff;
var ghour_color as Number = 0xff0000;
var gmins_color as Number = 0xffffff;

var gtheme as Number = -1;

// Views
var _backgroundView as BackgroundView?;

class InfocalView extends WatchUi.WatchFace {
   //! Additional memory margin (in bytes) to safely create screen BufferedBitmap
   //! Minimum memory = (screen buffer size) + (runtime margin)
   private const RUNTIME_MEM_MARGIN_MIN = 5000; //bytes

   private const _hasBatteryInDays = (System.Stats has :batteryInDays) as Boolean; // API 3.3.0
   private const _hasServiceDelegate = (System has :ServiceDelegate) as Boolean; // background service

   private var _partialUpdatesAllowed as Boolean = WatchUi.WatchFace has :onPartialUpdate;
   private var _settings_changed as Boolean = false;
   private var _isAwake as Boolean = true;
   private var last_draw_minute as Number = -1;
   private var restore_from_resume as Boolean = false;
   private var restore_from_sleep as Boolean = false;
   private var face_radius as Number = 0;

   // Cached settings
   private var _use_analog as Boolean = false;
   private var _always_on_second as Boolean = false;
   private var _always_on_heart as Boolean = false;
   private var _always_on_style as Lang.Number = 0;

   // Cached fonts
   private var _always_on_digi_font as FontType?;

   //! Battery Monitor Client.
   //! Used on watches that do not have Stats.batteryInDays (API 3.3.0)
   private var _batteryMonitor as BatteryMonitor?;

   //! List of Field Ids currently displayed on screen (in use)
   var _currentFieldsIdsInUse as Array<Number> = [];

   //! Screen buffer stores a copy of the bitmap rendered to the screen.
   //! This avoids having to fully redraw the screen each update, improving battery life
   //! @note Screen bufferring can only be used on (newer) devices with larger memory,
   //!       on lower-end devices it must be disabled to avoid out of memory errors.
   private var _screen_buffer as Graphics.BufferedBitmap? = null;

   function initialize() {
      WatchFace.initialize();

      debug_print(:view, "init [$1$]", _partialUpdatesAllowed);
   }

   //! The entry point for the View.
   //! onLayout() is called before the View is shown to load resources and set up the layout of the View.
   //! @note Watch Faces: onLayout() → onShow() → onUpdate()
   function onLayout(dc as Dc) {
      // Set globals
      center_x = dc.getWidth() / 2;
      center_y = dc.getHeight() / 2;
      face_radius = center_x - ((18 * center_x) / 120).toNumber();

      readSettings();

      // Load Watchface drawables from layout.xml (creates all Ui.Drawable classes)
      setLayout(Rez.Layouts.WatchFace(dc));
      loadDrawables(dc);

      loadFonts();
      updateColorsInUse();
      updateCurrentFieldIdsInUse();
      calcAlwaysOnLayout(dc);

      setupScreenBuffer(dc);
   }

   //! Handle view updates from settings changed
   function onSettingsChanged() as Void {
      last_draw_minute = -1;
      _settings_changed = true;

      readSettings();
      updateColorsInUse();
      updateCurrentFieldIdsInUse();

      // update the view to reflect changes
      WatchUi.requestUpdate();
   }

   //! Read (cache) settings
   //! Used to avoid expensive Properties reads in low-power mode (eg. onPartialUpdate)
   function readSettings() as Void {
      _use_analog = Properties.getValue("use_analog") as Boolean;
      _always_on_second = Properties.getValue("always_on_second") as Boolean;
      _always_on_heart = Properties.getValue("always_on_heart") as Boolean;
      _always_on_style = Properties.getValue("always_on_style") as Number;
   }

   // Called when this View is brought to the foreground. Restore
   // the state of this View and prepare it to be shown. This includes
   // loading resources into memory.
   function onShow() {
      loadFonts();

      last_draw_minute = -1;
      restore_from_resume = true;
   }

   // Called when this View is removed from the screen. Save the
   // state of this View here. This includes freeing resources from
   // memory.
   function onHide() {
      // Unload fonts
      small_digi_font = null;
      _always_on_digi_font = null;
   }

   //! Update the View.
   //! This is called when a View is brought to the foreground, after the call to onShow().
   //! There are also some special cases when it will be invoked:
   //! - On WatchUi.requestUpdate() calls within Widgets and Watch Apps
   //! - Once per minute in Watch Faces when in low power mode
   //! - Once per second in Watch Faces when in high power mode
   //! - Once per second in Data Fields
   //!
   //! @note More than one call to onUpdate() may occur during View transitions
   function onUpdate(screenDc) {
      var clockTime = System.getClockTime();
      var minute_changed = clockTime.min != last_draw_minute;

      // force update layout if settings changed
      if (_settings_changed) {
         onLayout(screenDc);
      }

      if (restore_from_resume || minute_changed || _settings_changed) {
         // update all client data (e.g. Air Quality, Weather, Battery Info)
         updateClientData();
      }

      // On some older devices (e.g. vivoactive_hr):
      //       - you can avoid performing a full screen draw every minute
      //       - do not need to perform full redraw on every update as screen is not cleared
      //       - you just need to do full redraw on: onLayout, onShow and onExitSleep
      //         (and for this app minute_changed to print a new hh:mm time)
      var power_save_mode = Properties.getValue("power_save_mode") as Boolean;
      if (power_save_mode == false || _settings_changed || restore_from_resume || restore_from_sleep || minute_changed) {
         // Clear screen clip region (may be set after onPartialUpdate/onPowerBudgetExceeded on some devices)
         screenDc.clearClip();

         // Use screen_buffer if available
         var dc = _screen_buffer != null ? _screen_buffer.getDc() : screenDc;

         //! @note because we can use screen buffering, call mainDrawComponents() instead of View.onUpdate() to update drawables and draw screen
         mainDrawComponents(dc);

         // Copy screen buffer to screen
         if (_screen_buffer != null) {
            screenDc.drawBitmap(0, 0, _screen_buffer);
         }
      }

      // Reset draw state flags
      last_draw_minute = clockTime.min;
      restore_from_resume = false;
      restore_from_sleep = false;
      minute_changed = false;
      _settings_changed = false;

      // Update seconds and hr fields in high power mode (or at top of minute during sleep partial updates)
      if (_isAwake || _partialUpdatesAllowed) {
         onPartialUpdate(screenDc);
      }
   }

   //! Update a portion of the screen.
   //! Partial updates can be used to update a small part of the screen to allow for Always On Watch Faces.
   //! This method is called each second as long as the device power budget is not exceeded.
   //! @note     If the call to this method exceeds the power budget of the device, the partial update will not draw and
   //!           a call to onPowerBudgetExceeded() is made to report the limits that were exceeded.
   //! @internal It is important to update as small of a portion of the display as possible in this method to avoid
   //!           exceeding the allowed power budget. To do this, the application must set the clipping region for the
   //!           Graphics.Dc object using the setClip() method.
   //!
   //! @internal Calls to System.println() and System.print() will not execute on devices when this function is being
   //!           invoked, but can be used in the device *simulator*.
   //! @note     Any system I/O in partial updates (e.g. Properties, Storage, Resources) will cause time budget to be
   //!           exceeded - sometimes in weird ways (like showing Graphics Time taking 1700000 usec)
   public function onPartialUpdate(dc as Dc) as Void {
      // FIXME: Support seconds on Analog by painting circular mask in centre of dial
      if (_use_analog) {
         // not supported
         return;
      }
      var font = _always_on_digi_font;
      if (_always_on_second && font != null) {
         var clockTime = System.getClockTime();
         var second_text = clockTime.sec.format("%02d");

         dc.setClip(second_x, second_y, second_clip_size[0], second_clip_size[1]);
         dc.setColor(Graphics.COLOR_TRANSPARENT, gbackground_color);
         dc.clear();
         dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
         dc.drawText(second_x, second_y, font, second_text, Graphics.TEXT_JUSTIFY_LEFT);
      }

      if (_always_on_heart && font != null) {
         var width = second_clip_size[0];
         dc.setClip(heart_x - width - 1, second_y, width + 2, second_clip_size[1]);
         dc.setColor(Graphics.COLOR_TRANSPARENT, gbackground_color);
         dc.clear();

         // fix: remove (and do not draw) heart rate if invalid
         var hr = _retrieveHeartrate();
         if (hr != null && hr > 0) {
            var heart_text = hr.format("%d");

            dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(heart_x - 1, second_y, font, heart_text, Graphics.TEXT_JUSTIFY_RIGHT);
         }
      }
   }

   //! Callback from Watch Face events delegate
   public function onPowerBudgetExceeded() as Void {
      _partialUpdatesAllowed = false;

      WatchUi.requestUpdate();
   }

   //! The device is exiting low power mode.
   //! Timers and animations may be started here in preparation for once-per-second updates.
   //! (the user has just looked at their watch)
   function onExitSleep() {
      restore_from_sleep = true;
      _isAwake = true;

      var dialDisplay = View.findDrawableById("analog") as AnalogDial;
      if (dialDisplay != null) {
         dialDisplay.enableSecondHand();
      }
   }

   //! The device is entering low power mode.
   //! Terminate any active timers and prepare for once-per-minute updates.
   function onEnterSleep() {
      _isAwake = false;

      // If the analog dial is used then disable the seconds hand.
      var dialDisplay = View.findDrawableById("analog") as AnalogDial;
      if (dialDisplay != null) {
         dialDisplay.disableSecondHand();
      }
      WatchUi.requestUpdate();
   }

   //! Create screen buffer, if enabled and memory available.
   //! Use screen buffer (to speed up onDraw; requires extra memory)
   //!
   //! @note Includes a runtime check to permanently disable memory-intensive
   //!       operations that have previously caused an application crash!
   //!       (out-of-memory errors are fatal so cannot be handled)
   function setupScreenBuffer(dc as Dc) as Void {
      var enable_buffering = Properties.getValue("enable_buffering") as Boolean;
      var err_runtime_oom = Application.Storage.getValue("err_runtime_oom") as Boolean?;
      var stats = System.getSystemStats();
      var free_mem = stats.freeMemory;

      // Rough estimate of screen buffer size, in bytes (based on default 256 colors)
      var buffer_size = dc.getWidth() * dc.getHeight() + 1000;

      // FIXED: Permanently disable memory-intensive operation if previously caused OOM crash
      // FIXED: Do not create screen buffer if insufficient memory (based on screen size)
      if (enable_buffering && _screen_buffer == null && err_runtime_oom != true && free_mem >= buffer_size + RUNTIME_MEM_MARGIN_MIN) {
         try {
            // Safety: Store semaphore to detect if operation causes runtime OOM fatal
            Application.Storage.setValue("err_runtime_oom", true);

            // TODO: Specify the color palette required, to reduce buffer memory size
            var params = {
               :width => dc.getWidth(),
               :height => dc.getHeight(),
            };
            if (Toybox.Graphics has :createBufferedBitmap) {
               _screen_buffer = Graphics.createBufferedBitmap(params).get() as BufferedBitmap;
            } else if (Toybox.Graphics has :BufferedBitmap) {
               _screen_buffer = new Graphics.BufferedBitmap(params);
            } else {
               // Not supported
               _screen_buffer = null;
            }

            // OK (not run during fatal oom; or catchable exceptions)
            Application.Storage.deleteValue("err_runtime_oom");
         } catch (ex) {
            // API 5.0.0 supports catching insufficient memory error
            // Do nothing - leave semaphore set
            _screen_buffer = null;
         }
      } else {
         // Unload
         _screen_buffer = null;
      }
   }

   //! Application replacement for setLayout(resource).
   //! Provides a lower memory footprint
   private function loadDrawables(dc as Dc) as Void {
      if (_backgroundView == null) {
         _backgroundView = new BackgroundView(null);
      }
   }

   //! Draw Drawables using our own device context (potentially a screen buffer)
   //! Used instead of View.onUpdate() to draw drawables
   function mainDrawComponents(dc as Dc) as Void {
      // XXX: Why is this clearing the background twice?
      dc.setColor(Graphics.COLOR_TRANSPARENT, gbackground_color);
      dc.clear();
      dc.setColor(gbackground_color, Graphics.COLOR_TRANSPARENT);
      dc.fillRectangle(0, 0, center_x * 2, center_y * 2);

      var bar1 = View.findDrawableById("aBarDisplay") as Drawable;
      var bar2 = View.findDrawableById("bBarDisplay") as Drawable;
      var bar3 = View.findDrawableById("cBarDisplay") as Drawable;
      var bar4 = View.findDrawableById("dBarDisplay") as Drawable;
      var bar5 = View.findDrawableById("eBarDisplay") as Drawable;
      var bar6 = View.findDrawableById("fBarDisplay") as Drawable;
      var bbar1 = View.findDrawableById("bUBarDisplay") as Drawable;
      var bbar2 = View.findDrawableById("tUBarDisplay") as Drawable;

      bar1.draw(dc);
      bar2.draw(dc);
      bar3.draw(dc);
      bar4.draw(dc);
      bar5.draw(dc);
      bar6.draw(dc);

      dc.setColor(gbackground_color, Graphics.COLOR_TRANSPARENT);
      dc.fillCircle(center_x, center_y, face_radius);
      // XXX: Move to call _backgroundView first
      if (_backgroundView != null) {
         _backgroundView.draw(dc);
      }
      bbar1.draw(dc);
      bbar2.draw(dc);

      var bgraph1 = View.findDrawableById("tGraphDisplay") as Drawable;
      var bgraph2 = View.findDrawableById("bGraphDisplay") as Drawable;
      bgraph1.draw(dc);
      bgraph2.draw(dc);

      if (_use_analog) {
         (View.findDrawableById("analog") as Drawable).draw(dc);
      } else {
         (View.findDrawableById("digital") as Drawable).draw(dc);
      }
   }

   function updateColorsInUse() as Void {
      var theme_code = Properties.getValue("theme_code") as Number;
      if (gtheme != theme_code || theme_code == 18) {
         if (theme_code == 18) {
            // Custom colors
            var background_color = Properties.getValue("background_color") as Number;
            var text_color = Properties.getValue("text_color") as Number;
            var accent_color = Properties.getValue("accent_color") as Number;
            var ticks_color = Properties.getValue("ticks_color") as Number;
            var bar_background_color = Properties.getValue("bar_background_color") as Number;
            var bar_indicator_color = Properties.getValue("bar_indicator_color") as Number;
            var bar_graph_color_top = Properties.getValue("bar_graph_color_top") as Number;
            var bar_graph_color_bottom = Properties.getValue("bar_graph_color_bottom") as Number;
            var hour_color = Settings.getOrDefault("hour_color", 0xff0000) as Lang.Number;
            var mins_color = Settings.getOrDefault("mins_color", 0xffffff) as Lang.Number;

            if (
               background_color != gbackground_color ||
               text_color != gmain_color ||
               hour_color != ghour_color ||
               mins_color != gmins_color ||
               accent_color != gaccent_color ||
               ticks_color != garc_color ||
               bar_background_color != gbar_color_back ||
               bar_indicator_color != gbar_color_indi ||
               bar_graph_color_top != gbar_color_0 ||
               bar_graph_color_bottom != gbar_color_1
            ) {
               // background
               gbackground_color = background_color;
               // main text
               gmain_color = text_color;
               // hour_color
               ghour_color = hour_color;
               // mins_color
               gmins_color = mins_color;
               // accent (dividers between complications)
               gaccent_color = accent_color;
               // ticks
               garc_color = ticks_color;
               // indicator pointing at the bar
               gbar_color_indi = bar_indicator_color;
               // bar background
               gbar_color_back = bar_background_color;
               // bar foreground/graph (top)
               gbar_color_0 = bar_graph_color_top;
               // bar foreground/graph (bottom)
               gbar_color_1 = bar_graph_color_bottom;
            }
         } else {
            var theme_pallete = WatchUi.loadResource(Rez.JsonData.theme_pallete) as Dictionary<String, Array<Number> >;
            var theme = theme_pallete[theme_code.toString()];
            if (theme != null) {
               // background
               gbackground_color = theme[0];
               // main text
               gmain_color = theme[1];
               // hour_color
               ghour_color = theme[2];
               // mins_color
               gmins_color = theme[1];
               // accent (dividers between complications)
               gaccent_color = theme[2];
               // ticks
               garc_color = theme[3];
               // indicator pointing at the bar
               gbar_color_indi = theme[4];
               // bar background
               gbar_color_back = theme[5];
               // bar foreground/graph (top)
               gbar_color_0 = theme[6];
               // bar foreground/graph (bottom)
               gbar_color_1 = theme[7];
            }
         }
         // set the global theme
         gtheme = theme_code;
      }
   }

   //! @note must have called readSettings() before calling this method
   function loadFonts() as Void {
      // Load global fonts
      if (small_digi_font == null) {
         small_digi_font = WatchUi.loadResource(Rez.Fonts.smadigi) as FontType;
      }

      if (_always_on_second || _always_on_heart) {
         // Loads always on (seconds/hr) Font
         if (_always_on_style == 0) {
            _always_on_digi_font = WatchUi.loadResource(Rez.Fonts.secodigi) as FontType;
         } else {
            _always_on_digi_font = WatchUi.loadResource(Rez.Fonts.xsecodigi) as FontType;
         }
      } else {
         // Unload
         _always_on_digi_font = null;
      }
   }

   //! @note must have called readSettings() and loadFonts() before this method
   function calcAlwaysOnLayout(dc as Dc) as Void {
      // Measure clipping area for seconds and heart rate, range [XX..2XX]
      var font = _always_on_digi_font; // remove type-checker ambiguity (ie. globals can be modified in diff thread)
      if (font != null) {
         var height = Graphics.getFontHeight(font);
         var width = dc.getTextWidthInPixels("200", font) + 2;
         second_font_height_half = height / 2;
         second_clip_size = [width, height];

         if (_use_analog) {
            // Analog Watchface
            second_x = center_x;
            second_y = center_y - second_font_height_half * 2;
         } else {
            // Digital Watchface
            // FIXME: Position of seconds / hr digits layout is done in DigitalDial!
         }
      }
   }

   //! Update Client Data
   //! Called by onUpdate(): on show; on settings changed; and every minute
   function updateClientData() as Void {
      var settings = System.getDeviceSettings();

      // Update last known location
      updateLastLocation();

      // Update Internal batteryInDays calculation
      if (!_hasBatteryInDays && isAnyDataFieldsInUse([FIELD_TYPE_BATTERY])) {
         if (_batteryMonitor == null) {
            _batteryMonitor = new BatteryMonitor();
         }
         if (_batteryMonitor != null) {
            _batteryMonitor.update();
         }
      } else {
         _batteryMonitor = null;
      }

      // Update background communication (web) clients
      // - watch must support background service (service delegate)
      // - watch must be connected to phone
      // @note `pendingWebRequests` are stored as Dictionary keys to prevent duplicate-entries
      //       that may be introduced due to multi-threaded nature of updates to pendingWebRequests
      if (_hasServiceDelegate && settings.phoneConnected) {
         var pendingWebRequests = {};

         // If AirQuality data fields in use
         if (isAnyDataFieldsInUse([FIELD_TYPE_AIR_QUALITY])) {
            if (IQAirClientHelper.needsDataUpdate()) {
               pendingWebRequests[IQAirClient.DATA_TYPE] = true;
               debug_print(:background, "need:$1$", IQAirClient.DATA_TYPE);
            }
         }

         // If Weather data fields in use
         if (isAnyDataFieldsInUse([FIELD_TYPE_TEMPERATURE_OUT, FIELD_TYPE_TEMPERATURE_HL, FIELD_TYPE_WEATHER, FIELD_TYPE_WIND])) {
            if (OpenWeatherClientHelper.needsDataUpdate()) {
               pendingWebRequests[OpenWeatherClient.DATA_TYPE] = true;
               debug_print(:background, "need:$1$", OpenWeatherClient.DATA_TYPE);
            }
         }

         Storage.setValue("PendingWebRequests", pendingWebRequests as Dictionary<PropertyKeyType, PropertyValueType>);

         // If there are any pending data requests (and phone is connected)
         if (pendingWebRequests.keys().size() > 0) {
            // Register for background temporal event as soon as possible.
            var lastTime = Background.getLastTemporalEventTime();

            if (lastTime != null) {
               var FIVE_MINUTES = 5 * Gregorian.SECONDS_PER_MINUTE;

               // Add a random jitter time to this client to avoid client-synchronization load issues
               // (e.g. at every top-of minute all clients send their request to server)
               var jitterTime = Math.rand() % FIVE_MINUTES;

               // Events scheduled for a time in the past trigger immediately.
               var nextTime = lastTime.add(new Time.Duration(FIVE_MINUTES + jitterTime));
               Background.registerForTemporalEvent(nextTime);
            } else {
               Background.registerForTemporalEvent(Time.now());
            }
         }
      }
   }

   function getArcComplicationSettingFieldId(angle as Number) as Number {
      return Properties.getValue("comp" + angle + "h") as Number;
   }

   function getBarDataComplicationSettingFieldId(position as Number) as Number {
      if (position == 0) {
         // upper
         return Properties.getValue("compbart") as Number;
      } else {
         // lower
         return Properties.getValue("compbarb") as Number;
      }
   }

   function getGraphComplicationFieldId(position as Number) as Number {
      if (position == 0) {
         return Properties.getValue("compgrapht") as Number;
      } else {
         return Properties.getValue("compgraphb") as Number;
      }
   }

   //! Populates a list of all the data field ids in use
   //! Used by isAnyDataFieldsInUse()
   function updateCurrentFieldIdsInUse() as Void {
      var fieldIds = [
         getArcComplicationSettingFieldId(12),
         getArcComplicationSettingFieldId(10),
         getArcComplicationSettingFieldId(2),
         getArcComplicationSettingFieldId(4),
         getArcComplicationSettingFieldId(6),
         getArcComplicationSettingFieldId(8),
         getBarDataComplicationSettingFieldId(0),
         getBarDataComplicationSettingFieldId(1),
         getGraphComplicationFieldId(0),
         getGraphComplicationFieldId(1),
      ];

      _currentFieldsIdsInUse = fieldIds;
   }

   function isAnyDataFieldsInUse(fieldIds as Array<Number>) as Boolean {
      for (var i = 0; i < fieldIds.size(); i++) {
         var id = fieldIds[i];
         if (_currentFieldsIdsInUse.indexOf(id) != -1) {
            return true;
         }
      }
      return false;
   }

   //! Update last (known) location.
   //! Persists location for later use (e.g. after app restart)
   //! @note 2025.08.18 data moved from app Property to Storage class
   function updateLastLocation() as Void {
      // Attempt to update current location, to be used by Sunrise/Sunset, Weather, Air Quality.
      // If current location available from current activity, save it in case it goes "stale" and can not longer be retrieved.
      var activityInfo = Activity.getActivityInfo();
      if (activityInfo != null && activityInfo.currentLocation != null) {
         // Save current location to globals
         var degrees = activityInfo.currentLocation.toDegrees(); // Array of Doubles.
         gLocationLat = degrees[0].toFloat();
         gLocationLon = degrees[1].toFloat();

         Storage.setValue("LastLocation", [gLocationLat, gLocationLon]);
      } else {
         // current location is not available, read stored value from Object Store, being careful not to overwrite a valid
         // in-memory value with an invalid stored one.
         var storedLocation = Storage.getValue("LastLocation") as Array<Float>?;
         if (storedLocation != null) {
            gLocationLat = storedLocation[0];
            gLocationLon = storedLocation[1];
         }
      }
   }
}

//! Receive events on a Watch Face.
class InfocalViewDelegate extends WatchUi.WatchFaceDelegate {
   private var _view as InfocalView;

   function initialize(view as InfocalView) {
      WatchFaceDelegate.initialize();
      _view = view;
   }

   //! Handle a partial update exceeding the power budget.
   //!
   //! If the onPartialUpdate() callback of the associated WatchFace exceeds the power budget of the device,
   //! this method will be called with information about the limits that were exceeded.
   function onPowerBudgetExceeded(powerInfo as WatchFacePowerInfo) as Void {
      debug_print(:powerbudget, "PWR: $1$ > $2$", [powerInfo.executionTimeAverage, powerInfo.executionTimeLimit]);

      _view.onPowerBudgetExceeded();
   }
}
