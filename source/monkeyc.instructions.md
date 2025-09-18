---
applyTo: "**/*.mc"
---

# Monkey C Instructions for Copilot — Watch Face (Latest SDK)

These instructions enforce **Monkey C syntax** and **Toybox API usage** for a Watch Face application.
Follow Garmin’s official language rules and API docs exactly.
Do **not** substitute Java, JavaScript, or JSON syntax.

---

## Authoritative references

- Toybox API reference: https://developer.garmin.com/connect-iq/api-docs/index.html
- Toybox.WatchUi.WatchFace: https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/WatchFace.html
- Functions and keywords: https://developer.garmin.com/connect-iq/monkey-c/functions/
- Objects and memory: https://developer.garmin.com/connect-iq/monkey-c/objects-and-memory/
- Containers (Array and Dictionary): https://developer.garmin.com/connect-iq/monkey-c/containers/
- Strict typing (Monkey Types): https://developer.garmin.com/connect-iq/monkey-c/monkey-types/
- Exceptions and errors: https://developer.garmin.com/connect-iq/monkey-c/exceptions-and-errors/

If any request conflicts with these references, follow the references and explain the correction.

---

## File structure

- **All `import` statements must appear at the very top of the file**, before any class or function definitions.
- Always use the form:

  ```monkeyc
  import Toybox.Graphics;
  import Toybox.WatchUi;
  import Toybox.System;
  import Toybox.Lang;
  ```

- Do **not** alias modules with `as` (e.g., `using Toybox.Graphics as G;` is not valid style here).

---

## Watch Face–specific rules

- **Base class:** The main view must extend `Toybox.WatchUi.WatchFace`.

  ```monkeyc
  import Toybox.WatchUi;
  import Toybox.Graphics;

  class MyWatchFace extends WatchUi.WatchFace {
      function initialize() {
          WatchFace.initialize();
      }
  }
  ```

- **Lifecycle methods:**
  - `onUpdate(dc as Graphics.Dc)`
  - `onEnterSleep()`
  - `onExitSleep()`
  - `onPartialUpdate(dc as Graphics.Dc)`

- **Low‑power/Always‑On guidance:**
  - No timers or animations in low‑power mode.
  - Minimize drawing; use partial updates.
  - Avoid allocations; reuse objects.

---

## Language fundamentals

- **Functions:** `function name(args) { ... }` — no JS arrow functions or Java annotations.
- **Classes:** `class Name extends Base { ... }` — call base initializers explicitly.
- **Symbols:** `:name` — in dictionaries, symbol keys must be prefixed by `:`.
- **Booleans/null:** `true`, `false`, `null`.
- **Characters vs strings:** `'x'` is `Lang.Char`; `"text"` is `Lang.String`.
- **Numbers:** `5` (Number), `5l` (Long), `4.0` (Float), `4.0d` (Double).
- **Semicolons:** Only where required.
- **Comments:** `//` and `/* ... */`.

---

## Containers

- **Arrays:**

  ```monkeyc
  var xs = [1, 2, 3];
  xs.add(4);
  var first = xs[0];
  var n = xs.size();
  ```

- **Dictionaries (symbol keys preferred):**

  ```monkeyc
  var cfg = { :theme=>"dark", :retries=>3, :active=>true };
  var theme = cfg[:theme];
  cfg[:retries] = 4;
  var hasTheme = cfg.hasKey(:active);
  ```

- **Iteration:**

  ```monkeyc
  for (var i = 0; i < xs.size(); i += 1) {
      var v = xs[i];
  }

  foreach (var k in cfg.keys()) {
      var v = cfg[k];
  }
  ```

- **Hard rules:**
  - Never use JSON `{ "key": value }`.
  - Arrays are created with `[ ... ]` — no `new` keyword.

---

## Strings and comparison

- **Equality:**

  ```monkeyc
  if (a.equals(b)) { ... }
  ```

  - Use `.equals()` for value equality.
  - Do not use `==` for strings.

- **Ordering:**

  ```monkeyc
  var cmp = a.compareTo(b);
  ```

- **Search:**

  ```monkeyc
  var i = a.find("ell");
  ```

- **Case‑insensitive:**

  ```monkeyc
  a.toLower().equals(b.toLower());
  ```

- **Formatting:**

  ```monkeyc
  var s = Lang.format("$1$:$2$", [hour, min]);
  ```

- **Testing type of:**

  ```monkeyc
  if (value instanceof String) { ... };
  ```

---

## Control flow and declarations

- Standard `if/else`, `for`, `while`, `do/while`, `switch`.
- Use `const` and `enum` for constants.
- Use `instanceof` and `has` as documented.

---

## Monkey Types (strict typing)

- Dynamic by default.
- Use documented syntax for annotations, unions, tuples, container typing.
- Use `as` for safe casting.
- Check for `null` before access.

---

## Exceptions and errors

- **Try/catch/finally:**

  ```monkeyc
  try {
      risky();
  } catch (e) {
      // handle/log
  } finally {
      // cleanup
  }
  ```

- **Throwing:**

  ```monkeyc
  throw new Exception("Invalid state");
  ```

- Only documented exception classes.

---

## Toybox API usage

- **Imports at top** (no aliasing):

  ```monkeyc
  import Toybox.System;
  import Toybox.WatchUi;
  import Toybox.Graphics;
  import Toybox.Lang;
  ```

- **Drawing basics:**

  ```monkeyc
  function drawCenter(dc, text) {
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
      dc.clear();
      var w = dc.getWidth();
      var h = dc.getHeight();
      dc.drawText(w/2, h/2, Graphics.FONT_MEDIUM, text, Graphics.TEXT_JUSTIFY_CENTER);
  }
  ```

- **Watch Face onUpdate:**

  ```monkeyc
  function onUpdate(dc) {
      var t = System.getClockTime();
      var timeStr = Lang.format("$1$:$2$", [t.hour, t.min]);
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
      dc.clear();
      dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_XLARGE, timeStr, Graphics.TEXT_JUSTIFY_CENTER);
  }
  ```

---

## Performance and memory

- Avoid allocations in `onUpdate`/`onPartialUpdate`.
- Stop timers in `onEnterSleep`; restart in `onExitSleep`.
- Use constants over magic numbers.
- Precompute layout in `onLayout`.

---

## Common pitfalls (reject these)

- Arrays:
  - ❌ `var xs = new [1,2,3];`
  - ✅ `var xs = [1, 2, 3];`

- Dictionaries:
  - ❌ `{ "theme": "dark" }`
  - ✅ `{ :theme=>"dark" }`

- Strings:
  - ❌ `if (a == b)`
  - ✅ `if (a.equals(b))`

- Imports:
  - ❌ `using Toybox.Graphics as G;`
  - ✅ `import Toybox.Graphics;`

---

## Golden snippet

```monkeyc
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

class Screen extends WatchUi.WatchFace {
    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc) {
        var t = System.getClockTime();
        var s = Lang.format("$1$:$2$", [t.hour, t.min]);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.clear();
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_XLARGE, s, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onEnterSleep() { }
    function onExitSleep() { }
    function onPartialUpdate(dc) { }
}
