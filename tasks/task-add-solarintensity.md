# TASK: Add `solarIntensity` System Stats Field to Watchface Application

## Objective
You are working in my watchface application repository.
Implement a new `solarIntensity` system stats field in the watchface application, ensuring it is fully integrated into data handling, UI strings, device support configuration, and resources.

Use TimeToRecovery as an example of how to implement this best.

---

## Steps

For each step:
   - Search the workspace to locate the relevant files (even if they are not currently open).
   - Make the required edits following the repo’s existing naming conventions, style, and comment patterns.
   - If multiple files match a name, choose the one in the correct package/module for the watchface application.
   - After completing each step, continue with the next step

### 1. Data Layer Updates
- **Add to DataFactory**
  - Add a new `SolarIntensity` field to `DataFactory`.
  - Follow the existing pattern for other system stats fields.
- **Update FIELD_TYPES enum**
  - Add a new enum entry for `SOLAR_INTENSITY` (naming consistent with existing style).

---

### 2. Data Field Class
- Create a new `SolarIntensityDataField` class.
- Follow the same structure, naming conventions, and method patterns as other data field classes.
- Include comments for any edge cases or special handling.

---

### 3. Strings
- Add `"Solar Intensity"` to `strings.xml`.
- Ensure the string key follows the naming convention used for other system stats fields.

---

### 4. Device Support

#### 4.1 Documentation
- Create a new markdown file (e.g., `docs/solarIntensity-supported-devices.md`).
- List all devices that support `solarIntensity`.
- Include any notes about capability differences between devices.

#### 4.2 monkey.jungle
- Update `monkey.jungle` to group all devices that support `solarIntensity`.
- Maintain existing grouping style and comments.

#### 4.3 Resource Folder
- Create a new `resource-feat-solar` folder.
- Copy `settings.xml` from `resource-feat-hrv` as a starting point.
- Modify it to include `solarIntensity` in the `settingConfig` section for devices that support it.

---

### 5. Settings Integration
- In `settings.xml` for devices with `solarIntensity`:
  - Add `solarIntensity` to the `DataField` list in `settingConfig`.
  - Ensure the list contains **all** data fields supported by that device.
- For devices with different solar capabilities:
  - Create a **separate** `resource-feat-solar` folder and `settings.xml` file.
  - Add a separate section in `monkey.jungle` for these devices.

---

### 6. Finally
- Finally, Document all your changes in a new markdown file

---

## Caveats
- Some solar devices may have **different capabilities** — handle these separately.
- Keep naming, formatting, and file structure consistent with the existing codebase.
- Follow the **commenting convention** in each file, adding detail for tricky or edge-case logic.

---

## Checking
1. **Compile** the code and resolve any errors.
2. **Review** all changes for correctness and adherence to style.
3. **Verify** that each `settings.xml` matches the capabilities of its target devices.
4. **Test** on at least one device that supports `solarIntensity`.

---

## Guidelines
- Find these files in the workspace if they’re not open.
- Follow **existing naming conventions** and **code style**.
- Maintain **clear, descriptive comments** for any non-obvious logic.
- Keep changes **modular** and **consistent** with similar features.
- create any new files in the correct folder structure.
- when updating `settings.xml` for specific devices, search the workspace for those files and update them accordingly.
- `monkey.jungle` can be found in the root folder.
- for adding documentation, create the `.md` file in the `docs` folder.


---