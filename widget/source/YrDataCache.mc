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
            var properties = (data as Dictionary<String, Dictionary>)["properties"] as Dictionary<String, Dictionary or Array>;

            var timeseries = properties["timeseries"] as Array<Dictionary>;
        
            var expiresString = (properties["meta"] as Dictionary<String, String>)["expires"] as String?;
            var expires = Utils.parseIsoDate(expiresString);
            var isStale = expires == null || (expires as Moment).lessThan(Time.now());
            if (!isStale || ignoreExpiry) {
                Utils.log("Cache hit (" + (isStale ? "stale, " : "") + "expiry: " + expiresString + "): " + Utils.locationToString(latitude, longitude));

                return timeseries;
            } else {
                Utils.log("Cache miss (stale data found, expiry: " + expiresString + "): " + Utils.locationToString(latitude, longitude));

                return null;
            }
        }

        Utils.log("Cache miss" + (ignoreExpiry ? " (ignoring expiry)" : "") + ": " + Utils.locationToString(latitude, longitude));

        return null;
    }

    static function setCachedData(latitude as Float, longitude as Float, data as Dictionary<String, PropertyValueType>) as Void {
        var properties = (data as Dictionary<String, Dictionary>)["properties"] as Dictionary<String, Dictionary>;
        var expiresString = (properties["meta"] as Dictionary<String, String>)["expires"] as String?;
        Utils.log("Cache update (expiry: " + expiresString + "): " + Utils.locationToString(latitude, longitude));

        Storage.setValue(Utils.locationToString(latitude, longitude), data);
    }
}