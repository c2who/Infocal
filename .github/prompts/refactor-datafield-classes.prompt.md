---
description: "Refactor DataField Classes to Individual Files"
mode: agent
model: ${input:model:Claude Sonnet 3.7}
---

## Goal
Move each class currently stored in grouped files in `/source/datafield` to individual files, with the below guidelines and exceptions.

Work on each file one at a time, ensuring all imports/usages are updated accordingly.

## Guidelines
- Each class should be placed in its own `.mc` file named after the class (e.g., `SolarIntensity` → `SolarIntensity.mc`).
- If two or more classes are tightly coupled (e.g., Time-related fields), they may remain together in a single file. Use your judgment and add a comment explaining the grouping.
- The `SolarIntensity` class in `SolarIntensity.mc` is a model example: the file name matches the class, and the file contains only that class.
- Update all imports/usages throughout the codebase to reference the new file locations.
- Remove the original grouped files after migration.
- Do not change class names or logic—only move and update file structure and imports.
- Maintain explicit Toybox imports at the top of each file.
- Keep the `/source/datafield` directory structure flat unless a clear sub-grouping is required for related classes.

## Exceptions
- Closely related classes (e.g., all Time-related fields) may be grouped in a single file. Add a comment at the top explaining the grouping.
- Do not split classes that are tightly coupled or depend on each other for correct operation.

## Example
- `SolarIntensity` class → `SolarIntensity.mc` (already correct)
- If `TimeToRecovery` and `RecoveryTimeHelper` are tightly coupled, keep both in `TimeToRecovery.mc` with a comment.

## Deliverables
- All classes in `/source/datafield` are in their own file (or grouped as per above), with updated imports/usages, and no unused grouped files remain.
- This prompt file should be saved as `.github/prompts/refactor-datafield-classes.prompt.md`.

## Logging
- Document all changes made during the refactoring process, including file moves, import updates, and any code changes.
- Log any issues encountered and how they were resolved.
- store this log in `.github/logs/refactor-datafield-classes.log.md`.
