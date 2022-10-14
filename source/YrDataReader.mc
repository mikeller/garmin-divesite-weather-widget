import Toybox.System;
import Toybox.Communications;
import Toybox.Lang;

class YrDataReader {
    function onReceive(responseCode as Number, data as Dictionary?, context as Method) as Void {
        System.println("Response: " + responseCode);
        System.println("Data: " + data);
        System.println("length: " + data.toString().length());

        if (responseCode >= 200 && responseCode < 300 && data != null) {
            var properties = data["properties"];
            System.println("Last Updated: " + properties["meta"]["updated_at"]);

            var timeSeries = properties["timeseries"];
            var currentWindMS = timeSeries[0]["data"]["instant"]["details"]["wind_speed"];
            var currentTemperatureC = timeSeries[0]["data"]["instant"]["details"]["air_temperature"];

            var weatherContext = [
                currentWindMS,
                currentTemperatureC,
            ];

            context.invoke(weatherContext);
        } else {
            //TODO: Show error page
        }
    }

    function readWeatherData(callback as Method(weatherData as Array) as Void) as Void {
        var url = "https://api.met.no/weatherapi/locationforecast/2.0/compact.json";
        // Status JSON URL:
        //var url = "https://api.met.no/weatherapi/locationforecast/2.0/status.json";
        
        var lat = -43.342;
        var lon = 171.546;

        var params = {
            "lat" => lat.format("%.3f"),
            "lon" => lon.format("%.3f"),
        };

        var userAgent = WatchUi.loadResource(Rez.Strings.AppName) + "/0.1 " + "https://github.com/mikeller/garmin-divesite-weather-widget";

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => {
                "User-Agent" => userAgent,
            },
            :context => (callback as Object),
        };

        Communications.makeWebRequest(url, params, options, method(:onReceive));
    }
}