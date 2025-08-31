using Toybox.WatchUi as Ui;
using Toybox.Math;
using Toybox.Graphics;
using Toybox.System;

import Toybox.Application;
import Toybox.Lang;

class ArcTextComplication extends Ui.Drawable {
   private var barRadius;
   private var baseRadian;
   private var baseDegree;
   private var alignment;
   private var perCharRadius;

   private var accumulation_sign;

   private var dt_field;

   // layout
   protected var angle;
   protected var field_type;

   function initialize(params) {
      Drawable.initialize(params);

      field_type = params.get(:field_type);
      dt_field = buildFieldObject(field_type);

      barRadius = center_x - ((13 * center_x) / 120).toNumber();
      var kerning = 1.0;
      if (center_x == 109) {
         kerning = 1.1;
         barRadius = center_x - 11;
      } else if (center_x == 130) {
         kerning = 0.95;
      } else if ((center_x == 195) || (center_x == 208)) {
         kerning = 0.95;
         barRadius = barRadius + 4;
      }

      baseDegree = params.get(:base);
      baseRadian = Math.toRadians(baseDegree);

      angle = params.get(:angle);
      perCharRadius = (kerning * 4.7 * Math.PI) / 100;
      barRadius += (((baseDegree < 180 ? 8 : -3) * center_x) / 120).toNumber();
      accumulation_sign = baseDegree < 180 ? -1 : 1;

      alignment = Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER;
   }

   function getSettingDataKey() {
      return Properties.getValue("comp" + angle + "h");
   }

   function get_text() {
      var curval = dt_field.cur_val();
      var pre_label = dt_field.cur_label(curval);
      return pre_label;
   }

   function need_draw() {
      var digital_style = Properties.getValue("digital_style");
      if (digital_style == 1 || digital_style == 3) {
         // small digital
         return dt_field.need_draw();
      }
      if (Properties.getValue("left_digital_info")) {
         var can_draw = !(
            angle == 10 && !Properties.getValue("use_analog")
         );
         return dt_field.need_draw() && can_draw;
      } else {
         var can_draw = !(
            angle == 2 && !Properties.getValue("use_analog")
         );
         return dt_field.need_draw() && can_draw;
      }
   }

   function draw(dc) {
      field_type = getSettingDataKey();
      if (field_type != dt_field.field_id()) {
         dt_field = buildFieldObject(field_type);
      }

      if (need_draw()) {
         // Draw background arc
         dc.setColor(gbackground_color, Graphics.COLOR_TRANSPARENT);
         dc.setPenWidth(20);
         var target_r =
            barRadius -
            (((baseDegree < 180 ? 6 : -3) * center_x) / 120).toNumber();
         dc.drawArc(
            center_x,
            center_y,
            target_r,
            Graphics.ARC_CLOCKWISE,
            360.0 - (baseDegree - 30.0),
            360.0 - (baseDegree + 30.0)
         );

         // draw text
         dc.setPenWidth(1);
         dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
         var text = get_text();
         drawArcText(dc, text);
      }
   }

   //! Prevent invalid characters from causing runtime exception
   private function get_kerning_ratio(c as Char, kerning_ratios as Array<Float>) as Float {

      // PERF: Lookup Kerning Ratios in Array
      var kr;
      if ((c >= '+') && (c <= ':')) {
         kr = kerning_ratios[ c.toNumber() - '+'.toNumber() + 3 ];
      } else if ((c >= 'A') && (c <= 'Z')) {
         kr = kerning_ratios[ c.toNumber() - 'A'.toNumber() + 19 ];
      } else if (c == ' ') {
         kr = kerning_ratios[0];
      } else if (c == '%') {
         kr = kerning_ratios[1];
      } else if (c == '°') {
         kr = kerning_ratios[2];
      } else {
         // Unknown character (return avg kerning ratio)
         kr = 0.64;
      }
      return kr;
   }

   private function drawArcText(dc, text) {
      var totalChar = 0;
      if (text instanceof String) {
         totalChar = text.length();
      } else {
         // Error
         text = "ERR";
         totalChar = text.length();
      }
      var charArray = text.toUpper().toCharArray();

      // PERF: Remove large constants from <Global> Object statics
      // (created on stack, once per drawn field)
      var KERNING_RATIOS = [
         0.40,  // ' ' [0]
         0.92,  // '%' [1]
         0.47,  // '°' [2]
         0.70,  // '+' [3]
         0.25,  // ','    // TODO: international numbers use comma delimeters
         0.38,  // '-'
         0.25,  // '.'
         0.64,  // '/'    // NOT USED: Packing to simplify array indexing
         0.66,  // '0'
         0.41,  // '1'
         0.60,  // '2'
         0.63,  // '3'
         0.67,  // '4'
         0.63,  // '5'
         0.64,  // '6'
         0.53,  // '7'
         0.67,  // '8'
         0.64,  // '9'
         0.25,  // ':'
         0.68,  // 'A' [19]
         0.68,  // 'B'
         0.66,  // 'C'
         0.68,  // 'D'
         0.59,  // 'E'
         0.56,  // 'F'
         0.67,  // 'G'
         0.71,  // 'H'
         0.33,  // 'I'
         0.64,  // 'J'
         0.68,  // 'K'
         0.55,  // 'L'
         0.89,  // 'M'
         0.73,  // 'N'
         0.68,  // 'O'
         0.66,  // 'P'
         0.80,  // 'Q'  // TODO : Add letter Q to all arc text fonts
         0.67,  // 'R'
         0.67,  // 'S'
         0.55,  // 'T'
         0.68,  // 'U'
         0.64,  // 'V'
         1.00,  // 'W'
         0.64,  // 'X'  // TODO : Add letter X to all arc text fonts
         0.64,  // 'Y'
         0.64,  // 'Z'  // TODO : Add letter Z to all arc text fonts
      ] as Array<Float>;

      var totalRad = 0.0;
      for (var i = 0; i < totalChar; i++) {
         var ra = perCharRadius * get_kerning_ratio(charArray[i], KERNING_RATIOS);
         totalRad += ra;
      }
      var lastRad = -totalRad / 2.0;

      for (var i = 0; i < totalChar; i++) {
         var ra = perCharRadius * get_kerning_ratio(charArray[i], KERNING_RATIOS);

         lastRad += ra;
         if (charArray[i] == ' ') {
         } else {
            //var centering = ra / 2.0;
            var targetRadian =
               baseRadian + (lastRad - ra / 2.0) * accumulation_sign;

            var labelCurX = Globals.convertCoorX(targetRadian, barRadius);
            var labelCurY = Globals.convertCoorY(targetRadian, barRadius);
            var font;
            try {
               font = load_arc_text_font(targetRadian);
               dc.drawText(labelCurX, labelCurY, font, charArray[i].toString(), alignment);
            } finally {
               font = null;
            }
         }
      }
   }

   function load_arc_text_font(current_rad) as Ui.Resource {
      var converted = current_rad + Math.PI;
      var degree = Math.toDegrees(converted).toNumber();
      var idx = ((degree % 180) / 3).toNumber();

      if (idx == 0) {
         return Ui.loadResource(Rez.Fonts.e0);
      } else if (idx == 1) {
         return Ui.loadResource(Rez.Fonts.e1);
      } else if (idx == 2) {
         return Ui.loadResource(Rez.Fonts.e2);
      } else if (idx == 3) {
         return Ui.loadResource(Rez.Fonts.e3);
      } else if (idx == 4) {
         return Ui.loadResource(Rez.Fonts.e4);
      } else if (idx == 5) {
         return Ui.loadResource(Rez.Fonts.e5);
      } else if (idx == 6) {
         return Ui.loadResource(Rez.Fonts.e6);
      } else if (idx == 7) {
         return Ui.loadResource(Rez.Fonts.e7);
      } else if (idx == 8) {
         return Ui.loadResource(Rez.Fonts.e8);
      } else if (idx == 9) {
         return Ui.loadResource(Rez.Fonts.e9);
      } else if (idx == 10) {
         return Ui.loadResource(Rez.Fonts.e10);
      } else if (idx == 11) {
         return Ui.loadResource(Rez.Fonts.e11);
      } else if (idx == 12) {
         return Ui.loadResource(Rez.Fonts.e12);
      } else if (idx == 13) {
         return Ui.loadResource(Rez.Fonts.e13);
      } else if (idx == 14) {
         return Ui.loadResource(Rez.Fonts.e14);
      } else if (idx == 15) {
         return Ui.loadResource(Rez.Fonts.e15);
      } else if (idx == 16) {
         return Ui.loadResource(Rez.Fonts.e16);
      } else if (idx == 17) {
         return Ui.loadResource(Rez.Fonts.e17);
      } else if (idx == 18) {
         return Ui.loadResource(Rez.Fonts.e18);
      } else if (idx == 19) {
         return Ui.loadResource(Rez.Fonts.e19);
      } else if (idx == 20) {
         return Ui.loadResource(Rez.Fonts.e20);
      } else if (idx == 21) {
         return Ui.loadResource(Rez.Fonts.e21);
      } else if (idx == 22) {
         return Ui.loadResource(Rez.Fonts.e22);
      } else if (idx == 23) {
         return Ui.loadResource(Rez.Fonts.e23);
      } else if (idx == 24) {
         return Ui.loadResource(Rez.Fonts.e24);
      } else if (idx == 25) {
         return Ui.loadResource(Rez.Fonts.e25);
      } else if (idx == 26) {
         return Ui.loadResource(Rez.Fonts.e26);
      } else if (idx == 27) {
         return Ui.loadResource(Rez.Fonts.e27);
      } else if (idx == 28) {
         return Ui.loadResource(Rez.Fonts.e28);
      } else if (idx == 29) {
         return Ui.loadResource(Rez.Fonts.e29);
      } else if (idx == 30) {
         return Ui.loadResource(Rez.Fonts.e30);
      } else if (idx == 31) {
         return Ui.loadResource(Rez.Fonts.e31);
      } else if (idx == 32) {
         return Ui.loadResource(Rez.Fonts.e32);
      } else if (idx == 33) {
         return Ui.loadResource(Rez.Fonts.e33);
      } else if (idx == 34) {
         return Ui.loadResource(Rez.Fonts.e34);
      } else if (idx == 35) {
         return Ui.loadResource(Rez.Fonts.e35);
      } else if (idx == 36) {
         return Ui.loadResource(Rez.Fonts.e36);
      } else if (idx == 37) {
         return Ui.loadResource(Rez.Fonts.e37);
      } else if (idx == 38) {
         return Ui.loadResource(Rez.Fonts.e38);
      } else if (idx == 39) {
         return Ui.loadResource(Rez.Fonts.e39);
      } else if (idx == 40) {
         return Ui.loadResource(Rez.Fonts.e40);
      } else if (idx == 41) {
         return Ui.loadResource(Rez.Fonts.e41);
      } else if (idx == 42) {
         return Ui.loadResource(Rez.Fonts.e42);
      } else if (idx == 43) {
         return Ui.loadResource(Rez.Fonts.e43);
      } else if (idx == 44) {
         return Ui.loadResource(Rez.Fonts.e44);
      } else if (idx == 45) {
         return Ui.loadResource(Rez.Fonts.e45);
      } else if (idx == 46) {
         return Ui.loadResource(Rez.Fonts.e46);
      } else if (idx == 47) {
         return Ui.loadResource(Rez.Fonts.e47);
      } else if (idx == 48) {
         return Ui.loadResource(Rez.Fonts.e48);
      } else if (idx == 49) {
         return Ui.loadResource(Rez.Fonts.e49);
      } else if (idx == 50) {
         return Ui.loadResource(Rez.Fonts.e50);
      } else if (idx == 51) {
         return Ui.loadResource(Rez.Fonts.e51);
      } else if (idx == 52) {
         return Ui.loadResource(Rez.Fonts.e52);
      } else if (idx == 53) {
         return Ui.loadResource(Rez.Fonts.e53);
      } else if (idx == 54) {
         return Ui.loadResource(Rez.Fonts.e54);
      } else if (idx == 55) {
         return Ui.loadResource(Rez.Fonts.e55);
      } else if (idx == 56) {
         return Ui.loadResource(Rez.Fonts.e56);
      } else if (idx == 57) {
         return Ui.loadResource(Rez.Fonts.e57);
      } else if (idx == 58) {
         return Ui.loadResource(Rez.Fonts.e58);
      } else if (idx == 59) {
         return Ui.loadResource(Rez.Fonts.e59);
      } else {//(idx == 60)
         return Ui.loadResource(Rez.Fonts.e60);
      }
   }
}
