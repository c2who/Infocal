import Toybox.System;
import Toybox.Lang;

//! SolarIntensity (API Level 3.2.0)
//! Solar charging intensity from 0-100%. Value may be null.
class SolarIntensityField extends BaseDataField {
   private const _hasSolarIntensity = (System.Stats has :solarIntensity) as Boolean;

   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function max_val() as Float {
      return 100.0; // percentage
   }

   function cur_val() as Float {
      // solarIntensity can return null
      var intensity = (_hasSolarIntensity) ? System.getSystemStats().solarIntensity : null;
      return (intensity != null) ? intensity.toFloat() : -1.0;
   }

   function max_label(value as Float) as String {
      return value.format("%d");
   }

   function cur_label(value as Float) as String {
      if (value < 0.0) {
         return "--";
      } else {
         return Lang.format("SI $1$%", [value.format("%d")]);
      }
   }

   function bar_data() as Boolean {
      return true;
   }
}
