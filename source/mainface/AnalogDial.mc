using Toybox.Math;
using Toybox.Graphics;
using Toybox.Time.Gregorian as Date;

import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;


class AnalogDial extends Drawable {
   private var _secondHandEnabled = false;

   private var hour_font_1,
      hour_font_2,
      hour_font_3,
      hour_font_4,
      hour_font_5,
      hour_font_6;
   private var minu_font_1,
      minu_font_2,
      minu_font_3,
      minu_font_4,
      minu_font_5,
      minu_font_6;
   private var hour_1 as Array<Array<Number>>?;
   private var hour_2 as Array<Array<Number>>?;
   private var hour_3 as Array<Array<Number>>?;
   private var hour_4 as Array<Array<Number>>?;
   private var hour_5 as Array<Array<Number>>?;
   private var hour_6 as Array<Array<Number>>?;
   private var minu_1 as Array<Array<Number>>?;
   private var minu_2 as Array<Array<Number>>?;
   private var minu_3 as Array<Array<Number>>?;
   private var minu_4 as Array<Array<Number>>?;
   private var minu_5 as Array<Array<Number>>?;
   private var minu_6 as Array<Array<Number>>?;

   var offset_x = 0;
   var offset_y = 0;
   var offset_rad = 0;

   private var factor = 1;

   function initialize(params) {
      Drawable.initialize(params);

      if (center_x == 195) {
         factor = 2;
      }
   }

   //! Draw an object to the device context (Dc).
   //!
   //! This method assumes that the device context has already been configured to the proper options.
   //! Derived classes should check the isVisible property, if it exists, before trying to draw.
   public function draw(dc as Dc) {
      if (Properties.getValue("use_analog") == false) {
         return;
      }

      dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);

      var clockTime = System.getClockTime();
      drawHourHands(dc, clockTime);
      drawMinuteHands(dc, clockTime);

      // Draw seconds hand if enabled, and not in power save mode
      if (  (_secondHandEnabled)
         && (Properties.getValue("power_save_mode") == false)) {

         dc.setColor(gsecondary_color, Graphics.COLOR_TRANSPARENT);
         drawSecondHand(dc, clockTime);
      }
   }

   public function disableSecondHand() {
      _secondHandEnabled = false;
   }

   public function enableSecondHand() {
      _secondHandEnabled = true;
   }

   private function unloadFontsHour() {
      hour_font_1 = null;
      hour_1 = null;
      hour_font_2 = null;
      hour_2 = null;
      hour_font_3 = null;
      hour_3 = null;
      hour_font_4 = null;
      hour_4 = null;
      hour_font_5 = null;
      hour_5 = null;
      hour_font_6 = null;
      hour_6 = null;
   }

   private function unloadFontsMinute() {
      minu_font_1 = null;
      minu_1 = null;
      minu_font_2 = null;
      minu_2 = null;
      minu_font_3 = null;
      minu_3 = null;
      minu_font_4 = null;
      minu_4 = null;
      minu_font_5 = null;
      minu_5 = null;
      minu_font_6 = null;
      minu_6 = null;
   }

   private function loadFontsHour(hour_i as Number) as Void {
      if (hour_i >= 50) {
         hour_font_6 = loadResource(Rez.Fonts.hour_6);
         hour_6 = loadResource(Rez.JsonData.hour_6_data);
      } else if (hour_i >= 40) {
         hour_font_5 = loadResource(Rez.Fonts.hour_5);
         hour_5 = loadResource(Rez.JsonData.hour_5_data);
      } else if (hour_i >= 30) {
         hour_font_4 = loadResource(Rez.Fonts.hour_4);
         hour_4 = loadResource(Rez.JsonData.hour_4_data);
      } else if (hour_i >= 20) {
         hour_font_3 = loadResource(Rez.Fonts.hour_3);
         hour_3 = loadResource(Rez.JsonData.hour_3_data);
      } else if (hour_i >= 10) {
         hour_font_2 = loadResource(Rez.Fonts.hour_2);
         hour_2 = loadResource(Rez.JsonData.hour_2_data);
      } else {
         hour_font_1 = loadResource(Rez.Fonts.hour_1);
         hour_1 = loadResource(Rez.JsonData.hour_1_data);
      }
   }

   private function loadFontsMinute(minu_i as Number) as Void {
      if (minu_i >= 50) {
         minu_font_6 = loadResource(Rez.Fonts.minu_6);
         minu_6 = loadResource(Rez.JsonData.minu_6_data);
      } else if (minu_i >= 40) {
         minu_font_5 = loadResource(Rez.Fonts.minu_5);
         minu_5 = loadResource(Rez.JsonData.minu_5_data);
      } else if (minu_i >= 30) {
         minu_font_4 = loadResource(Rez.Fonts.minu_4);
         minu_4 = loadResource(Rez.JsonData.minu_4_data);
      } else if (minu_i >= 20) {
         minu_font_3 = loadResource(Rez.Fonts.minu_3);
         minu_3 = loadResource(Rez.JsonData.minu_3_data);
      } else if (minu_i >= 10) {
         minu_font_2 = loadResource(Rez.Fonts.minu_2);
         minu_2 = loadResource(Rez.JsonData.minu_2_data);
      } else {
         minu_font_1 = loadResource(Rez.Fonts.minu_1);
         minu_1 = loadResource(Rez.JsonData.minu_1_data);
      }
   }

   /////////////////////////
   /// antialias handler ///
   /////////////////////////

   private function drawHourHands(dc as Dc, clockTime as System.ClockTime) as Void {
      var hour_i = getHourHandFragment(clockTime) % 60;

      try {
         loadFontsHour(hour_i);
         if (hour_i >= 50) {
            drawTiles(hour_6[(hour_i - 50).toNumber()], hour_font_6, dc, hour_i);
         } else if (hour_i >= 40) {
            drawTiles(hour_5[(hour_i - 40).toNumber()], hour_font_5, dc, hour_i);
         } else if (hour_i >= 30) {
            drawTiles(hour_4[(hour_i - 30).toNumber()], hour_font_4, dc, hour_i);
         } else if (hour_i >= 20) {
            drawTiles(hour_3[(hour_i - 20).toNumber()], hour_font_3, dc, hour_i);
         } else if (hour_i >= 10) {
            drawTiles(hour_2[(hour_i - 10).toNumber()], hour_font_2, dc, hour_i);
         } else {
            drawTiles(hour_1[hour_i.toNumber()], hour_font_1, dc, hour_i);
         }
      } finally {
         unloadFontsHour();
      }
   }

   private function drawMinuteHands(dc as Dc, clockTime as System.ClockTime) as Void {
      var minu_i = clockTime.min;
      try {
         loadFontsMinute(minu_i);

         if (minu_i >= 50) {
            drawTiles(minu_6[(minu_i - 50).toNumber()], minu_font_6, dc, minu_i);
         } else if (minu_i >= 40) {
            drawTiles(minu_5[(minu_i - 40).toNumber()], minu_font_5, dc, minu_i);
         } else if (minu_i >= 30) {
            drawTiles(minu_4[(minu_i - 30).toNumber()], minu_font_4, dc, minu_i);
         } else if (minu_i >= 20) {
            drawTiles(minu_3[(minu_i - 20).toNumber()], minu_font_3, dc, minu_i);
         } else if (minu_i >= 10) {
            drawTiles(minu_2[(minu_i - 10).toNumber()], minu_font_2, dc, minu_i);
         } else {
            drawTiles(minu_1[minu_i.toNumber()], minu_font_1, dc, minu_i);
         }
      } finally {
         unloadFontsMinute();
      }
   }

   private function drawSecondHand(dc as Dc, clockTime as System.ClockTime) as Void {
      var base_radius = center_x == 109 ? 0.0 : 11.0;
      var minu_radius = center_x - 23.0;
      var base_thick = 3.0;
      var radian = 2 * (clockTime.sec / 60.0) * Math.PI - 0.5 * Math.PI;

      var startx = Globals.convertCoorX(radian, base_radius);
      var starty = Globals.convertCoorY(radian, base_radius);
      var endx = Globals.convertCoorX(radian, minu_radius);
      var endy = Globals.convertCoorY(radian, minu_radius);

      dc.setColor(gsecondary_color, Graphics.COLOR_TRANSPARENT);
      dc.setPenWidth(base_thick);
      dc.drawLine(startx, starty, endx, endy);
   }

   //! Draw *image* font based on parameters packed in jsondata
   //!
   //! - The hour/minute/bar images are drawn from custom made fonts
   //! - The JsonData files contain packed instructions on how to draw
   //!   the full image from the font characters.
   //! - Each JsonData number represents an image part (tile) with byte encoding:
   //!   [ flags|char|xpos|ypos ]
   private function drawTiles(packed_array as Array<Number>, font, dc, index) {
      var radian = (index.toFloat() / 60.0) * (2 * 3.1415) - 0.5 * 3.1415;
      var offset_rad_x = Globals.convertCoorX(radian, offset_rad) - center_x;
      var offset_rad_y = Globals.convertCoorY(radian, offset_rad) - center_y;
      for (var i = 0; i < packed_array.size(); i++) {
         var val = packed_array[i];
         var flag = (val >> 24) & 255;
         var code = (val >> 16) & 255;
         var xpos = (val >> 8) & 255;
         var ypos = (val >> 0) & 255;
         var xpos_bonus = (flag & 0x01) == 0x01 ? 1 : 0;
         var ypos_bonus = (flag & 0x10) == 0x10 ? 1 : 0;
         dc.drawText(
            (xpos * factor + xpos_bonus + offset_x - offset_rad_x).toNumber(),
            (ypos * factor + ypos_bonus + offset_y - offset_rad_y).toNumber(),
            font,
            code.toChar().toString(),
            Graphics.TEXT_JUSTIFY_LEFT
         );
      }
   }

   //! Returns the 24hr clock time (in increments of 1/5 hours) [0..120]
   private function getHourHandFragment(clockTime as System.ClockTime) as Number {
      var hour = clockTime.hour;
      var minute = clockTime.min;
      return (((hour * 60.0 + minute) / (12.0 * 60)) * 60.0).toNumber();
   }

}
