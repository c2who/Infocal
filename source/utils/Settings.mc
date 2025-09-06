import Toybox.Application;
import Toybox.Lang;

//! Utitlity (helper) methods
module Settings {

    //! Get Settings property value, or default if missing (null)
    (:background)
    function getOrDefault(key as PropertyKeyType, default_val as PropertyValueType) as PropertyValueType {
        var value = Properties.getValue(key) as PropertyValueType?;
        return (value != null) ? value : default_val;
    }

    //! Symmetrical method to set setting
    function setValue(key as PropertyKeyType, value as PropertyValueType) as Void {
        Properties.setValue(key, value);
    }

}

