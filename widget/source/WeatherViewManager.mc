import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class WeatherViewManager {
    private var reader as YrDataReader;
    private var behaviourDelegate as WatchUi.BehaviorDelegate;
    private var currentView as WatchUi.View;

    private var locations as Array<Dictionary> = [] as Array<Dictionary>;
    private var currentLocationIndex as Number = 0;

    private var currentPageTitle as String = WatchUi.loadResource(Rez.Strings.NoLocations) as String;
    private var started as Boolean = false;

    function initialize(locations as Array<Dictionary>) {
        if (locations != null) {
            self.locations = locations;
        }

        reader = new YrDataReader();
        behaviourDelegate = new WeatherBehaviorDelegate(method(:displayWeatherForCurrentLocation), method(:nextLocation));
        currentView = new BaseWeatherView(currentPageTitle, false);

        // Wake up the proxy
        reader.getStatus();

        displayWeatherForCurrentLocation();

        started = true;
    }

    function getInitialView() as Array<Views or InputDelegates>? {
        return [ currentView, behaviourDelegate ] as Array<Views or InputDelegates>;
    }

    private function switchView () as Void {
        WatchUi.switchToView(currentView, behaviourDelegate, WatchUi.SLIDE_IMMEDIATE);
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
                currentPageTitle = Conversions.locationToString(latitude, longitude);
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
}