import Toybox.System;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Time;
import Toybox.Time.Gregorian;

class YrDataReader {
    protected const DATA_PATH as String = "data";
    protected const STATUS_PATH as String = "status";

    protected var baseUrl as String = "https://garmin-divesite-weather-widget-service.azurewebsites.net/";

    protected var connectionProblem as Boolean = false;

    // YR weather data URL (too verbose for the device):
    //var url = "https://api.met.no/weatherapi/locationforecast/2.0/compact.json";
    // YR status URL:
    //var url = "https://api.met.no/weatherapi/locationforecast/2.0/status.json";

    function initialize(customUrl as String?) {
        if (customUrl != null) {
            baseUrl = customUrl as String;
        }
    }

    protected function tryGetCachedData(latitude as Float, longitude as Float, ignoreExpiry as Boolean) as Array<Dictionary>? {
        var data = Storage.getValue(locationToString(latitude, longitude));
        if (data != null) {
            try {
                var properties = (data as Dictionary<String, Dictionary>)["properties"] as Dictionary<String, Dictionary>;

                var timeseries = properties["timeseries"] as Array<Dictionary>;
            
                if (ignoreExpiry) {
                    return timeseries;
                }

                var expires = IsoDateHandler.parseIsoDate((properties["meta"] as Dictionary<String, String>)["expires"] as String);
                if (expires != null && (expires as Moment).greaterThan(Time.now())) {
                    return timeseries;
                }
            } catch (exception instanceof UnexpectedTypeException) {
                return null;
            }
        }

        return null;
    }

    function getWeatherData(latitude as Float, longitude as Float, callback as Method(weatherData as Array, success as Boolean) as Void) as Void {
        var cache = tryGetCachedData(latitude, longitude, false);
        if (cache != null) {
            callback.invoke(cache as Array<Dictionary>, true);

            return;
        }

        var cachedDataShown = false;
        if (connectionProblem) {
            cache = tryGetCachedData(latitude, longitude, true);
            if (cache != null) {
                callback.invoke(cache as Array<Dictionary>, false);

                cachedDataShown = true;
            }
        }

        var params = {
            "lat" => latitude.format("%.3f"),
            "lon" => longitude.format("%.3f"),
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :context => {
                "callback" => callback,
                "latitude" => latitude,
                "longitude" => longitude,
                "cachedDataShown" => cachedDataShown,
            },
        };

        Communications.makeWebRequest(baseUrl + DATA_PATH, params, options, method(:onReceiveData));
    }

    function onReceiveData(responseCode as Number, data as Dictionary?, context as Dictionary<String, String or Method>) as Void {
        System.println("Response: " + responseCode);

        var done = false;
        if (responseCode >= 200 && responseCode < 300 && data != null) {
            connectionProblem = false;
            try {
                var coordinates = (data["geometry"] as Dictionary<String, String or Array>)["coordinates"] as Array<Float>;
                var timeseries = (data["properties"] as Dictionary<String, Dictionary>)["timeseries"] as Array<Dictionary>;

                Storage.setValue(locationToString(coordinates[1], coordinates[0]), data as Dictionary<String, PropertyValueType>);

                (context["callback"] as Method).invoke(timeseries, true);

                done = true;
            } catch (exception instanceof UnexpectedTypeException) {
                // the data we received is bad, fall through
            }
        } else {
            connectionProblem = true;
        }

        if (!done && !(context["cachedDataShown"] as Boolean)) {
            var cache = tryGetCachedData(context["latitude"] as Float, context["longitude"] as Float, true);
            if (cache != null) {
                (context["callback"] as Method).invoke(cache as Array<Dictionary>, false);
            }
        }
    }

    function getStatus() as Void {
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
        };

        Communications.makeWebRequest(baseUrl + STATUS_PATH, { }, options, method(:onReceiveStatus));
    }

    function onReceiveStatus(responseCode as Number, data as Dictionary?) as Void {
        System.println("Status response: " + responseCode);

        if (responseCode >= 200 && responseCode < 300 && data != null) {
            connectionProblem = false;
        } else {
            connectionProblem = true;
        }

    }

    function locationToString(latitude as Float, longitude as Float) as String {
        return latitude.format("%.3f") + " " + longitude.format("%.3f");
    }
}