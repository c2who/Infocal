import Toybox.Application;
import Toybox.Lang;

/* CUSTOM TEXT */
class CTextField extends BaseDataField {
   function initialize(id as Number) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var custom_text = Properties.getValue("ctext_input");
      if (custom_text.length() == 0) {
         return "--";
      }
      return custom_text;
   }
}
