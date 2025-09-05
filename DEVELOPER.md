# Developer Notes

Developer / Design notes and knowledge base to help maintain code base.

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
- OnUpdate() does not clear the screen
  (all newer watches clear screen on update, so must perform a full screen refresh;
  older watches allowed incremental draw on update, allowing incredible power efficiency)

# Fonts

## Sizes
To match different screen sizes, many of the custom Fonts are created at different Point Sizes.
The table below shows the relationship between screen size and font size.

|  Font         | Weather     | arc-text(e) | Bar(cur/arr)   | digi clock | seconds | hour/minu_hand |
|---------------|-------------|-------------|----------------|------------|---------|----------------|
| round-218x218 | (19pt) 39px |     32px    |  _sm  18px     |            |         |  24px 33 chars |
| round-240x240 | (19pt) 39px |     32px    |  _    18px     |            |         |  28px 33 chars |
| round-260x260 | (22pt) 44px |     35px    |  _big 18px 13ch|            |         |  28px 38 chars |
| round-280x280 |    "     "  |     37px    | _xbig 18px 15ch|            |         |  28px 41 chars |
| round-390x390 | (36pt 71px) |     52px    | _xbig 26px 13ch|            |         |  32px 49 chars |


## DigitalDial Fonts
The seconds and heart rate digit fonts are stored in:
  - secodigi.fntc (Samll size)
  - xsecodigi.fntc (Medium size)
  The font files have been edited to fix the incorrect lineHeight

## Arc Fonts
The arc fonts are stored in 60 (sixty) seperate font files [e0..e60] representing the angles 0° to 180°,
whereby the character set in each font file _eN__ is rotated by 3° * _N_.
To display the text around the arc:
For each character:
  1. Calculate the font resource based on angle
  2. load the font resource
  3. write out the single character at corresponding [x,y] coordinates
  4. Unload the font resource

Depending on the number of characters displayed along the circumference, a single onUpdate()
may require the loadResource() and free(null) of typically 40 (forty) different font resources for a single refresh!

Note that all fonts must be written with anti-aliasing (a grayscale of intensities) to look smooth.

# Arc Bar Data Fonts
The 5-segment bar chart along an arc, with the arrow pointer is made up of
different characters of a custom font:
- arrow top     (arr_up, arr_up_sm, arr_up_big, arr_up_xbig)
- arrow bottom  (arr_bo, arr_bo_sm, arr_bo_big, arr_bo_xbigs)
- curve top     (cur_up, cur_up_sm, cur_up_big, cur_up_xbig)
- curve bottom  (cur_bo, cur_bo_sm, cur_bo_big, cur_bo_xbig)

## Screen Buffer
The idea behind the screen buffer is that you can write (and cache) all your graphics and text in
a local buffer, so that when a full screen refresh is required (onUpdate) you can simply copy
the screen buffer to the device, saving a lot of execution time.

(1) Note: the Screen Buffer today does not provide the full benefits - onUpdate() all components are fully
redrawn into the screen buffer, before being copied to the screen.

The following drawables are written to the screen buffer:
 - Background             (dc.clear / fillRectangle)
 - BackgroundView(Ticks)  [background] drawable
 - ArcText Complication   [aBarDisplay ... fBarDisplay] drawables
 - BarData Complication   [bUBarDisplay, tUBarDisplay] drawables
 - Graph Complication     [bGraphDisplay, tGraphDisplay] drawables
 - Analog Dial            [analog] drawable
 - Digital Dial           [digital] drawable

 The following items are not stored in the screen buffer, and are written
 directly to the screen:
 - Heart rate (Always on optional)
 - Seconds (Alwyas on optional)