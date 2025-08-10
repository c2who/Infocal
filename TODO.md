# Developer TODO List

## Improvements

[ ] Fix mainDrawComponents to only update screen_buffer if data is changed
    All Views currently fully re-draw on every call to draw() so screen_buffer 
    is not currently saving any execution time!
   

## Wish List

[ ] Update application to use Application.Properties, Application.Storage (API level 2.4.0+)
    https://developer.garmin.com/connect-iq/core-topics/persisting-data/
    (1) Background processes cannot save Properties.
    (2) Application.Storage can save in background process since ConnectIQ 3.2.0

