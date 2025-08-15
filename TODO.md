# Developer TODO List

## Improvements

[ ] FIXME: [Power] Fix mainDrawComponents to only update screen_buffer if data is changed
    All Views currently fully re-draw on every call to draw() so screen_buffer 
    is not currently saving any execution time!

[ ] FIXME: [Memory] Update application to use Application.Properties, Application.Storage (API level 2.4.0+)
    https://developer.garmin.com/connect-iq/core-topics/persisting-data/
    (1) Background processes cannot save Properties.
    (2) Application.Storage can read/saved in background process since ConnectIQ 3.2.0

[ ] FIXME: [Display] Fix the broken Digital and Analog complication layout on many watch sizes 

[ ] FIXME: [Display] onPartialUpdate() measures Graphics Time as 5310000 µsec (5.3 seconds) - even with nothing diplayed!
    This is causing onPowerBudgetExceeded() to trigger - on both Simulation and real hardware :/

## Wish List
