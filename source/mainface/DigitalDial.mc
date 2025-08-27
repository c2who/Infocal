using Toybox.WatchUi as Ui;
using Toybox.Math;
using Toybox.System;

import Toybox.Application;
import Toybox.Graphics;

class DigitalDial extends Ui.Drawable {
   ////////////////////////
   /// common variables ///
   ////////////////////////
   private var digitalFont, xdigitalFont;
   private var midDigitalFont;
   private var midBoldFont;
   private var midSemiFont;
   private var xmidBoldFont;
   private var xmidSemiFont;
   private var barRadius;

   ///////////////////////////////
   /// non-antialias variables ///
   ///////////////////////////////

   private var alignment;

   private var bonusy_smallsize;

   function initialize(params) {
      Drawable.initialize(params);
      barRadius = center_x - 10;
      alignment = Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER;

      bonusy_smallsize = 0;
      if (center_x == 195) { // 390x390 screen
         bonusy_smallsize = -35;
      }
   }

   private function unloadFonts() {
      midBoldFont = null;
      midSemiFont = null;
      xmidBoldFont = null;
      xmidSemiFont = null;
      xdigitalFont = null;
      digitalFont = null;
      midDigitalFont = null;
   }

   // TODO: Simplify font handling (remove duplicate vars)
   private function loadFonts() {
      var digital_style = Properties.getValue("digital_style");
      if (digital_style == 0) {
         // big
         digitalFont = Ui.loadResource(Rez.Fonts.bigdigi);
         midDigitalFont = Ui.loadResource(Rez.Fonts.middigi);

      } else if (digital_style == 1) {
         // small
         midBoldFont = Ui.loadResource(Rez.Fonts.midbold);
         midSemiFont = Ui.loadResource(Rez.Fonts.midsemi);

      } else if (digital_style == 2) {
         // extra big
         xdigitalFont = Ui.loadResource(Rez.Fonts.xbigdigi);
         midDigitalFont = Ui.loadResource(Rez.Fonts.middigi);

      } else {
         // medium
         xmidBoldFont = Ui.loadResource(Rez.Fonts.xmidbold);
         xmidSemiFont = Ui.loadResource(Rez.Fonts.xmidsemi);
      }
   }

   //! Draw an object to the device context (Dc).
   //!
   //! This method assumes that the device context has already been configured to the proper options.
   //! Derived classes should check the isVisible property, if it exists, before trying to draw.
   function draw(dc as Dc) as Void {
      if (Properties.getValue("use_analog") == true) {
         return;
      }

      try {
         loadFonts();
         var clockTime = System.getClockTime();
         drawdigitalDial(dc, clockTime);

      } finally {
         unloadFonts();
      }
   }

   function drawdigitalDial(dc as Dc, clockTime as System.ClockTime) as Void {
      var currentSettings = System.getDeviceSettings();

      var hour = clockTime.hour;
      if (!currentSettings.is24Hour) {
         hour = hour % 12;
         hour = hour == 0 ? 12 : hour;
      }
      var minute = clockTime.min;

      var leading_zeros = Properties.getValue("zero_leading_digital");
      var number_formater = leading_zeros ? "%02d" : "%d";

      var digital_style = Properties.getValue("digital_style");
      var alwayon_style = Properties.getValue("always_on_style");

      if (digital_style == 0 || digital_style == 2) {
         // Big number in center_x style
         var big_number_type = Properties.getValue("big_number_type");
         var bignumber = (big_number_type == 0) ? minute : hour;
         var smallnumber = (big_number_type == 0) ? hour : minute;

         var target_center_font = digital_style == 0 ? digitalFont : xdigitalFont;

         // Draw center_x number
         var bigText = bignumber.format(number_formater);
         dc.setPenWidth(1);
         dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
         var h = dc.getFontHeight(target_center_font);
         var w = dc.getTextWidthInPixels(bigText, target_center_font);
         dc.drawText(
            center_x,
            center_y - h / 4,
            target_center_font,
            bigText,
            alignment
         );

         // Draw stripes
         if (Properties.getValue("big_num_stripes")) {
            dc.setColor(gbackground_color, Graphics.COLOR_TRANSPARENT);
            var w2 = dc.getTextWidthInPixels("\\", target_center_font);
            dc.drawText(
               center_x + w2 - w / 2,
               center_y - h / 4,
               target_center_font,
               "\\",
               Graphics.TEXT_JUSTIFY_VCENTER
            );
         }

         // FIXME - Move to InfocalView: Calculate seconds/hr global offsets
         var f_align = digital_style == 0 ? 62 : 71;
         if (center_x == 195) {
            f_align = f_align + 40;
         }
         var second_x_l = center_x + w / 2 + 3;
         var heart_x_l = center_x - w / 2 - 3;
         var second_y_l = 0;
         if (center_x == 109 && digital_style == 2) {
            second_y_l =
               center_y -
               second_font_height_half / 2 -
               (alwayon_style == 0 ? 3 : 6);
         } else {
            second_y_l =
               center_y +
               (h - f_align) / 2 -
               second_font_height_half * 2 +
               (alwayon_style == 0 ? 0 : 5);
         }

         // Draw digital info (small number, date)
         // Calculate alignment
         var bonus_alignment = 0;
         var extra_info_alignment = 0;
         var vertical_alignment = 0;
         if (center_x == 109) {
            bonus_alignment = 4;
            if (digital_style == 2) {
               bonus_alignment = 4;
               vertical_alignment = -23;
            }
         } else if (center_x == 120 && digital_style == 2) {
            bonus_alignment = 6;
            extra_info_alignment = 4;
         }
         var target_info_x = center_x * 1.6;
         var left_digital_info = Properties.getValue("left_digital_info");
         if (left_digital_info) {
            target_info_x = center_x * 0.4;
            bonus_alignment = -bonus_alignment;
            extra_info_alignment = -extra_info_alignment;
         }

         // Draw background of date
         // This is needed to prevent power save mode from re-rendering
         dc.setColor(gbackground_color, Graphics.COLOR_TRANSPARENT);
         dc.setPenWidth(20);
         if (left_digital_info) {
            dc.drawArc(
               center_x,
               center_y,
               barRadius,
               Graphics.ARC_CLOCKWISE,
               180 - 10,
               120 + 10
            );
         } else {
            dc.drawArc(
               center_x,
               center_y,
               barRadius,
               Graphics.ARC_CLOCKWISE,
               60 - 10,
               0 + 10
            );
         }
         dc.setPenWidth(1);

         // Draw small number
         dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
         var h2 = dc.getFontHeight(midDigitalFont);
         dc.drawText(
            target_info_x + bonus_alignment,
            center_y * 0.7 - h2 / 4 + 5 + vertical_alignment,
            midDigitalFont,
            smallnumber.format(number_formater),
            alignment
         );

         // If there is no room for the date, return and don't draw it
         if (center_x == 109 && digital_style == 2) {
            return;
         }

         // Draw date
         var dateText = Globals.getFormattedDate();
         dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
         var h3 = dc.getFontHeight(small_digi_font);
         dc.drawText(
            target_info_x - bonus_alignment + extra_info_alignment,
            center_y * 0.4 - h3 / 4 + 7,
            small_digi_font,
            dateText,
            alignment
         );

         // Draw horizontal line
         var w3 = dc.getTextWidthInPixels(dateText, small_digi_font);
         dc.setPenWidth(2);
         dc.setColor(gsecondary_color, Graphics.COLOR_TRANSPARENT);
         dc.drawLine(
            target_info_x - bonus_alignment - w3 / 2 + extra_info_alignment,
            center_y * 0.5 + 7,
            target_info_x - bonus_alignment + w3 / 2 + extra_info_alignment,
            center_y * 0.5 + 7
         );

         // Save globals
         second_x = second_x_l;
         second_y = second_y_l;
         heart_x = heart_x_l;

      } else if (digital_style == 1 || digital_style == 3) {
         // All numbers in center_x style
         var hourText = hour.format(number_formater);
         var minuText = minute.format("%02d");

         var boldF = digital_style == 3 ? xmidBoldFont : midBoldFont;
         var normF = digital_style == 3 ? xmidSemiFont : midSemiFont;

         // BUG: Digital font is bottom-aligned at 2x character height (font bounds are incorrect)
         var height = dc.getFontHeight(boldF);
         var y_offset = height * 0.75;
         var hourW = dc.getTextWidthInPixels(hourText, boldF);
         var minuW = dc.getTextWidthInPixels(minuText, normF);
         var width = hourW + minuW + 6;
         var left = center_x - width/2;

         // Draw time
         dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
         dc.drawText(
            left,
            center_y - y_offset,
            boldF,
            hourText,
            Graphics.TEXT_JUSTIFY_LEFT
         );
         dc.drawText(
            left + hourW + 6,
            center_y - y_offset,
            normF,
            minuText,
            Graphics.TEXT_JUSTIFY_LEFT
         );

         // FIXME - Move to InfocalView: Save globals - Calculate Layout of seconds and heart rate (with widest digits)
         second_x = center_x + width/2 + 1;
         heart_x = center_x - width/2 - 1;
         second_y = center_y - second_font_height_half; // centre-justified
      }
   }
}
