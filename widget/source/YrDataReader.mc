import Toybox.Lang;
import Toybox.Application;
import Toybox.Communications;

class YrDataReader {
    private const DATA_PATH as String = "data";
    private const STATUS_PATH as String = "status";

    private var baseUrl as String = "https://garmin-divesite-weather-widget-service.azurewebsites.net/";

    private var connectionProblem as Boolean = false;

    private var requestIsRunning as Dictionary<Number, Boolean> = {} as Dictionary<Number, Boolean>;

    // YR weather data URL (too verbose for the device):
    //var url = "https://api.met.no/weatherapi/locationforecast/2.0/compact.json";
    // YR status URL:
    //var url = "https://api.met.no/weatherapi/locationforecast/2.0/status.json";

    function initialize() {
        var customUrl = WeatherAppProperties.getCustomUrl();
        if (customUrl != null) {
            baseUrl = customUrl;
        }
    }

    function getWeatherData(latitude as Float, longitude as Float, handle as Number, callback as Method(weatherData as Array<Dictionary>?, handle as Number, dataIsStale as Boolean) as Void) as Void {
        var cache = YrDataCache.tryGetCachedData(latitude, longitude, false);
        if (cache != null) {
            callback.invoke(cache as Array<Dictionary>, handle, false);

            return;
        }

        var staleDataIsShown = false;
        if (connectionProblem) {
            cache = YrDataCache.tryGetCachedData(latitude, longitude, true);
            if (cache != null) {
                staleDataIsShown = true;
            }

            callback.invoke(cache, handle, true);
        }

        if (requestIsRunning[handle]) {
            Utils.log("Request already running for handle: " + handle);

            return;
        }

        requestIsRunning[handle] = true;

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
                "handle" => handle,
                "staleDataIsShown" => staleDataIsShown,
            },
        };

        Communications.makeWebRequest(baseUrl + DATA_PATH, params, options, method(:onReceiveData));

        Utils.log("Sent request for handle: " + handle + ", " + Utils.locationToString(latitude, longitude));
    }

    function onReceiveData(responseCode as Number, data as Dictionary?, context as Dictionary<String, String or Method or Number>) as Void {
        var callback = context["callback"];
        var handle = context["handle"];

        var done = false;
        if (responseCode >= 200 && responseCode < 300 && data != null) {
            try {
                var coordinates = (data["geometry"] as Dictionary<String, String or Array>)["coordinates"] as Array<Float>;
                var timeseries = (data["properties"] as Dictionary<String, Dictionary>)["timeseries"] as Array<Dictionary>;

                YrDataCache.setCachedData(coordinates[1], coordinates[0], data as Dictionary<String, PropertyValueType>);

                connectionProblem = false;

                Utils.log("Received data for handle: " + handle + ", " + Utils.locationToString(coordinates[1], coordinates[0]));

                (callback as Method).invoke(timeseries, handle, false);

                done = true;
            } catch (exception instanceof UnexpectedTypeException) {
                Utils.log("Received data format problem for handle: " + handle + ", " + exception.getErrorMessage());
                exception.printStackTrace();
            }
        } else {
            Utils.log("Received data nok for handle: " + handle + ", " + responseCode);
        }

        if (!done) {
            connectionProblem = true;

            if (!(context["staleDataIsShown"] as Boolean)) {
                var cache = YrDataCache.tryGetCachedData(context["latitude"] as Float, context["longitude"] as Float, true);
                (callback as Method).invoke(cache, handle, true);
            }
        }

        requestIsRunning[handle] = false;
    }

    function getStatus() as Void {
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
        };

        Communications.makeWebRequest(baseUrl + STATUS_PATH, { }, options, method(:onReceiveStatus));
    }

    function onReceiveStatus(responseCode as Number, data as Dictionary?) as Void {
        if (responseCode >= 200 && responseCode < 300 && data != null) {
            Utils.log("Received status.");
            connectionProblem = false;
        } else {
            Utils.log("Received status nok: " + responseCode);

            connectionProblem = true;
        }

    }
}