import Toybox.Lang;
import Toybox.Math;
import Toybox.Application;
import Toybox.Application.Properties;

(:glance)
class WeatherAppProperties {
    static function getLocationsProperty() as Array<Dictionary>? {
        var locations = Properties.getValue("locations") as Array<Dictionary>;

        if (locations != null) {
            var needsUpdate = false;
            for (var i = 0; i < locations.size(); i++) {
                var latitude = locations[i]["latitude"] as Float;
                var latitudeSanitised = Math.round(latitude * 1000) / 1000;
                if (latitudeSanitised != latitude) {
                    locations[i]["latitude"] = latitudeSanitised;
                    needsUpdate = true;
                }

                var longitude = locations[i]["longitude"] as Float;
                var longitudeSanitised = Math.round(longitude * 1000) / 1000;
                if (longitudeSanitised != longitude) {
                    locations[i]["longitude"] = longitudeSanitised;
                    needsUpdate = true;
                }
            }

            if (needsUpdate) {
                Properties.setValue("locations", locations as Array<PropertyValueType>);

                System.println("Locations sanitised");
            }
        }

        return locations;
    }

    static function getCustomUrl() as String? {
        var customUrl = Properties.getValue("customUrl");
        if ("".equals(customUrl)) {
            customUrl = null;
        }

        return customUrl;
    }
}