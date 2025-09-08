 Copilot Instructions for This Repository

## Language & Platform
- All code in this repository is written in **Monkey C** for the **Garmin Connect IQ** platform.
- Use only APIs and modules from the official Garmin Connect IQ SDK.

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
- **Do not invent APIs, methods, or modules.**
- If an API or method is not part of the Garmin Connect IQ SDK, explicitly state that it does not exist and suggest an alternative.
- When unsure, ask for clarification instead of guessing.

## Multi‑File Awareness
- When referencing functions from other modules in this repo, use correct import syntax and match existing patterns.
- Maintain separation of concerns — keep utility functions in `utils` path.

## Documentation
- Add concise comments for non‑obvious logic.
- Document function purpose, parameters, and return values where helpful.