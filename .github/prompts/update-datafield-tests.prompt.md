---
description: Write unit tests for DataField classes in the `/tests` directory.
mode: agent
model: ${input:model:claude-sonnet-4}
---

# Add DataField Tests Prompt

## Objective
Create/update unit tests (in output folder `/tests/datafield`) for each of the classes/files in `/source/datafield`
1. Add test to ensure each method in class returns an expected output.
2. Where this is non-trivial, test the method returns a value and does not throw an exception.

## Pre-requisites
- Read and understand the testing framework documented at:
  https://developer.garmin.com/connect-iq/api-docs/Toybox/Test.html
- Read the references to get an idea of the testing framework and conventions used in this project:
  https://developer.garmin.com/connect-iq/core-topics/unit-testing/

## Instructions

# Goal
Generate all test classes/files for every source class/file in `/source/datafield`.

# Steps

## 1. **Setup Log File to record Progress and Errors:**
   - Create a log file named `/.github/logs/update-datafield-tests.log.md` (if the log file already exists, overwrite it; note ).
   - Write the model used and the time the prompt file was executed in the log file.
   - Write the local date and time the task was started, completed, and which model was used to execute the prompt in the log file.
   - For each step below, write progress updates and any errors/issues encountered to the log file

## 2. **Iterate over Source/Test Files:**
- For each file in `/source/datafield`:
   - Create/update a corresponding test file in `/tests/datafield` named `Test<ClassName>.mc`
     (e.g., for `SolarIntensity.mc`, create `TestSolarIntensity.mc`).
   - If a corresponding test file already exists, review and update it to ensure all methods in each class are covered.
   - If a test file does not exist, create a new one.

### 2.1 **Iterate over Source/Test classes:**
- For each class in each source file:
   - If a corresponding Test function exists,review and update it to ensure all methods in the class are covered.
   - If a test function does not exist, it.

# **Testing Requirements:**
- Ensure that each method in the DataField classes is covered by a unit test.
- Validate that methods return expected outputs or, in non-trivial cases, return a value without throwing exceptions.

# **Directory Structure:**
- Write tests in the `/tests/datafield` directory.
- Ensure that the tests align with the refactored structure of `/source/datafield`.

# **Output:**
- The unit tests should be written in a format compatible with the existing testing framework used in the project (The Connect IQ SDK has Run No Evil).
- see `/tests/datafield/TestSolarIntensity.mc` for an example test file (feel free to improve on this  example, where necessary).
- Ensure that the tests are organized and named clearly to reflect the class they are testing;
- Ideally, all methods in a class should tested be in a single test function.

# Guidelines
- **DO** Make the actual changes in the files, not just comments or suggestions.

# Syntax and Conventions
- Use the same coding style and conventions as the existing codebase.
- ensure test code complies with #file:monkeyc.instructions.md  and #file:monkeyc-tests.instructions.md
- See the Garmin Monkey C documentation for more details: https://developer.garmin.com/connect-iq/monkey-c/monkey-types/ and all other relevant documentation under https://developer.garmin.com/connect-iq/monkey-c/.

# Hallucination Guardrails
- **DONT** make up any functionality or methods that do not exist in the source files.
- **DONT** make up any functionality or methods that do not exist in Toxybox APIs
- **DONT** use JSON syntax, Java syntax, or any other syntax that is not supported by Connect IQ.
- **DONT** use any libraries or packages that are not supported by Connect IQ.
- **DONT** use any classes or methods that are not supported by Connect IQ.
- **DONT** use any syntax that is not supported by Connect IQ.
- **DONT** use Test methods that are not supported by Connect IQ (see https://developer.garmin.com/connect-iq/api-docs/Toybox/Test.html).
- Storage.setValue(...) and Storage.getValue(...) can be used to persist and check stored data, e.g. for mocking.
- the syntax for checking if a value is of a type is `value instanceof Type`.
- There are no apis for mocking System.getDeviceSettings() or System.getDeviceInfo(), and most other Toxybox apis.

# Progress Checkpoints
- After completing tests for each class/file, write a progress update to the log file.
- continue, and at the end of your turn, continue again each time until all tests have been completed

# Example Test Files
- see `/tests/datafield/TestSolarIntensity.mc` for an example test file
- see `/tests/datafield/TestCaloField.mc` for another example test file
- (feel free to improve on this  example, where necessary).
