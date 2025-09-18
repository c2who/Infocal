# Solar Intensity Supported Devices

This document lists all Garmin Connect IQ devices that support the `solarIntensity` system statistic.

## Supported Devices

Solar intensity is available on devices with solar charging capabilities, typically requiring API Level 3.2.0 or higher.

### Fenix Series
- fenix6xpro (solar variants)
- fenix7 series (solar variants)
- fenix7pro series (solar variants)
- fenix7x series (solar variants)
- fenix7xpro series (solar variants)
- fenix8solar47mm
- fenix8solar51mm

### Instinct Series
- instinct2 (solar variants)
- instinct2s (solar variants)
- instinct2x (solar variants)
- instinct3solar45mm
- instinctcrossover (solar variants)

### Enduro Series
- enduro (solar variants)
- enduro3

### Other Series
- approachs7042mm (solar variants)
- approachs7047mm (solar variants)
- descentg1
- fr955

## Notes

- Solar intensity represents the current solar charging intensity as a percentage (0-100%)
- Value may be null when solar charging is not active or data is unavailable
- Some devices may have different solar charging capabilities or reporting frequencies
- Solar intensity is only available when the device is actively exposed to light sources

## API Requirements

- Requires Connect IQ API Level 3.2.0 or higher
- Uses `System.getSystemStats().solarIntensity`
- Requires `System.Stats has :solarIntensity` capability check
