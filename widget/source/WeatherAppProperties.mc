import Toybox.Lang;
import Toybox.Math;
import Toybox.Application;
import Toybox.Application.Properties;

(:glance)
class WeatherAppProperties {
    static function getLocationsProperty() as Array<Dictionary>? {
        var locations = Properties.getValue("locations") as Array<Dictionary>?;

        if (locations != null) {
            var needsUpdate = false;
            var i = 0;
            while (i < locations.size()) {
                var location = locations[i];
                var latitude = location["latitude"] as Float;
                var latitudeSanitised = Math.round(latitude * 1000) / 1000 as Float;
                if (latitudeSanitised != latitude) {
                    location["latitude"] = latitudeSanitised;

                    Utils.log("Location latitude truncated: " + latitude + " => " + latitudeSanitised);

                    needsUpdate = true;
                }

                var longitude = location["longitude"] as Float;
                var longitudeSanitised = Math.round(longitude * 1000) / 1000 as Float;
                if (longitudeSanitised != longitude) {
                    location["longitude"] = longitudeSanitised;

                    Utils.log("Location longitude truncated: " + longitude + " => " + longitudeSanitised);

                    needsUpdate = true;
                }

                var j;
                for (j = 0; j < i; j++) {
                    var firstLatitude = locations[j]["latitude"] as Float;
                    var firstLongitude = locations[j]["longitude"] as Float;

                    if (latitudeSanitised == firstLatitude && longitudeSanitised == firstLongitude) {
                        locations.remove(location);
                        needsUpdate = true;

                        Utils.log("Duplicate location removed: " + location.toString());

                        break;
                    }
                }

                if (j == i) {
                    i++;
                }
            }

            if (needsUpdate) {
                Properties.setValue("locations", locations as Array<PropertyValueType>);
            }
        }

        return locations;
    }

    static function getCustomUrl() as String? {
        var customUrl = Properties.getValue("customUrl") as String;
        if ("".equals(customUrl)) {
            customUrl = null;
        }

        return customUrl;
    }
}