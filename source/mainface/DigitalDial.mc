using Toybox.WatchUi as Ui;
using Toybox.Math;
using Toybox.System;

import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;

import Settings;

class DigitalDial extends Ui.Drawable {
   private var barRadius as Number;
   private var alignment as Number;

   function initialize(params as DrawableInitOptions) {
      Drawable.initialize(params);

      barRadius = center_x - 10;
      alignment = Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER;
   }

   //! Draw an object to the device context (Dc).
   //!
   //! This method assumes that the device context has already been configured to the proper options.
   //! Derived classes should check the isVisible property, if it exists, before trying to draw.
   function draw(dc as Dc) as Void {
      if (Properties.getValue("use_analog") as Boolean?) {
         return;
      }

      var clockTime = System.getClockTime();
      drawdigitalDial(dc, clockTime);
   }

   function drawdigitalDial(dc as Dc, clockTime as System.ClockTime) as Void {
      var currentSettings = System.getDeviceSettings();

      var hour = clockTime.hour;
      if (!currentSettings.is24Hour) {
         hour = hour % 12;
         hour = hour == 0 ? 12 : hour;
      }
      var minute = clockTime.min;

      var leading_zeros = Properties.getValue("zero_leading_digital") as Boolean?;
      var number_formater = leading_zeros ? "%02d" : "%d";

      var digital_style = Properties.getValue("digital_style") as Number?;
      var alwayon_style = Properties.getValue("always_on_style") as Number?;

      if (digital_style == 0 || digital_style == 2) {
         // Big number in center_x style (0=big, 2=xbig)
         var big_number_type = Properties.getValue("big_number_type") as Number?;
         var bignumber = big_number_type == 0 ? minute : hour;
         var smallnumber = big_number_type == 0 ? hour : minute;
         var big_color = big_number_type == 0 ? gmins_color : ghour_color;
         var sml_color = big_number_type == 0 ? ghour_color : gmins_color;

         var target_center_font;
         try {
            var fontId = digital_style == 0 ? Rez.Fonts.bigdigi : Rez.Fonts.xbigdigi;
            target_center_font = Ui.loadResource(fontId) as FontType?;

            // Draw center_x number
            var bigText = bignumber.format(number_formater);
            dc.setPenWidth(1);
            dc.setColor(big_color, Graphics.COLOR_TRANSPARENT);
            var h = dc.getFontHeight(target_center_font);
            var w = dc.getTextWidthInPixels(bigText, target_center_font);
            dc.drawText(center_x, center_y - h / 4, target_center_font, bigText, alignment);

            // Draw stripes
            if (Properties.getValue("big_num_stripes")) {
               dc.setColor(gbackground_color, Graphics.COLOR_TRANSPARENT);
               var w2 = dc.getTextWidthInPixels("\\", target_center_font);
               dc.drawText(center_x + w2 - w / 2, center_y - h / 4, target_center_font, "\\", Graphics.TEXT_JUSTIFY_VCENTER);
            }

            // FIXME - Move to InfocalView: Calculate seconds/hr global offsets
            var f_align = digital_style == 0 ? 62 : 71;
            if (center_x == 195 || center_x == 208) {
               f_align = f_align + 40;
            }
            var second_x_l = center_x + w / 2 + 3;
            var heart_x_l = center_x - w / 2 - 3;
            var second_y_l = 0;
            if (center_x == 109 && digital_style == 2) {
               second_y_l = center_y - second_font_height_half / 2 - (alwayon_style == 0 ? 3 : 6);
            } else {
               second_y_l = center_y + (h - f_align) / 2 - second_font_height_half * 2 + (alwayon_style == 0 ? 0 : 5);
            }
            // Save globals
            second_x = second_x_l;
            second_y = second_y_l;
            heart_x = heart_x_l;
         } finally {
            // unload
            target_center_font = null;
         }

         // Calculate alignment of digital info (small number, date)
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
         // This is needed to prevent power save mode from re-rendering // XXX ?
         dc.setColor(gbackground_color, Graphics.COLOR_TRANSPARENT);
         dc.setPenWidth(20);
         if (left_digital_info) {
            dc.drawArc(center_x, center_y, barRadius, Graphics.ARC_CLOCKWISE, 180 - 10, 120 + 10);
         } else {
            dc.drawArc(center_x, center_y, barRadius, Graphics.ARC_CLOCKWISE, 60 - 10, 0 + 10);
         }
         dc.setPenWidth(1);

         var midDigitalFont;
         try {
            midDigitalFont = Ui.loadResource(Rez.Fonts.middigi) as FontType?;

            // Draw small number
            dc.setColor(sml_color, Graphics.COLOR_TRANSPARENT);
            var h2 = dc.getFontHeight(midDigitalFont);
            dc.drawText(
               target_info_x + bonus_alignment,
               center_y * 0.7 - h2 / 4 + 5 + vertical_alignment,
               midDigitalFont,
               smallnumber.format(number_formater),
               alignment
            );
         } finally {
            // unload
            midDigitalFont = null;
         }

         // TODO: Localize load-unload of global small_digi_font
         // Draw the date only if there is enough room to display it
         if (center_x > 109 || digital_style != 2) {
            // Draw date
            var dateText = Globals.getFormattedDate();
            dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
            var h3 = dc.getFontHeight(small_digi_font);
            dc.drawText(target_info_x - bonus_alignment + extra_info_alignment, center_y * 0.4 - h3 / 4 + 7, small_digi_font, dateText, alignment);

            // Draw horizontal line
            var w3 = dc.getTextWidthInPixels(dateText, small_digi_font);
            dc.setPenWidth(2);
            dc.setColor(gaccent_color, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(
               target_info_x - bonus_alignment - w3 / 2 + extra_info_alignment,
               center_y * 0.5 + 7,
               target_info_x - bonus_alignment + w3 / 2 + extra_info_alignment,
               center_y * 0.5 + 7
            );
         }
      } else if (digital_style == 1 || digital_style == 3) {
         // Classic time numbers in center_x style (1=small(mid), 3=medium(xmid))
         var hourText = hour.format(number_formater);
         var minuText = minute.format("%02d");

         var boldF;
         var hourW;
         var minsW;
         var timeW;
         var left;
         var y_offset;
         try {
            var fontId = digital_style == 1 ? Rez.Fonts.midbold : Rez.Fonts.xmidbold;
            boldF = Ui.loadResource(fontId) as FontType;

            // BUG: fonts are bottom-aligned at 2x character height (font bounds are incorrect)
            var height = dc.getFontHeight(boldF);
            y_offset = height * 0.75;
            hourW = dc.getTextWidthInPixels(hourText, boldF);
            minsW = (dc.getTextWidthInPixels(minuText, boldF) * 0.95).toNumber() + 1; // estimate using boldF (normF not loaded)
            timeW = (hourW + 6 + minsW);
            left = center_x - timeW/2;

            // Draw hour
            dc.setColor(ghour_color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(left, center_y - y_offset, boldF, hourText, Graphics.TEXT_JUSTIFY_LEFT);
         } finally {
            // unload
            boldF = null;
         }

         var normF;
         try {
            var fontId = digital_style == 1 ? Rez.Fonts.midsemi : Rez.Fonts.xmidsemi;
            normF = Ui.loadResource(fontId) as FontType;

            dc.setColor(gmins_color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(left + hourW + 6, center_y - y_offset, normF, minuText, Graphics.TEXT_JUSTIFY_LEFT);
         } finally {
            // unload
            normF = null;
         }

         // FIXME - Move to InfocalView: Save globals - Calculate Layout of seconds and heart rate (with widest digits)
         heart_x = center_x - timeW / 2 - 1;
         second_x = center_x + timeW / 2 + 3;
         second_y = center_y - second_font_height_half; // centre-justified
      }
   }
}
