import Toybox.Lang;
import Toybox.Application;
import Toybox.System;
import Toybox.Communications;

class YrDataReader {
    private const DATA_PATH as String = "data";
    private const STATUS_PATH as String = "status";

    private var baseUrl as String = "https://garmin-divesite-weather-widget-service.azurewebsites.net/";

    private var connectionProblem as Boolean = false;

    private var concurrentRequestCount as Number = 0;
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

    function getWeatherData(latitude as Float, longitude as Float, handle as Number, callback as Method(weatherData as Array<Dictionary>?, handle as Number, requestIsCompleted as Boolean, dataIsStale as Boolean) as Void) as Boolean {
        if (concurrentRequestCount >= Constants.MAX_CONCURRENT_REQUESTS) {
            Utils.log("Concurrent request limit reached for handle: " + handle);

            return false;
        } else {
            concurrentRequestCount++;
        }

        var cache = YrDataCache.tryGetCachedData(latitude, longitude, false);
        if (cache != null) {
            callback.invoke(cache as Array<Dictionary>, handle, true, false);

            concurrentRequestCount--;
            return true;
        }

        var existingConnectionProblem = connectionProblem;
        if (existingConnectionProblem) {
            showStaleData(latitude, longitude, handle, false, callback);
        }

        if (requestIsRunning[handle]) {
            Utils.log("Request already running for handle: " + handle);

            concurrentRequestCount--;
            return true;
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
                "handle" => handle,
                "existingConnectionProblem" => existingConnectionProblem,
            },
        };

        if (System.getDeviceSettings().connectionAvailable) {
            requestIsRunning[handle] = true;

            Communications.makeWebRequest(baseUrl + DATA_PATH, params, options, method(:onReceiveData));

            Utils.log("Sent request for handle: " + handle + ", " + Utils.locationToString(latitude, longitude));
        } else {
            connectionProblem = true;

            showStaleData(latitude, longitude, handle, true, callback);

            Utils.log("No connection for request: handle: " + handle + ", " + Utils.locationToString(latitude, longitude));

            concurrentRequestCount--;
        }

        return true;
    }

    function onReceiveData(responseCode as Number, data as Dictionary?, context as Dictionary<String, String or Method or Number or Float or Boolean>) as Void {
        var callback = context["callback"] as Method(weatherData as Array<Dictionary>?, handle as Number, requestIsCompleted as Boolean, dataIsStale as Boolean) as Void;
        var handle = context["handle"] as Number;

        var done = false;
        if (responseCode >= 200 && responseCode < 300 && data != null) {
            try {
                var coordinates = (data["geometry"] as Dictionary<String, String or Array>)["coordinates"] as Array<Float>;
                var timeseries = (data["properties"] as Dictionary<String, Dictionary or Array>)["timeseries"] as Array<Dictionary>;

                YrDataCache.setCachedData(coordinates[1], coordinates[0], data as Dictionary<String, PropertyValueType>);

                connectionProblem = false;

                Utils.log("Received data for handle: " + handle + ", " + Utils.locationToString(coordinates[1], coordinates[0]));

                callback.invoke(timeseries, handle, true, false);

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

            if (!(context["existingConnectionProblem"] as Boolean)) {
                showStaleData(context["latitude"] as Float, context["longitude"] as Float, handle, true, callback);
            }
        }

        requestIsRunning[handle] = false;
        concurrentRequestCount--;
    }

    private function showStaleData(latitude as Float, longitude as Float, handle as Number, requestIsCompleted as Boolean, callback as Method(weatherData as Array<Dictionary>?, handle as Number, requestIsCompleted as Boolean, dataIsStale as Boolean) as Void) as Void {
        var cache = YrDataCache.tryGetCachedData(latitude, longitude, true);
        callback.invoke(cache, handle, requestIsCompleted, true);
    }

    function getStatus() as Void {
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
        };

        Communications.makeWebRequest(baseUrl + STATUS_PATH, null, options, method(:onReceiveStatus));
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