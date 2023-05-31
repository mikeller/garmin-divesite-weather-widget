import Toybox.Lang;
import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Time;
import Toybox.Time.Gregorian;

(:glance)
class YrDataCache {
    static function tryGetCachedData(latitude as Float, longitude as Float, ignoreExpiry as Boolean) as Array<Dictionary>? {
        var data = Storage.getValue(Utils.locationToString(latitude, longitude));
        if (data != null) {
            try {
                var properties = (data as Dictionary<String, Dictionary>)["properties"] as Dictionary<String, Dictionary>;

                var timeseries = properties["timeseries"] as Array<Dictionary>;
            
                if (ignoreExpiry) {
                    Utils.log("Cache hit: " + Utils.locationToString(latitude, longitude));

                    return timeseries;
                }

                var expiresString = (properties["meta"] as Dictionary<String, String>)["expires"] as String;
                var expires = Utils.parseIsoDate(expiresString);
                if (expires != null && (expires as Moment).greaterThan(Time.now())) {
                    Utils.log("Cache hit (expiry: " + expiresString + "): " + Utils.locationToString(latitude, longitude));

                    return timeseries;
                }
            } catch (exception instanceof UnexpectedTypeException) {
                Utils.log("Cache data format problem: " + exception.getErrorMessage());
                exception.printStackTrace();
            }
        }

        Utils.log("Cache miss.");

        return null;
    }

    static function setCachedData(latitude as Float, longitude as Float, data as Dictionary<String, PropertyValueType>) as Void {
        Storage.setValue(Utils.locationToString(latitude, longitude), data);
    }
}