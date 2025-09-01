using Toybox.WatchUi;
using Toybox.Math;
using Toybox.System;

import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.SensorHistory;

class GraphComplication extends WatchUi.Drawable {
   private var position_x as Number, position_y as Number;
   private var graph_width as Number, graph_height as Number;

   private var _elevationUnits as Number = System.UNIT_METRIC;
   private var _temperatureUnits as Number = System.UNIT_METRIC;

   // layout
   protected var position as Number;

   function initialize(options as DrawableInitOptions) {
      Drawable.initialize(options);

      position = options.get(:position) as Number;
      if (position == 0) {
         // top
         position_x = center_x;
         position_y = center_y / 2;
      } else {
         // bottom
         position_x = center_x;
         position_y = (center_y * 1.45).toNumber();
      }

      graph_width =  (0.8 * center_x).toNumber();
      graph_height = (0.3 * center_y).toNumber();
   }

   function get_data_type() as Number {
      if (position == 0) {
         return Settings.getOrDefault("compgrapht", 0) as Number;
      } else {
         return Settings.getOrDefault("compgraphb", 0) as Number;
      }
   }

   //! Get Sensor History Iterator
   function get_data_iterator(type as Number) as SensorHistoryIterator? {
      if (type == 1) {
         if (
            Toybox has :SensorHistory &&
            SensorHistory has :getHeartRateHistory
         ) {
            return SensorHistory.getHeartRateHistory({});
         }
      } else if (type == 2) {
         if (
            Toybox has :SensorHistory &&
            SensorHistory has :getElevationHistory
         ) {
            return SensorHistory.getElevationHistory({});
         }
      } else if (type == 3) {
         if (
            Toybox has :SensorHistory &&
            SensorHistory has :getPressureHistory
         ) {
            return SensorHistory.getPressureHistory({});
         }
      } else if (type == 4) {
         if (
            Toybox has :SensorHistory &&
            SensorHistory has :getTemperatureHistory
         ) {
            return SensorHistory.getTemperatureHistory({});
         }
      } else if (type == 5) {
         if (
            Toybox has :SensorHistory &&
            SensorHistory has :getBodyBatteryHistory
         ) {
            return SensorHistory.getBodyBatteryHistory({});
         }
      } else if (type == 6) {
         if (
            Toybox has :SensorHistory &&
            SensorHistory has :getStressHistory
         ) {
            return SensorHistory.getStressHistory({});
         }
      } else {
         return null;
      }
      return null;
   }

   function need_draw() as Boolean {
      return (get_data_type() > 0);
   }

   //! Perform units conversion on value
   function parse_data_value(type as Number, value as Numeric) as Numeric {
      if (type == 1) {
         return value;
      } else if (type == 2) {
         if (_elevationUnits == System.UNIT_METRIC) {
            // Metres (no conversion necessary).
            return value;
         } else {
            // Feet.
            return value * 3.28084;
         }
      } else if (type == 3) {
         return value / 100.0;
      } else if (type == 4) {
         if (_temperatureUnits == System.UNIT_STATUTE) {
            return value * (9.0 / 5) + 32; // Convert to Farenheit: ensure floating point division.
         } else {
            return value;
         }
      } else {
         return value;
      }
   }

   //! Draw
   function draw(dc as Dc) as Void {
      if (!need_draw()) {
         return;
      }
      var font = small_digi_font;
      if (font == null) {
         return;
      }

      try {
         // Refresh system settings
         var settings = System.getDeviceSettings();
         _elevationUnits = settings.elevationUnits;
         _temperatureUnits = settings.temperatureUnits;

         var primaryColor = position == 1 ? gbar_color_1 : gbar_color_0;

         //Calculation
         var targetdatatype = get_data_type();
         var historyIter = get_data_iterator(targetdatatype);

         if (historyIter == null) {
            dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
               position_x,
               position_y,
               font,
               "--",
               Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
            return;
         }

         var min = historyIter.getMin();
         var max = historyIter.getMax();

         // Fixed: Prevent divide by zero if diff=0 (min==max)
         if ( (min == null || max == null) || (min == max) ) {
            dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
               position_x,
               position_y,
               font,
               "--",
               Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
            return;
         }

         var minMaxDiff = (max - min).toFloat();

         var xStep = graph_width;
         var height = graph_height;
         var HistoryPresent = 0;

         var lastPoint = null;
         var firstPoint = null;

         // FIXME: should read current sample from Activity/Sensor - not history
         // Find first point lastyStep
         var latest_sample = historyIter.next();
         if (latest_sample != null) {
            HistoryPresent = latest_sample.data;
            if (HistoryPresent != null) {
               // draw diagram
               // Fixed: Divide by zero checked above
               var historyDifPers = (HistoryPresent - min) / minMaxDiff;
               var yStep = historyDifPers * height;
               yStep = yStep > height ? height : yStep;
               yStep = yStep < 0 ? 0 : yStep;
               lastPoint = [xStep, yStep];
            } else {
               lastPoint = null;
            }
         }

         dc.setPenWidth(2);
         dc.setColor(primaryColor, Graphics.COLOR_TRANSPARENT);

         //Build and draw Iteration
         for (var i = graph_width; i > 0; i--) {
            var sample = historyIter.next();

            if ((sample != null) && (sample.data != null)) {
               // draw graph
               var historyDifPers = (sample.data - min) / minMaxDiff;
               var yStep = historyDifPers * height;
               yStep = yStep > height ? height : yStep;
               yStep = yStep < 0 ? 0 : yStep;

               if (lastPoint == null) {
                  // this is our first valid point
               } else {
                  // draw diagram
                  dc.drawLine(
                     position_x - graph_width/2  + lastPoint[0],
                     position_y + graph_height/2 - lastPoint[1],
                     position_x - graph_width/2  + xStep,
                     position_y + graph_height/2 - yStep
                  );
               }
               lastPoint = [xStep, yStep];
            }
            xStep--;
         }

         dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);

         if (HistoryPresent == null) {
            dc.drawText(
               position_x,
               position_y + (position == 1 ? graph_height/2 + 10 : -graph_height/2 - 16),
               font,
               "--",
               Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
            return;
         }
         var value_label = parse_data_value(targetdatatype, HistoryPresent);
         var labelll = value_label.format("%d");
         dc.drawText(
            position_x,
            position_y + (position == 1 ? graph_height/2 + 10 : -graph_height/2 - 16),
            font,
            labelll,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
         );

      } catch (ex) {
         // currently unknown, weird bug
         dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
         dc.drawText(
            position_x,
            position_y,
            font,
            "--",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
         );
      }
   }
}
