# Copilot Instructions for This Repository

## Language & Platform
- All code is written in **Monkey C** for the **Garmin Connect IQ** platform.
- Use only APIs and modules from the official Garmin Connect IQ SDK.


## Architecture & Key Files
- **Background Service:** The app uses a background service to orchestrate the background clients.
- **Background Clients:** `source/clients/*` — minimal, stateless background clients for OpenWeather, IQAir, Heartbeat. Parsers must be tiny to avoid memory issues.
- **UI & Scheduling:** `source/InfocalView.mc` — main entry point, UI logic, and background job scheduling
- **Data Fields:** `source/dataField/*` — defines all supported data fields. Update when adding/removing fields.
- **Device Resource Mapping:** `monkey.jungle` — defines device/resource mapping. Each device section must have only one `resourcePath` entry.
- **Device Manfifest:** `manifest.xml` — lists supported devices and minimum API level. Update when adding device support.
- **Settings:** Multiple `settings.xml` files exist for different device/resource variants. All supported `DataField` entries must be included. Keep `Strings` keys alphabetized.
- **Fonts & Resources:** Font and arc text resources are managed per device size. See [DEVELOPER.md](../DEVELOPER.md#fonts) for details on font resource management and performance implications.

## Project Conventions & Patterns
- **Imports:** Always use explicit Toybox imports at the top of each file (e.g., `import Toybox.WatchUi;`).
- **Memory:** Minimize the amount of code written, avoid use of Dictionary. Use manual parsing in background clients to reduce memory usage.
- **Background Logic:** Keep all background logic stateless. Place as much logic as possible in the foreground to avoid bloating background service memory.
- **API/Device-Specific Calls:** When using device/API-specific features, append a comment with the minimum Connect IQ API requirement.
- **Data Fields:** When adding or updating data fields, ensure all relevant `settings.xml` and `Strings` entries are updated and alphabetized.
- **Font/Resource Management:** Font resources are loaded/unloaded per character for arc text.

## Style Guide
- Always import required `Toybox` modules explicitly at the top of the file.
- Keep functions short, focused, and memory‑efficient.
- Avoid unnecessary object allocations and repeated calculations.
- Use clear, descriptive variable and function names.
- Follow consistent indentation and brace style as in existing code.
- In monkey.jungle, a device’s `resourcePath` may only appear once - make sure it is in the correct section.
- In settings.xml, the `DataField` list must include **all** data fields supported by that device.
- In settings.xml, place new data fields in the correct place, to maintain alphabetical order of the related Strings value;
  note that the Strings entries are keys - you must lookup the display string in the strings.xml file

## Performance & Constraints
- Optimize for **low memory usage** and **battery efficiency** — this is wearable device code.
- Avoid blocking operations or excessive loops in UI update methods.
- Minimize allocations inside `onUpdate()` or other frequently‑called functions.

## Error & Edge‑Case Handling
- Always handle `null` returns from APIs like `System.getHeartRate()` or `Position.getInfo()`.
- For any Toxybox API usage with a supported devices / API requirement, add add this as a comment at the end of the line.
- Include graceful fallbacks when data is unavailable.
- Validate inputs before use.

## Hallucination Guardrail
- **Never invent Toybox/Connect IQ APIs.** If uncertain, reference the official SDK docs and ask for clarification.
- When changing cross-file logic, always trace from `source/InfocalView.mc` into `source/clients/*` and keep background logic stateless.

## Contribution & Code Review
- Follow the existing code style and conventions. See [DEVELOPER.md](../DEVELOPER.md) for architecture and design notes.

## Documentation
- Add concise comments for non‑obvious logic.
- Document function purpose, parameters, and return values where helpful.

## Examples & References
- For weather and air quality integration, see `source/clients/OpenWeather.mc` and `source/clients/IQAir.mc`.
- For heartbeat/diagnostics, see `source/clients/Heartbeat.mc`.
- For device/resource mapping, see `monkey.jungle` and `manifest.xml`.
