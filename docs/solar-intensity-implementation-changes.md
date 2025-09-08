# Solar Intensity Implementation Changes

This document summarizes all changes made to implement the `solarIntensity` system stats field in the watchface application.

## Files Modified

### 1. Data Layer (`source/datafield/DataFactory.mc`)
- **Added**: `FIELD_TYPE_SOLAR_INTENSITY = 41` to the FIELD_TYPES enum
- **Added**: Solar intensity case in `buildFieldObject()` function to return `SolarIntensityField`

### 2. Data Field Class (`source/datafield/SolarIntensity.mc`)
- **Created**: New `SolarIntensityField` class following the same pattern as `TimeToRecoveryField`
- **Features**:
  - Uses `System.getSystemStats().solarIntensity` API
  - Capability check with `System.Stats has :solarIntensity`
  - Returns percentage values (0-100%)
  - Handles null values gracefully with fallback to "--"
  - Supports bar data visualization
  - Display format: "SI XX%" where XX is the intensity percentage

### 3. String Resources (`resources/strings/strings.xml`)
- **Added**: `<string id="solarintensity">Solar Intensity</string>`

### 4. Device Support Configuration (`monkey.jungle`)
- **Added**: New section for solar-capable devices
- **Solar devices configured**:
  - enduro, enduro3
  - fenix6xpro (solar variants)
  - fenix7 series (solar variants)
  - fenix7pro series (solar variants)
  - fenix7x series (solar variants)
  - fenix8solar47mm, fenix8solar51mm
  - instinct2s, instinct2x (solar variants)
  - instinct3solar45mm
  - instinctcrossover (solar variants)

### 5. Solar Feature Settings (`resource-feat-solar/settings.xml`)
- **Created**: New resource folder for solar-capable devices
- **Added**: Solar intensity (value="41") to all setting configurations:
  - comp12h, comp2h, comp4h, comp6h, comp8h, comp10h
  - compbart, compbarb
- **Placement**: Added in Health Metrics section after timetorecovery

### 6. Documentation (`docs/solarIntensity-supported-devices.md`)
- **Created**: Comprehensive documentation listing all supported devices
- **Includes**: API requirements, device capabilities, and usage notes
- **Details**: Solar intensity percentage representation and null value handling

## Technical Implementation Details

### API Usage
- **Module**: `System.getSystemStats().solarIntensity`
- **API Level**: 4.0.0 minimum
- **Return Type**: Number or null (converted to Float for calculations)
- **Range**: 0-100 (percentage)

### Error Handling
- Capability check prevents crashes on non-solar devices
- Null value handling with "--" display fallback
- Graceful degradation when solar data unavailable

### Display Format
- **Label**: "SI XX%" format
- **Bar Support**: Yes (percentage-based visualization)
- **Max Value**: 100%

### Device Targeting
- Only devices with confirmed solar charging capabilities
- Separate resource path to avoid bloating non-solar device builds
- Maintains existing HRV capabilities for solar devices

## Testing Recommendations
1. Compile and test on solar-capable devices
2. Verify null handling when solar charging inactive
3. Test bar visualization with various intensity levels
4. Confirm settings appear correctly in Connect IQ Store listing
5. Validate capability checks prevent crashes on non-solar devices

## Future Considerations
- Monitor for new solar devices requiring configuration updates
- Consider adding solar intensity to graph display options
- Potential for additional solar-related metrics in future API versions
