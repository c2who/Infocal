import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

//! Filter to filter debug messages in debug build
(:debug, :background) function is_debug_print_allowed(scope as Symbol) as Boolean {
   return true;
}

//! Filter to filter debug messages in release build
//! @note debug messages filtered in release build to limit log file overhead
(:release, :background) function is_debug_print_allowed(scope as Symbol) as Boolean {
   // TODO: Edit for the scope you want to debug in release builds
   return (scope == :bms);
}

//! Print debug messages.
//! (:debug)    print messages to Console
//! (:release)  Print debug messages to APPS/LOGS/<APPNAME>.txt
(:background)
public function debug_print(scope as Symbol, format as String, params as Object or Array) as Void {
   if (is_debug_print_allowed(scope)) {
        var time_info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        System.print( Lang.format("$1$:$2$:$3$ ", [ time_info.hour, time_info.min, time_info.sec ]) );
        if (params instanceof Array) {
            System.println(Lang.format(format, params));
        } else {
            System.println(Lang.format(format, [params]));
        }
   }
}
