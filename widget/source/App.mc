import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class App extends Application.AppBase {
    protected var reader as YrDataReader;
    protected var behaviourDelegate as WatchUi.BehaviorDelegate;
    protected var currentView as WatchUi.View;

    protected var locations as Array<Dictionary> = [] as Array<Dictionary>;
    protected var currentLocationIndex as Number = 0;

    protected var currentPageTitle as String = WatchUi.loadResource(Rez.Strings.NoLocations) as String;
    protected var started as Boolean = false;

    function initialize() {
        AppBase.initialize();

        var locations = Properties.getValue("locations") as Array<Dictionary>;
        if (locations != null) {
            self.locations = locations;
        }

        var customUrl = Properties.getValue("customUrl");
        if ("".equals(customUrl)) {
            customUrl = null;
        }
        reader = new YrDataReader(customUrl);
        behaviourDelegate = new WeatherBehaviorDelegate(method(:displayWeatherForCurrentLocation), method(:nextLocation));
        currentView = new BaseWeatherView(currentPageTitle, false);

        // Wake up the proxy
        reader.getStatus();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        System.println("App started at " + IsoDateHandler.printIsoDate(Time.now()));

        displayWeatherForCurrentLocation();

        started = true;
    }

    function nextLocation() as Void {
        currentLocationIndex++;
        if (currentLocationIndex >= locations.size()) {
            currentLocationIndex = 0;
        }
    }

    function displayWeatherForCurrentLocation() as Void {
        if (locations.size() > 0) {
            var location = locations[currentLocationIndex] as Dictionary<String, Float or String>;
            var latitude = location["latitude"] as Float;
            var longitude = location["longitude"] as Float;

            var displayName = location["displayName"] as String;
            if ("".equals(displayName)) {
                currentPageTitle = reader.locationToString(latitude, longitude);
            } else {
                currentPageTitle = displayName;
            }

            currentView = new BaseWeatherView(currentPageTitle, false);

            if (started) {
                switchView();
            }

            reader.getWeatherData(latitude, longitude, method(:onWeatherDataReady));
        }
    }

    function onWeatherDataReady(weatherSeries as Array<Dictionary>, success as Boolean) as Void {
        currentView = new WeatherView(weatherSeries, currentPageTitle, !success);

        switchView();
    }

    function switchView () as Void {
        WatchUi.switchToView(currentView, behaviourDelegate, WatchUi.SLIDE_IMMEDIATE);
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ currentView, behaviourDelegate ] as Array<Views or InputDelegates>;
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }
}

function getApp() as App {
    return Application.getApp() as App;
}