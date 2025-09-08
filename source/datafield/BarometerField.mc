import Toybox.Application;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.Time;

/* BAROMETER */
class BarometerField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function cur_val() {
      var presure_data = _retrieveBarometer();
      return presure_data;
   }

   function cur_label(value) {
      var value1 = value[0];
      var value2 = value[1];
      if (value1 == null) {
         return "BARO --";
      } else {
         var hector_pascal = value1 / 100.0;

         var unit = Properties.getValue("barometer_unit");
         if (unit == 1) {
            // convert to inHg
            hector_pascal = hector_pascal * 0.0295301;
         }
         var signal = "";
         if (value2 == 1) {
            signal = "+";
         } else if (value2 == -1) {
            signal = "-";
         }

         if (unit == 1) {
            return Lang.format("BAR $1$$2$", [
               hector_pascal.format("%0.2f"),
               signal,
            ]);
         }
         return Lang.format("BAR $1$$2$", [hector_pascal.format("%d"), signal]);
      }
   }

   // Create a method to get the SensorHistoryIterator object
   function _getIterator() {
      // Check device for SensorHistory compatibility
      if (
         Toybox has :SensorHistory &&
         Toybox.SensorHistory has :getPressureHistory
      ) {
         return Toybox.SensorHistory.getPressureHistory({});
      }
      return null;
   }

   // Create a method to get the SensorHistoryIterator object
   function _getIteratorDurate(hour) {
      // Check device for SensorHistory compatibility
      if (
         Toybox has :SensorHistory &&
         Toybox.SensorHistory has :getPressureHistory
      ) {
         var duration = new Time.Duration(hour * 3600);
         return Toybox.SensorHistory.getPressureHistory({
            "period" => duration,
            "order" => SensorHistory.ORDER_OLDEST_FIRST,
         });
      }
      return null;
   }

   function _retrieveBarometer() {
      var trend_iter = _getIteratorDurate(3); // 3 hour
      var trending = null;
      if (trend_iter != null) {
         // get 5 sample
         var sample = null;
         var num = 0.0;
         for (var i = 0; i < 5; i += 1) {
            sample = trend_iter.next();
            if (sample != null && sample has :data) {
               var d = sample.data;
               if (d != null) {
                  if (trending == null) {
                     trending = d;
                     num += 1;
                  } else {
                     trending += d;
                     num += 1;
                  }
               }
            }
         }
         if (trending != null) {
            trending /= num;
         }
      }
      var iter = _getIterator();
      // Print out the next entry in the iterator
      if (iter != null) {
         var sample = iter.next();
         if (sample != null && sample has :data) {
            var d = sample.data;
            var c = 0;
            if (trending != null && d != null) {
               c = trending > d ? -1 : 1;
            }
            return [d, c];
         }
      }
      return [null, 0];
   }
}
