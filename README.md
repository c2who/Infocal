A watchface for Garmin devices, available free on the [Garmin App Store](https://apps.garmin.com/apps/f86d1406-8272-4ede-abe5-cc566dd8e2d6)

# Description

Infocal is a digital and analogue watchface, carefully made with high quality rendering.

It's both customizable and functional. With up to 8 complications on the screen, each complication can show a variety of data:

- Air Quality
- Date
- Digital time/2nd timezone
- Battery
- Total/active calories
- Live heart rate
- Distance (day/weekly)
- Move bar
- Daily steps
- Active minutes
- Notification/alarm/connection status
- Altitude
- Temperature (on-device sensor)
- Temperature (Garmin weather)
- Temperature (outside, OpenWeather)
- Temperature (high/low, OpenWeather)
- Sunrise/Sunset time (OpenWeather)
- Floor climbed
- Barometer data
- Countdown to event day
- Weather condition (OpenWeather)
- Body battery
- Stress

# Configure Settings

There are a few alternative ways to change the Watch settings:
- Using Connect IQ App on your phone (recommended)
- Using[Connect IQ Store App](https://support.garmin.com/en-US/?faq=9rNKwEDKMj2FAxqUVrsudA) on your phone
- Using [Garmin Express](https://support.garmin.com/en-CA/?faq=6Vl7EbW3qA42l63ZIhJet5) from your computer

# FAQs

## Why does Infocal Custom need user profile permission?

Infocal Custom needs access to your profile to calculate active calories, distance goal (based on your steps and stride length), and moving distance for a whole week. Infocal Custom does not store this information.

## Why does Infocal Custom need internet/background communication permission?

If using the OpenWeather for any of the features (see feature list above), internet and background communication is used to fetch data from the OpenWeather API.

## Why isn't battery days remaining available?

Battery days remaining is provided by the garmin watch.  This is supported on devices running API level 3.3.0 and newer.

## Can I see the connection status between the watch and the phone?

The group notification complication displays a "C" (connected) if the watch is connected to a phone, otherwise it will display "D" (disconnected).

## Why doesn't sunrise/sunset/OpenWeather temperature display any information?

Sunrise/sunset only works if the watch has a GPS signal. Try starting any activity that requires GPS, then wait for GPS signal. Once a GPS signal is established, return to watch face and check the complication again.

## Why is my complication data just showing "--"?

Not all complications are supported for all devices, or there is no data to display at the moment. This could be because the data isn't available (e.g., Stress is not always calculated), or the complication relies on a GPS signal that has not been established.

## A blank square is shown instead of a character?

Currently, this watch face only supports English (or Latin characters).

## How do I get an OpenWeather API key?

Go to https://openweathermap.org/, create an account, and log in. Once logged in, click on your account name in the upper right corner, then click on "My API keys". If you do not have any keys, click "Generate" and copy the newly generated key to the Infocal Custom settings.

# Credits

- ⭐️ Weather data provided by OpenWeather https://openweathermap.org/

- ⭐️ Air Quality data provided by IQAir https://www.iqair.com/ca/world-air-quality

I am not affiliated with either company - but I do think they're pretty awesome providing world-wide, accurate Weather and Air Quality data free of charge - and I think you will too :)

- ⭐️ This project was forked from [Infocal](https://github.com/RyanDam/Infocal), and would not exist if not for the work RyanDam put into that project.

- ⭐️ Special thanks to **[warmsound](https://github.com/warmsound)** for awesome [Crystal Watchface](https://github.com/warmsound/crystal-face).

- ⭐️ Special thanks to **[sunpazed](https://github.com/sunpazed)** for his awesome GitHub projects.

This project is free and will remain free under the MIT License.

