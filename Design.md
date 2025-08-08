# Design Notes

## Location

OpenWeather and Air Quality fields need to know the user's location; accurate 
location is provided by the last recorded activity (using gps).
> Activity.getActivityInfo().currentLocation;

For accurate results, ensure the last Activity was for the current location.
You can start an Activity, and wait for GPS Ready to update the last known 
location; you do not need to save the activity to update the location.

## Weather

Weather related fields use the OpenWeather API to provide weather information.
> https://openweathermap.org/

OpenWeather requires the caller location. Field will display 'NO LOCN' if the
watch has not stored it's last location.

An OpenWeather API key must be provided in the application settings. A default key
can be built into the application by populating secrets.mc.

## Air Quality

Air Quality field is provided by the IQ Air Quality API
> https://www.iqair.com/world-air-quality

The Air Quality API provides the most accurate data if the location is provided; 
if the activity location is not available, the Air Quality API will fall-back
to use Geolocation by IP address (of the connected phone). 

An Air Quality API key must be provided in the application settings. A default key
can be built into the application by populating secrets.mc.

- The Air Quality field displays as "AI" - because the edge font does not 
  contain the letter 'Q'!


## Simulator
In the Garmin Simulator, you can run a recorded activity (FIT/GPX) to set
activity current location (Simulation > Activity Data).
> You can export an activity from [Garmin Connect account](https://connect.garmin.com/modern/activities)

### Simulator Limitations
The Garmin Simulator does not implent all of the device behaviors, here are some of the known limitations:
- Watch cannot enter/exit sleep mode - always in high-power mode
- OnUpdate() does not clear the screen 
  (all newer watches clear screen on update, so must perform a full screen refresh; 
  older watches allowed incremental draw on update, allowing incredible power efficiency)


