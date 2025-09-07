import Toybox.Activity;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Application.Storage;

//! Location utility for managing and validating location data
module Location {

    //! Update last (known) location.
    //! Persists location for later use (e.g. after app restart)
    function updateLastLocation() as Void {
        // Try to get current location from activity
        var activityInfo = Activity.getActivityInfo();
        var currentLocation = null;
        var currentLocationAccuracy = null;
        if ((activityInfo != null) && (activityInfo.currentLocation != null)) {
            currentLocation = (activityInfo.currentLocation as Position.Location).toDegrees(); // double
            currentLocationAccuracy = activityInfo.currentLocationAccuracy;
        }

        if ((currentLocation != null) && isValidLocation(currentLocation, currentLocationAccuracy)) {
            // Use current location if valid
            var lat = currentLocation[0].toFloat();
            var lon = currentLocation[1].toFloat();
            $.gLocation = [lat, lon];
            Storage.setValue("LastLocation", [lat, lon]);
        } else {
            // Fallback to stored location if valid
            var storedLocation = Storage.getValue("LastLocation") as [Float, Float]?;
            if ((storedLocation != null) && isValidLocation(storedLocation, null)) {
                $.gLocation = storedLocation;
            } else {
                // No valid location, clear stored value if present
                if (storedLocation != null) {
                    Storage.deleteValue("LastLocation");
                }
            }
        }
    }

    //! Validates location coordinates
    //! @param degrees Array containing [latitude, longitude]
    //! @return true if location is valid, false otherwise
    function isValidLocation(degrees as [Double, Double] or [Float, Float], accuracy as Position.Quality?) as Boolean {
        // [180,180] is invalid location
        var isValid = ((degrees[0] >=-90) && (degrees[0] <= 90) && (degrees[1] >=-180) && (degrees[1] <= 180));

        // special case: treat [~0,~0] as invalid  (sorry Null Island!)
        var isNull = ((degrees[0].abs() < 0.02) && (degrees[1].abs() < 0.02));

        if (IS_DEBUG || !isValid || isNull) {
            debug_print(:location, "loc: [$1$, $2$] acc=$3$ [$4$]", [
                degrees[0].format("%0.3f"),
                degrees[1].format("%0.3f"),
                accuracy,
                (isValid && !isNull) ? "ok" : "invalid" ]);
        }
        return (isValid && !isNull);
    }
}
