---
description: "Update API_REFERENCE.md from source, and generate a table of FIELD_TYPE_* enums with details."
mode: agent
model: ${input:model:gpt-5 mini}
---

## Objective
Regenerate the `docs/API_REFERENCE.md` file from the actual Infocal source code in `source/datafield/`, ensuring it is accurate, up to date, and includes the numeric enum value as the first column.  Open any files needed in the @workspace if not already open.

## Context
- This is a Garmin Connect IQ Monkey C project.
- All data field types are defined in `source/datafield/DataFactory.mc` as `FIELD_TYPE_*` constants mapped to specific `*Field` classes.
- Each `*Field` class is implemented in its own `.mc` file in `source/datafield/`.
- Monkey C uses `using Toybox.<Module>` imports to access Garmin APIs.
- API calls are typically in the form `<Module>.<FunctionName>()`.

---

## Steps

### 1. **Parse `DataFactory.mc`**
   - Extract every `FIELD_TYPE_*` constant and the class it instantiates (e.g., `FIELD_TYPE_HEART_RATE` → `HRField`).
   - Preserve the order they appear in the file.
   - Determine the numeric index, by looking at the FIELD_TYPE_* position in the `FIELD_TYPES` enum (zero-based).

---

### 2. **Inspect each class file** in `source/datafield/`:
   - Identify **Purpose**: Summarise what the field displays, based on code logic and any inline comments.
   - Identify **Toybox API Modules**: List the `using Toybox.*` imports in that file related to the sensor field; ignore generic imports like `Toybox.Lang`.
   - Identify **Key API Calls**: List the specific API calls made (e.g., `Sensor.getHeartRate()`).
   - Identify **Notes**: Mention any calculations, derived values, device‑specific availability, or external API usage (e.g., OpenWeather, IQAir).
   - If a field type maps to a missing or unresolved class file, set Purpose to “Unknown (source file not found)” and add a note.

---

### 3. **Generate a Markdown table** with columns:
   - `#` (numeric index from step 1)
   - Field Type Enum (FIELD_TYPE_*)
   - Class / Source File (link to relative path, note that this reference will be stored in the docs folder, so paths should start with `../source/`)
   - Purpose
   - Toybox API Modules (include only Modules related to reading/processing the sensor data)
   - Key API Calls
   - Notes

---

### 4. **Order** the table in the same sequence as `FIELD_TYPE_*` enums in `DataFactory.mc`.

---

### 5. **Write the output** to `docs/API_REFERENCE.md` with:
   - Title: `# Infocal – API Reference`
   - Timestamp line: `Auto-generated from source/datafield on YYYY-MM-DD HH:MM UTC_`
   - The generated table.

### 6. **Write a log of all actions taken**
- Finally, Document all your changes in a new markdown file `.github/logs/update-api-reference.log.md` with:
  - The objective
  - The steps you took
  - Any assumptions or decisions made
  - Any issues encountered and how you resolved them
- If the file already exists, overwrite it.

---

## Formatting rules:
   - Use GitHub‑flavored Markdown.
   - Wrap code identifiers in backticks.
   - Link each class name to its relative `.mc` file path in the repo (e.g., `[HRField.mc](../source/datafield/DeviceData.mc)`).
   - Keep the table clean and aligned for human readability of the markdown source file.
   - For “Toybox API Modules” and “Key API Calls”:
     - Dedupe entries and sort alphabetically.
     - Join items with `, `.
     - Prefer fully qualified call names when available (e.g., `Position.getInfo()` over internal helpers).

# Guidelines
- there are over 40 FIELD_TYPE(s) - some point to the same class - each FIELD_TYPE_ must have its own entry in the table
- if `FIELD_TYPES` enum order differs from constant declaration order, the enum order wins (indexes are zero‑based from the enum)
- if the enum contains values not mapped in the factory, still include them with a clear note and blank class link

## Example table row
| #  | Field Type Enum | Class / Source File | Purpose | Toybox API Modules | Key API Calls | Notes |
|----|-----------------|---------------------|---------|--------------------|---------------|-------|
| 0  | `FIELD_TYPE_HEART_RATE` | [`HRField`](../source/datafield/DeviceData.mc) | Current heart rate (BPM); falls back to history when needed. | `Toybox.Activity`, `Toybox.ActivityMonitor`, `Toybox.System`, `Toybox.Time` | `Activity.getActivityInfo()`, `ActivityMonitor.getHeartRateHistory()` | Returns 0 when no HR; `_retrieveHeartrate()` handles fallbacks. |


---
