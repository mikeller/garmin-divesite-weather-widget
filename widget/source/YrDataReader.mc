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
        System.println("Data: " + data);

        if (responseCode >= 200 && responseCode < 300 && data != null) {
            System.println("length: " + data.toString().length());

            var properties = (data["properties"] as Dictionary<String, Dictionary>);
            System.println("Last Updated: " + (properties["meta"] as Dictionary<String, Dictionary>)["updated_at"]);

            var timeSeries = (properties["timeseries"] as Array<Dictionary>);
            var weatherContainer = timeSeries[0];
            var weatherData = (weatherContainer["data"] as Dictionary<String, Dictionary>);
            var weatherInstantDetails = ((weatherData["instant"] as Dictionary<String, Dictionary>)["details"] as Dictionary<String, Number or Float>);
            var currentWindMS = weatherInstantDetails["wind_speed"];
            var currentTemperatureC = weatherInstantDetails["air_temperature"];
            var morningWeatherSymbolName = ((weatherData["next_1_hours"] as Dictionary<String, Dictionary>)["summary"] as Dictionary<String, String>)["symbol_code"];
            var afternoonWeatherSymbolName = ((weatherData["next_6_hours"] as Dictionary<String, Dictionary>)["summary"] as Dictionary<String, String>)["symbol_code"];

            var weatherContext = [
                currentWindMS,
                currentTemperatureC,
                morningWeatherSymbolName,
                afternoonWeatherSymbolName,
            ] as Array<Float or String>;

            (context["callback"] as Method).invoke(weatherContext);
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