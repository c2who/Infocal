# Change Log
• Summary of changes released to the [Garmin App Store](https://apps.garmin.com/apps/f86d1406-8272-4ede-abe5-cc566dd8e2d6)

-----------------------------


⭐️ Added IQAir Air Quality ⭐️
** Read the FAQ above to obtain your free Air Quality api key **

⭐️ I am currently adding new features and squashing bugs! - please check back regularly for updates - and use the "Contact Developer" button to report any issues, so I can fix them for you ⭐️

2025.8.11 -- Bug Fixes
• fixed communication error caused unhandled exception
• fixed schema change handling

2025.8.10 -- Low Memory optimization
• reduce background memory and payload data size (fixes low memory issues on Fenix and similar watches)
• fixed runtime null-pointer crash

2025.8.9 -- Bug Fixes
• handle web request background data received before View created (fixes app crash)

2025.8.8 -- Bug Fixes
• show hr/seconds in high power mode; remove if power budget exceeded
• tolerate unexpected data on web request

2025.8.7 -- Bug Fixes
• prevent use of buffering if available memory insufficient (fixes crash on fenix watches)
• handle BLE errors in communications
• clear clip region on update (fixes screen not updating on older watches when hr/seconds displayed)
• add defensive code against possible runtime errors

2025.8.6 -- Air Quality api key changes
• air quality updates every 30 minutes if using your own free api key (every 6 hours if you have not added your own api key)

2025.8.5 -- Stability improvements
• handle exception caused by invalid server response

2025.8.4 -- Stability improvements
• add runtime crash detection to disable in-memory buffering on lower-memory devices.

2025.8.3 -- Bug Fixes
• update default api key

2025.8.2 -- Bug Fixes
• add warning text for default api key quota reached "ERR 429" / "API KEY"
• fixed "main" digital time display position on all watch layouts
• fixed margin/alignment issues with "main" digital time fonts
• auto-hide seconds and heart-rate if always-on not available / power budget exceeded
• add back-off and retry to web requests, pause if phone not connected

2025.8.1 -- Bug Fixes
• fixed crash when buffering disabled
• fixed Group notification
• fixed "G" character rendering on arc text

2025.8.0 -- First Release
⭐️ Added IQAir Air Quality ⭐️
