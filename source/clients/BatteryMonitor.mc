import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

//! Battery Usage Monitor.
//! Monitor sthe battery discharge rate over time, implements a FSM.
//! Used on watches that do not have Stats.batteryInDays (API 3.3.0)
//!
//!                             ┌───────────────────────────────────────────┐
//! ┌───────────────┐           │  ┌─────────────────┐                      │
//! │               │[bat% --]  │  │                 │                      │
//! │     Init      ├───────────│─►│ Wait for dischg ├───────┐              │
//! │               │           │  │                 │       │              │
//! └───────────────┘           │  └─────────────────┘       │[bat% -- ]    │
//!         ▲[charging||invalid]│                ▲           │update_dchg() │
//!         └───────────────────┤                └───────────┘              │
//!                             └───────────────────────────────────────────┘
//!
//! Inputs
//!     stats.battery       battery charge (%)
//!
//! Output
//!     bat_dchg1_time      moving average of time (in seconds) to discharge battery by 1%
//!
//! State
//!     bat_state           state machine active state
//!     bat_last_pcnt       battery (%) on entry to state
//!     bat_last_time       time (seconds) on entry to state
//!
//! @note WatchFace is restarted often, so state is persisted in Storage across updates
//!
//! @note Algorithm sample period is battery decay (% change), not fixed time,
//!       so the algorithm can adapt faster to accelerated discharge rates
//!
class BatteryMonitor {
   private const _hasCharging = (System.Stats has :charging) as Boolean; // API 3.0.0

   private enum State {
      INIT,
      WAIT_FOR_DCHG,
   }

   // Self battery consumption monitoring (shared across all battery fields)
   private var _bat_state as State?; //< state
   private var _bat_last_pcnt as Float?; //< percent
   private var _bat_last_time as Number?; //< seconds since epoch

   function initialize() {
      // Reload values on app launch/restart
      _bat_state = Storage.getValue("bat_state");
      _bat_last_pcnt = Storage.getValue("bat_last_pcnt");
      _bat_last_time = Storage.getValue("bat_last_time");
   }

   //! Update method.
   //! Call approx every minute, to provide measurment accuracy
   public function update() {
      var stats = System.getSystemStats();
      var bat_pcnt = stats.battery; // %
      var time_now = Time.now().value(); // seconds since epoch
      var charging = _hasCharging ? stats.charging : false;

      // Detect if charged/charging / battery voltage increase (e.g. Solar)
      if (_bat_last_pcnt != null && _bat_last_pcnt < bat_pcnt) {
         charging = true;
      }

      // Outside state transition to INIT (charging or data invalid)
      // @note resets if excessive time elapsed between samples
      if (charging || _bat_state == null || _bat_last_pcnt == null || _bat_last_time == null || time_now - _bat_last_time > 2 * Gregorian.SECONDS_PER_HOUR) {
         update_state(INIT, bat_pcnt, time_now);
      }

      // State Machine:

      // INIT - waiting for start of a measurement period (battery % drop)
      if (_bat_state == INIT) {
         // Transition to WAIT_FOR_DCHG
         if (bat_pcnt < _bat_last_pcnt) {
            update_state(WAIT_FOR_DCHG, bat_pcnt, time_now);
         }

         // WAIT_FOR_DCHG - waiting for end of measurement period
      } else if (_bat_state == WAIT_FOR_DCHG) {
         // Take Measurement on battery change
         if (bat_pcnt < _bat_last_pcnt) {
            // Update discharge rate
            update_discharge_rate(bat_pcnt, time_now);

            // Next sample
            update_state(WAIT_FOR_DCHG, bat_pcnt, time_now);
         }

         // INVALID - reset to init
      } else {
         update_state(INIT, bat_pcnt, time_now);
      }
   }

   private function update_state(state as State, bat_pcnt as Float, time_now as Number) {
      // print debug message only on change - to avoid duplicate entries every minute when 'charging'
      if (_bat_state != state || _bat_last_pcnt != bat_pcnt) {
         debug_print(:bms, "[$1$] $2$%", [state, bat_pcnt.format("%0.1f")]);
      }

      _bat_state = state;
      _bat_last_pcnt = bat_pcnt;
      _bat_last_time = time_now;

      Storage.setValue("bat_state", _bat_state);
      Storage.setValue("bat_last_pcnt", _bat_last_pcnt);
      Storage.setValue("bat_last_time", _bat_last_time);
   }

   //! Update the (average) battery discharge rate
   //! @note   As the battery voltage discharge rate is very irregular, we use an
   //!         exponentially-weighted moving average (EMA) to smooth the output
   //!         y[n] = x[n]*alpha + y[n-1] * (1-alpha)
   //! @note We use a 'ramped-alpha' to remove early sample noise (over first T samples)
   //!         alpha[t] = 2 / ( min(t + 2, WINDOW_SIZE) + 1)
   private function update_discharge_rate(bat_pcnt as Float, time_now as Number) {
      // target alpha for averaging the discharge rate over 100% discharge
      var WINDOW_SIZE = 100; // (target alpha = 0.0198)

      // calculate ramped alpha over [t] samples
      var t = Storage.getValue("bat_dchg1_t") as Number?;
      t = t == null ? 0 : t + 1;
      var alpha = 2.0 / (min(t + 2, WINDOW_SIZE) + 1.0);

      // calculate x[n], current sample time (seconds) to lose 1% charge
      var x = ((time_now - _bat_last_time) / (_bat_last_pcnt - bat_pcnt)).toNumber();

      // load y[n-1], previous value
      var y_n_1 = Storage.getValue("bat_dchg1_time") as Float?;

      // calculate y[n]
      var y;
      if (y_n_1 == null) {
         // Init
         y = x;
      } else {
         // Apply EMA, // y[n] = (0.alpha * x[n]) + (y[n−1] * (1-alpha))
         y = (x * alpha + y_n_1 * (1 - alpha)).toNumber();
      }
      Storage.setValue("bat_dchg1_time", y);
      Storage.setValue("bat_dchg1_t", t);

      debug_print(:bms, "a=$1$, $2$sec/% > $3$sec/%", [alpha.format("%0.4f"), x, y]);
   }

   private function min(a as Number or Float, b as Number or Float) as Number or Float {
      return a < b ? a : b;
   }
}
