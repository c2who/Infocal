using Toybox.Application as App;
using Toybox.ActivityMonitor as Mon;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Time.Gregorian as Date;
using Toybox.WatchUi;

import Toybox.Lang;

var small_digi_font = null;
var second_digi_font = null;
var second_x = 160;
var second_y = 140;
var heart_x = 80;
var center_x;
var center_y;

var second_font_height_half = 7;
var second_background_color = 0x000000;
var second_font_color = 0xffffff;
var second_clip_size = null;

// theming
var gbackground_color = 0x000000;
var gmain_color = 0xffffff;
var gsecondary_color = 0xff0000;
var garc_color = 0x555555;
var gbar_color_indi = 0xaaaaaa;
var gbar_color_back = 0x550000;
var gbar_color_0 = 0xffff00;
var gbar_color_1 = 0x0000ff;

var gtheme = -1;

var last_battery_percent = -1;
var last_hour_consumption = -1;

class HuwaiiView extends WatchUi.WatchFace {
   private var _layout_changed as Lang.Boolean = false;
   private var last_draw_minute = -1;
   private var last_resume_milli = 0;
   private var restore_from_resume = false;

   private var last_battery_hour = null;

   private var font_height_half = 7;

   private var face_radius;

   private var did_clear = false;
   private var _is_partial_updates_active as Boolean = false;

   //! Screen buffer stores a copy of the bitmap rendered to the screen.
   //! This avoids having to fully redraw the screen each update, improving battery life
   //! @note Screen bufferring can only be used on (newer) devices with larger memory,
   //!       on lower-end devices it must be disabled to avoid out of memory errors.
   private var _screen_buffer as Graphics.BufferedBitmap? = null;

   function initialize() {
      WatchFace.initialize();
   }

   // Load your resources here
   function onLayout(dc) {
      _layout_changed = false;

      // Set globals
      center_x = dc.getWidth() / 2;
      center_y = dc.getHeight() / 2;
      face_radius = center_x - ((18 * center_x) / 120).toNumber();

      // Load global fonts
      if (small_digi_font == null) {
         small_digi_font = WatchUi.loadResource(Rez.Fonts.smadigi);
      }

      // Load Watchface drawables from layout.xml (creates all Ui.Drawable classes)
      setLayout(Rez.Layouts.WatchFace(dc));

      updateLayoutColors();
      updateLayoutFonts(dc);

      setupScreenBuffer(dc);
   }

   // Called when this View is brought to the foreground. Restore
   // the state of this View and prepare it to be shown. This includes
   // loading resources into memory.
   function onShow() {
      last_draw_minute = -1;
      restore_from_resume = true;
      App.getApp().checkPendingWebRequests();
   }

   function onSettingsChanged() {
      last_draw_minute = -1;
      _layout_changed = true;
   }

   //! Create screen buffer, if enabled and memory available.
   //! Use screen buffer (to speed up onDraw; requires extra memory)
   //!
   //! @note Includes a runtime check to permanently disable memory-intensive
   //!       operations that have previously caused an application crash!
   //!       (out-of-memory errors are fatal so cannot be handled)
   function setupScreenBuffer(dc) as Void {
      var enable_buffering = Application.getApp().getProperty("enable_buffering");
      var err_runtime_oom = Application.Storage.getValue("err_runtime_oom");

      // FIXED: Permanently disable memory-intensive operation if previously caused OOM crash
      if (enable_buffering && (_screen_buffer == null) && (err_runtime_oom != true)) {
         
         try {
            // Safety: Do not allocate screen buffer on low-memory devices (to avoid OOM crash)
            Application.Storage.setValue("err_runtime_oom", true);
            
            // Allow buffer (requires 65KB+ free memory)
            var params = {
               :width => dc.getWidth(),
               :height => dc.getHeight(),
            };
            if (Toybox.Graphics has :createBufferedBitmap) {
               _screen_buffer = Graphics.createBufferedBitmap(params).get();
            } else if (Toybox.Graphics has :BufferedBitmap) {
               _screen_buffer = new Graphics.BufferedBitmap(params);
            } else {
               // Not supported
               _screen_buffer = null;
            }
         } finally {
            // OK
            Application.Storage.deleteValue("err_runtime_oom");
         }
      } else {
         // Unload
         _screen_buffer = null;
      }
   }

   function calculateBatteryConsumption() {
      // Calculate battery consumption in days
      var time_now = Time.now();
      if (last_battery_hour == null) {
         last_battery_hour = time_now;
         last_battery_percent = System.getSystemStats().battery;
         last_hour_consumption = -1;
      } else if (time_now.compare(last_battery_hour) >= 60 * 60) {
         // 60 min
         last_battery_hour = time_now;
         var current_battery = System.getSystemStats().battery;
         var temp_last_battery_percent = last_battery_percent;
         var temp_last_hour_consumption = temp_last_battery_percent - current_battery;
         if (temp_last_hour_consumption < 0) {
            temp_last_hour_consumption = -1;
         }
         if (temp_last_hour_consumption > 0) {
            App.getApp().setProperty(
               "last_hour_consumption",
               temp_last_hour_consumption
            );

            var consumption_history =
               App.getApp().getProperty("consumption_history");
            if (consumption_history == null) {
               App.getApp().setProperty("consumption_history", [
                  temp_last_hour_consumption,
               ]);
            } else {
               consumption_history.add(temp_last_hour_consumption);
               if (consumption_history.size() > 24) {
                  var object0 = consumption_history[0];
                  consumption_history.remove(object0);
               }
               App.getApp().setProperty(
                  "consumption_history",
                  consumption_history
               );
            }
         }
         last_battery_percent = current_battery;
         last_hour_consumption = temp_last_hour_consumption;
      }
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
      if (_layout_changed) {
         onLayout(screenDc);
      }
      
      if (minute_changed) {
         calculateBatteryConsumption();
      }
      
      if (restore_from_resume || minute_changed) {
         App.getApp().checkPendingWebRequests();
      }

      // On older watches, can get away with only performing full update every minute
      // (do not need to perform full redraw on every update as screen is not cleared)
      var power_save_mode = Application.getApp().getProperty("power_save_mode");
      if ((power_save_mode == false) || minute_changed || _layout_changed || restore_from_resume) {
         // Use screen_buffer if available
         var dc = (_screen_buffer != null) ? _screen_buffer.getDc() : screenDc;

         mainDrawComponents(dc);

         // Copy screen buffer to screen
         if (_screen_buffer != null) {
            screenDc.drawBitmap(0, 0, _screen_buffer);
         }
      }

      // Reset draw state flags
      last_draw_minute = clockTime.min;
      restore_from_resume = false;
      minute_changed = false;

      // Update seconds and hr fields in high power mode
      if (_is_partial_updates_active) {
         onPartialUpdate(screenDc);
      }
   }

   function mainDrawComponents(dc) {
      dc.setColor(Graphics.COLOR_TRANSPARENT, gbackground_color);
      dc.clear();
      dc.setColor(gbackground_color, Graphics.COLOR_TRANSPARENT);
      dc.fillRectangle(0, 0, center_x * 2, center_y * 2);

      var backgroundView = View.findDrawableById("background");
      var bar1 = View.findDrawableById("aBarDisplay");
      var bar2 = View.findDrawableById("bBarDisplay");
      var bar3 = View.findDrawableById("cBarDisplay");
      var bar4 = View.findDrawableById("dBarDisplay");
      var bar5 = View.findDrawableById("eBarDisplay");
      var bar6 = View.findDrawableById("fBarDisplay");
      var bbar1 = View.findDrawableById("bUBarDisplay");
      var bbar2 = View.findDrawableById("tUBarDisplay");

      bar1.draw(dc);
      bar2.draw(dc);
      bar3.draw(dc);
      bar4.draw(dc);
      bar5.draw(dc);
      bar6.draw(dc);

      dc.setColor(gbackground_color, Graphics.COLOR_TRANSPARENT);
      dc.fillCircle(center_x, center_y, face_radius);

      backgroundView.draw(dc);
      bbar1.draw(dc);
      bbar2.draw(dc);

      var bgraph1 = View.findDrawableById("tGraphDisplay");
      var bgraph2 = View.findDrawableById("bGraphDisplay");
      bgraph1.draw(dc);
      bgraph2.draw(dc);

      if (Application.getApp().getProperty("use_analog")) {
         View.findDrawableById("analog").draw(dc);
      } else {
         View.findDrawableById("digital").draw(dc);
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
   //! @internal Calls to System.println() and System.print() will not execute on devices when this function is being 
   //!           invoked, but can be used in the device *simulator*.
   (:partial_update)
   function onPartialUpdate(dc) {
      _is_partial_updates_active = true;

      if (Application.getApp().getProperty("use_analog")) {
         // not supported
         return;
      }

      if (Application.getApp().getProperty("always_on_second")) {
         var clockTime = System.getClockTime();
         var second_text = clockTime.sec.format("%02d");

         dc.setClip(
            second_x,
            second_y,
            second_clip_size[0],
            second_clip_size[1]
         );
         dc.setColor(Graphics.COLOR_TRANSPARENT, gbackground_color);
         dc.clear();
         dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
         dc.drawText(
            second_x,
            second_y,
            second_digi_font,
            second_text,
            Graphics.TEXT_JUSTIFY_LEFT
         );
      }

      if (Application.getApp().getProperty("always_on_heart")) {
         var width = second_clip_size[0];
         dc.setClip(
            heart_x - width - 1,
            second_y,
            width + 2,
            second_clip_size[1]);
         dc.setColor(Graphics.COLOR_TRANSPARENT, gbackground_color);
         dc.clear();

         // fix: remove (and do not draw) heart rate if invalid
         var h = _retrieveHeartrate();
         if ((h != null) && (h > 0)) {
            var heart_text = h.format("%d");
         
            dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
               heart_x - 1,
               second_y,
               second_digi_font,
               heart_text,
               Graphics.TEXT_JUSTIFY_RIGHT
            );
         }
      }
      // Finally, remove any applied dc clipping
      dc.clearClip();
   }

   //! Handle a partial update exceeding the power budget.
   //! 
   //! If the onPartialUpdate() callback of the associated WatchFace exceeds the power budget of the device, 
   //! this method will be called with information about the limits that were exceeded.
   function onPowerBudgetExceeded(powerInfo as WatchUi.WatchFacePowerInfo) as Void {
      // TODO: DEBUG: Write out power error information

      // Watch has shut down partial updates
      _is_partial_updates_active = false;
   }

   // Called when this View is removed from the screen. Save the
   // state of this View here. This includes freeing resources from
   // memory.
   function onHide() {
   }

   //! The device is exiting low power mode.
   //! Timers and animations may be started here in preparation for once-per-second updates.
   //! (the user has just looked at their watch)
   function onExitSleep() {
      var dialDisplay = View.findDrawableById("analog");
      if (dialDisplay != null) {
         dialDisplay.enableSecondHand();
      }
      App.getApp().checkPendingWebRequests();
   }

   //! The device is entering low power mode.
   //! Terminate any active timers and prepare for once-per-minute updates.
   function onEnterSleep() {
      // If the analog dial is used then disable the seconds hand.
      if (Application.getApp().getProperty("use_analog")) {
         var dialDisplay = View.findDrawableById("analog");
         if (dialDisplay != null) {
            dialDisplay.disableSecondHand();
         }
      }
   }

   function updateLayoutColors() {
      var theme_code = Application.getApp().getProperty("theme_code");
      if (gtheme != theme_code || theme_code == 18) {
         if (theme_code == 18) {
            var background_color =
               Application.getApp().getProperty("background_color");
            var text_color =
               Application.getApp().getProperty("text_color");
            var accent_color =
               Application.getApp().getProperty("accent_color");
            var ticks_color =
               Application.getApp().getProperty("ticks_color");
            var bar_background_color =
               Application.getApp().getProperty(
                  "bar_background_color"
               );
            var bar_indicator_color =
               Application.getApp().getProperty("bar_indicator_color");
            var bar_graph_color_top = Application.getApp().getProperty(
               "bar_graph_color_top"
            );
            var bar_graph_color_bottom =
               Application.getApp().getProperty(
                  "bar_graph_color_bottom"
               );
            if (
               background_color != gbackground_color ||
               text_color != gmain_color ||
               accent_color != gsecondary_color ||
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
               // accent (dividers between complications)
               gsecondary_color = accent_color;
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
            var theme_pallete = WatchUi.loadResource(
               Rez.JsonData.theme_pallete
            );
            var theme = theme_pallete["" + theme_code];
            // background
            gbackground_color = theme[0];
            // main text
            gmain_color = theme[1];
            // accent (dividers between complications)
            gsecondary_color = theme[2];
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
         // set the global theme
         gtheme = theme_code;
      }
   }

   function updateLayoutFonts(dc as Graphics.Dc) {
      var always_on_style = Application.getApp().getProperty("always_on_style");
      if (always_on_style == 0) {
         second_digi_font = WatchUi.loadResource(Rez.Fonts.secodigi);
      } else {
         second_digi_font = WatchUi.loadResource(Rez.Fonts.xsecodigi);
      }

      // Measure clipping area for seconds and heart rate AOD
      var width  = dc.getTextWidthInPixels("200", second_digi_font) + 2;
      var height = Graphics.getFontHeight(second_digi_font);
      second_font_height_half = height/2;
      second_clip_size = [width, height];
   }

   function removeAllFonts() {
      View.findDrawableById("analog").removeFont();
      View.findDrawableById("digital").removeFont();
   }
}
