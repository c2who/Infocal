# Developer TODO List

## Bug Fixes

[ ] FIXME: [Display] Fix the broken Digital and Analog complication layout on many watch sizes

[ ] FIXME: [Display] onPartialUpdate() measures Graphics Time as 5310000 µsec (5.3 seconds) - even with nothing diplayed!
    This is causing onPowerBudgetExceeded() to trigger - on both Simulation and real hardware :/

## Improvements

[ ] DEPRECATED: [Memory] Upgrade application to use Application.Properties, Application.Storage (API level 2.4.0+)
    https://developer.garmin.com/connect-iq/core-topics/persisting-data/
    (1) Background processes cannot save Properties.
    (2) Application.Storage can read/saved in background process since ConnectIQ 3.2.0

[ ] FEAT: Add AMOLED / Screen burn-in protection logic (<10%pixels (venu), <10%luminance (venu2+), 3 minutes max)
    https://developer.garmin.com/connect-iq/connect-iq-faq/how-do-i-make-a-watch-face-for-amoled-products/

[ ] CLEANUP: Remove duplicate unused fonts from the resources*/fonts folders
    - arrow top     (arr_up, arr_up_sm, arr_up_big, arr_up_xbig)
    - arrow bottom  (arr_bo, arr_bo_sm, arr_bo_big, arr_bo_xbigs)
    - curve top     (cur_up, cur_up_sm, cur_up_big, cur_up_xbig)
    - curve bottom  (cur_bo, cur_bo_sm, cur_bo_big, cur_bo_xbig)
    - remove all fonts and jsons from resources/ folder if we have all the watch faces/sizes covered

[ ] FEAT: [Power] Update mainDrawComponents to only update screen_buffer if data is changed
    All Views currently fully re-draw on every call to draw() so screen_buffer
    is not currently saving much execution time!
    (writes to buffer should still be faster than writes to screen)

## Wish List

[ ] WISH [Memory, Display, Power] Add LRU Cache for Arc Text characters
    - Arc Tex: a linear BufferedBitmap operating as an LRU Cache for storing
      the Arc Text characters in use.
      Avoids the 40x Load/Free Font resources every update!
    - Reduce Screen Buffer Palette to actual characters in use
    - (Optionally) Add small BufferedBitmap to cache hour/min/month/weather/step/graph text (anti-aliased)
      saves a lot of memory by reducing palette size of Screen Buffer to <=16<<256 colors


[ ] WISH [Memory, Display, Power] Replace Screen Buffer with small seperate buffers for drawables:
    - Weather: icon BufferedBitmap + small BufferedBitmap for weather description, e.g. "CLEAR 31°C"
    - Graph(s): Single-color palette BufferedBitmap (no anti-aliasing)
    - Arc Bar Chart: Two-color palette BufferedBitmap (no anti-aliasing)
    - Tick Marks: Single-color palette BufferedBitmap (no anti-aliasing) ? Or Direct Draw
    - Digital Hour/Mins/Month: BufferedBitmap