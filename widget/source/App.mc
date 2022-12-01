import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class App extends Application.AppBase {
    protected var reader as YrDataReader;

    protected var locations as Array<Dictionary> = [] as Array<Dictionary>;
    protected var currentLocationIndex as Number = 0;
    protected var currentDisplayName as String = "";
    protected var started as Boolean = false;

    function initialize() {
        AppBase.initialize();

        var locations = Properties.getValue("locations") as Array<Dictionary>;
        if (locations != null) {
            self.locations = locations;
        }

        var customUrl = Properties.getValue("customWeatherApiUrl");
        if ("".equals(customUrl)) {
            customUrl = null;
        }
        reader = new YrDataReader(customUrl);
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        var date = Gregorian.info(Time.now(), Time.FORMAT_LONG);
        System.println("App started at " + format("$1$-$2$-$3$T$4$:$5$:$6$",[
            date.year,
            date.month,
            date.day,
            date.hour,
            date.min.format("%02d"),
            date.sec.format("%02d")
        ]));

        displayWeatherForLocation(currentLocationIndex);

        started = true;
    }

    function displayWeatherForLocation(locationIndex as Number) as Void {
        if (locationIndex >= locations.size()) {
            locationIndex = 0;
        }

        currentLocationIndex = locationIndex;

        if (locations.size() > 0) {
            var location = locations[locationIndex] as Dictionary<String, Float or String>;
            currentDisplayName = location["displayName"] as String;

            var defaultDisplayName = reader.readWeatherData(location, method(:onWeatherDataReady));
            if ("".equals(currentDisplayName)) {
                currentDisplayName = defaultDisplayName;
            }

        } else {
            currentDisplayName = "No locations!";
        }

        if (started) {
            WatchUi.switchToView(new BaseWeatherView(currentDisplayName), new WeatherBehaviorDelegate(currentLocationIndex, method(:displayWeatherForLocation)), WatchUi.SLIDE_IMMEDIATE);
        }
    }

    function onWeatherDataReady(weatherSeries as Array<Dictionary>) as Void {
        WatchUi.switchToView(new WeatherView(weatherSeries, currentDisplayName), new WeatherBehaviorDelegate(currentLocationIndex, method(:displayWeatherForLocation)), WatchUi.SLIDE_IMMEDIATE);
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new BaseWeatherView(currentDisplayName), new WeatherBehaviorDelegate(currentLocationIndex, method(:displayWeatherForLocation)) ] as Array<Views or InputDelegates>;
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }
}

function getApp() as App {
    return Application.getApp() as App;
}