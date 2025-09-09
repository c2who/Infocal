---
applyTo: "tests/**/*.mc"
---

# Monkey C Test Instructions — /tests Folder Only

These instructions apply **exclusively** to `.mc` files in the `/tests` folder.
All tests in this folder **must be valid Monkey C code that compiles**.
No intentionally broken or invalid syntax is permitted here — if a test is “broken,” it should be fixed to compile and run.

---

## Authoritative references

- Unit Testing (Core Topic): https://developer.garmin.com/connect-iq/core-topics/unit-testing/
- Toybox.Test API: https://developer.garmin.com/connect-iq/api-docs/Toybox/Test.html

---

## Folder scope

- **All unit tests must reside in `/tests`**.
- These rules **do not** apply to any `.mc` file outside `/tests`.
- Copilot must not suggest creating test files in other folders.

---

## File structure

- All test files must begin with imports for required modules:

  ```monkeyc
  import Toybox.Application;
  import Toybox.Lang;
  import Toybox.System;
  import Toybox.Test;
  ```

- Do **not** alias modules with `as`.

---

## Test function rules

- Annotate each test with `(:test)` immediately before the function.
- Signature: one parameter `logger` of type `Test.Logger`.
- Return `true` if the test contains assertions (and it should); assertions will signal any failures.
- Use `logger.debug()`, `logger.info()`, `logger.error()` sparingly for output.

---

## Assertions — **Mandatory Message Parameter**

- Always use the `*Message` variants:
  - `Test.assertMessage(...)`
  - `Test.assertEqualMessage(...)`
  - `Test.assertNotEqualMessage(...)`
- **Message content must include the actual value under test** for clarity.

  **Examples:**
  ```monkeyc
  Test.assertMessage(ams.equals(label), "\"" + label + "\" should return 'am'");
  Test.assertEqualMessage(expected, actual, "Expected " + actual + " to equal " + expected);
  Test.assertNotEqualMessage(a, b, "Expected " + a + " to differ from " + b);
  ```

- Do **not** use `Test.assert()` or `Test.assertEqual()` without a message in this folder.

---

## Compiler Warnings

- The compiler warning `Passing 'Any' as parameter ...` can be safely ignored.
  - It is because the class under test does not use strong typing, so the default type in Monkey C is `Any`.
  - Monkey C is a Duck-Typed language, the test code will still run fine.
  - I have added strong type hints to the #file:TestActiveField.mc file, so you can see how this warning can be resolved; But please just ignore these warnings in other test files.

---

## Common pitfalls to avoid in generated tests

- ❌ Omitting `(:test)` annotation.
- ❌ Using `==` for string equality — use `.equals()` or `Test.assertEqualMessage()`.
- ❌ Forgetting to import `Toybox.Test`.
- ❌ Using assertions without a message.
- ❌ Creating tests outside `/tests`.

---

## Golden test patterns

**Basic assert with message:**
```monkeyc
(:test)
function basicAssert(logger) {
    var val = System.getClockTime().hour;
    Test.assertMessage(val < 24, "Hour value was " + val + ", should be less than 24");
    return true;
}
```

**Equality with message:**
```monkeyc
(:test)
function eqWithMessage(logger) {
    var expected = "am";
    var label = "ams".substring(0, 2);
    Test.assertEqualMessage(expected, label, "\"" + label + "\" should equal \"" + expected + "\"");
    return true;
}
```

**Not‑equal with message:**
```monkeyc
(:test)
function notEqWithMessage(logger) {
    var a = 5;
    var b = 10;
    Test.assertNotEqualMessage(a, b, "Expected " + a + " to differ from " + b);
    return true;
}
```

**Type of with message:**
```monkeyc
(:test)
function typeOfWithMessage(logger) {
    var value = "hello";
    Test.assertMessage(value instanceof String, "Value should be of type String");
    return true;
}
```

- There is no way to get the type name as a string in Monkey C, so include the expected type in the message manually.

---

## Do / Don’t

- **Do:** Keep all tests in `/tests`, use `Test.assert*Message()` with actual values in messages, annotate with `(:test)`, import `Toybox.Test` at the top.
- **Don’t:** Create tests outside `/tests`, use assertions without messages, invent assertion methods, or use Java/JS assert styles.
