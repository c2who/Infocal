# Developer TODO List

## Improvements

[ ] FIXME: [Power] Fix mainDrawComponents to only update screen_buffer if data is changed
    All Views currently fully re-draw on every call to draw() so screen_buffer 
    is not currently saving any execution time!

[ ] FIXME: [Memory] Reduce number of ArcText fonts from 60 to 30 (reduce memory use)
    ArcText loads 60 (sixty) font resources to render bezel text.  Remove half
    of them, as they are identical to font set at 180° on bezel!

[ ] FIXME: [Memory] Update application to use Application.Properties, Application.Storage (API level 2.4.0+)
    https://developer.garmin.com/connect-iq/core-topics/persisting-data/
    (1) Background processes cannot save Properties.
    (2) Application.Storage can read/saved in background process since ConnectIQ 3.2.0

## Wish List
