using Toybox.WatchUi as Ui;
using Toybox.Math;
using Toybox.System;

import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;

class BarComplication extends Ui.Drawable {
   private var position_y_draw, position_y_draw_bonus;
   private var font, arrFont;
   private var fontInfo as Array<Array<Number>>?;
   private var arrInfo as Array<Array<Number>>?;
   private var weatherFont;
   private var factor = 1;
   private var dt_field;

   // layout
   protected var field_type;
   protected var position;


   function initialize(params) {
      Drawable.initialize(params);

      field_type = params.get(:field_type);
      dt_field = buildFieldObject(field_type);
      position = params.get(:position);

      if (position == 0) {
         // up
         if (center_x == 120) {
            position_y_draw = 52; //center_y - 36 - 18 - 14; // font height 14
            position_y_draw_bonus = -13;
         } else if (center_x == 130) {
            position_y_draw = 58; //center_y - 36 - 18 - 14 - 4; // font height 14
            position_y_draw_bonus = -18;
         } else if (center_x == 140) {
            position_y_draw = 64; //center_y - 36 - 18 - 14 - 8; // font height 14
            position_y_draw_bonus = -18;
         } else if (center_x == 195) {
            position_y_draw = 89; //center_y - 36 - 18 - 14 - 8; // font height 14
            position_y_draw_bonus = -36;
            factor = 2;
         } else {
            position_y_draw = 44; //center_y - 36 - 18 - 14 + 5; // font height 14
            position_y_draw_bonus = -13;
         }
      } else {
         // down
         if (center_x == 120) {
            position_y_draw = 156; //center_y + 36;
            position_y_draw_bonus = 29;
         } else if (center_x == 130) {
            position_y_draw = 170; //center_y + 36 + 4;
            position_y_draw_bonus = 33;
         } else if (center_x == 140) {
            position_y_draw = 184; //center_y + 36 + 8;
            position_y_draw_bonus = 33;
         } else if (center_x == 195) {
            position_y_draw = 256; //center_y - 36 - 18 - 14 - 8; // font height 14
            position_y_draw_bonus = 48;
            factor = 2;
         } else {
            position_y_draw = 140; //center_y + 36 - 5;
            position_y_draw_bonus = 29;
         }
      }
   }

   private function load_font() {
      if (position == 0) {
         // up
         font = Ui.loadResource(Rez.Fonts.cur_up);
         arrFont = Ui.loadResource(Rez.Fonts.arr_up);
         fontInfo = Ui.loadResource(Rez.JsonData.bar_font_top);
         arrInfo = Ui.loadResource(Rez.JsonData.bar_pos_top);
      } else {
         // down
         font = Ui.loadResource(Rez.Fonts.cur_bo);
         arrFont = Ui.loadResource(Rez.Fonts.arr_bo);
         fontInfo = Ui.loadResource(Rez.JsonData.bar_font_bottom);
         arrInfo = Ui.loadResource(Rez.JsonData.bar_pos_bottom);
      }
   }

   function min_val() {
      return dt_field.min_val();
   }

   function max_val() {
      return dt_field.max_val();
   }

   function cur_val() {
      return dt_field.cur_val();
   }

   function get_title() {
      var curval = dt_field.cur_val();
      return dt_field.cur_label(curval);
   }

   function need_draw() {
      return dt_field.need_draw();
   }

   function bar_data() {
      return dt_field.bar_data();
   }

   function get_weather_icon() {
      return dt_field.cur_icon();
   }

   function getSettingDataKey() {
      if (position == 0) {
         // upper
         return Properties.getValue("compbart");
      } else {
         // lower
         return Properties.getValue("compbarb");
      }
   }

   function draw(dc as Dc) {
      field_type = getSettingDataKey();
      if (field_type != dt_field.field_id()) {
         dt_field = buildFieldObject(field_type);
      }

      if (need_draw()) {
         draw_bar(dc);
      }
   }

   function draw_bar(dc as Dc) as Void {

      var is_bar_data = bar_data();
      if (is_bar_data) {
         load_font();
      }

      if (field_type == FIELD_TYPE_WEATHER) {
         weatherFont = Ui.loadResource(Rez.Fonts.weather);
      } else {
         weatherFont = null;
      }

      var primaryColor = position == 1 ? gbar_color_1 : gbar_color_0;

      var bonus_padding = 0;

      if (is_bar_data) {
         var mi = min_val().toFloat(); // 0
         var ma = max_val().toFloat(); // 5
         // support current value is null (for no-computed-data)
         var val = cur_val();
         var cu = (val != null) ? val.toFloat() : mi; // 1

         var i = 0;
         if (cu >= ma) {
            i = 4;
         } else if (cu <= mi) {
            i = -1;
         } else {
            var fraction = (cu - mi) / (ma - mi);
            if (fraction > 0.81) {
               i = 4;
            } else if (fraction > 0.61) {
               i = 3;
            } else if (fraction > 0.41) {
               i = 2;
            } else if (fraction > 0.21) {
               i = 1;
            } else {
               i = 0;
            }
         }

         for (var j = 0; j <= 4; j++) {
            if (j == i) {
               dc.setColor(primaryColor, Graphics.COLOR_TRANSPARENT);
            } else {
               dc.setColor(gbar_color_back, Graphics.COLOR_TRANSPARENT);
            }
            drawTiles(fontInfo[j], font, dc);
         }

         if (i >= 0) {
            dc.setColor(gbar_color_indi, Graphics.COLOR_TRANSPARENT);
            drawTiles(arrInfo[i], arrFont, dc);
         }
      } else if (field_type == FIELD_TYPE_WEATHER) {
         var icon = get_weather_icon();
         if (icon != null) {
            dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
               center_x,
               position_y_draw + position_y_draw_bonus,
               weatherFont,
               icon,
               Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
         }
         bonus_padding = position == 0 ? 2 : -2;
      } else {
         bonus_padding = position == 0 ? -7 : 5;
      }

      var title = get_title();
      if (title == null) {
         title = "--";
      }

      title = title.toUpper();
      dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
      dc.drawText(
         center_x,
         position_y_draw + bonus_padding,
         small_digi_font,
         title,
         Graphics.TEXT_JUSTIFY_CENTER
      );

      font = null;
      fontInfo = null;
      arrFont = null;
      arrInfo = null;
      weatherFont = null;
   }

   //! Draw *image* font based on parameters packed in jsondata
   //!
   //! - The hour/minute/bar images are drawn from custom made fonts
   //! - The JsonData files contain packed instructions on how to draw
   //!   the full image from the font characters.
   //! - Each JsonData number represents an image part (tile) with byte encoding:
   //!   [ flags|char|xpos|ypos ]
   function drawTiles(packed_array as Array<Number>, font, dc) {
      for (var i = 0; i < packed_array.size(); i++) {
         var val = packed_array[i];
         var flag = (val >> 24) & 255;
         var code = (val >> 16) & 255;
         var xpos = (val >> 8) & 255;
         var ypos = (val >> 0) & 255;
         var xpos_bonus = (flag & 0x01) == 0x01 ? 1 : 0;
         var ypos_bonus = (flag & 0x10) == 0x10 ? 1 : 0;
         dc.drawText(
            (xpos * factor + xpos_bonus).toNumber(),
            (ypos * factor + ypos_bonus).toNumber(),
            font,
            code.toChar().toString(),
            Graphics.TEXT_JUSTIFY_LEFT
         );
      }
   }
}
