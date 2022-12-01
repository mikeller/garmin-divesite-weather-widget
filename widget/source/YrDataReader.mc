import Toybox.System;
import Toybox.Communications;
import Toybox.Lang;

class YrDataReader {
    protected var url as String = "https://garmin-divesite-weather-widget-service.azurewebsites.net/data";

    // YR weather data URL (too verbose for the device):
    //var url = "https://api.met.no/weatherapi/locationforecast/2.0/compact.json";
    // YR status URL:
    //var url = "https://api.met.no/weatherapi/locationforecast/2.0/status.json";

    function initialize(customUrl as String?) {
        if (customUrl != null) {
            url = customUrl as String;
        }
    }

    function onReceive(responseCode as Number, data as Dictionary?, context as Dictionary<String, String or Method>) as Void {
        System.println("Response: " + responseCode);

        if (responseCode >= 200 && responseCode < 300 && data != null) {
            System.println("length: " + data.toString().length());

            var properties = data["properties"] as Dictionary<String, Dictionary>;
            System.println("Expires: " +  (properties["meta"] as Dictionary<String, Dictionary>)["expires"]);

            var timeseries = properties["timeseries"] as Array<Dictionary>;

            (context["callback"] as Method).invoke(timeseries);
        } else {
            //TODO: Show error page
        }
    }

    function readWeatherData(location as Dictionary<String, Float or String>, callback as Method(weatherData as Array) as Void) as String {
        var latitudeString = (location["latitude"] as Float).format("%.3f");
        var longitudeString = (location["longitude"] as Float).format("%.3f");
        var defaultDisplayName = latitudeString + " " + longitudeString;

        var params = {
            "lat" => latitudeString,
            "lon" => longitudeString,
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :context => {
                "callback" => callback,
            },
        };

        Communications.makeWebRequest(url, params, options, method(:onReceive));

        return defaultDisplayName;
    }
}