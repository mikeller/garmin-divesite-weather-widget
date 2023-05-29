import Toybox.Lang;
import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Time;
import Toybox.Time.Gregorian;

(:glance)
class YrDataCache {
    static function tryGetCachedData(latitude as Float, longitude as Float, ignoreExpiry as Boolean) as Array<Dictionary>? {
        var data = Storage.getValue(Conversions.locationToString(latitude, longitude));
        if (data != null) {
            try {
                var properties = (data as Dictionary<String, Dictionary>)["properties"] as Dictionary<String, Dictionary>;

                var timeseries = properties["timeseries"] as Array<Dictionary>;
            
                if (ignoreExpiry) {
                    return timeseries;
                }

                var expires = Conversions.parseIsoDate((properties["meta"] as Dictionary<String, String>)["expires"] as String);
                if (expires != null && (expires as Moment).greaterThan(Time.now())) {
                    return timeseries;
                }
            } catch (exception instanceof UnexpectedTypeException) {
                return null;
            }
        }

        return null;
    }

    static function setCachedData(latitude as Float, longitude as Float, data as Dictionary<String, PropertyValueType>) as Void {
        Storage.setValue(Conversions.locationToString(latitude, longitude), data);
    }
}