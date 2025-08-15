using Toybox.Math;

//! Utility class to hold common helper methods
class Utility {
    static function convertCoorX(radians, radius) {
        return center_x + radius * Math.cos(radians);
    }

    static function convertCoorY(radians, radius) {
        return center_y + radius * Math.sin(radians);
    }
}