import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;
import Toybox.Timer;

class WeatherViewManager {
    private var reader as YrDataReader;

    private var behaviourDelegate as WatchUi.BehaviorDelegate;

    private var currentView as WatchUi.View;
    private var currentPageTitle as String = WatchUi.loadResource(Rez.Strings.NoLocations) as String;

    private var locations as Array<Dictionary> = [] as Array<Dictionary>;
    private var currentLocationIndex as Number = 0;

    private var started as Boolean = false;

    private var retryTimer as Timer.Timer = new Timer.Timer();
    private var retryIndex as Number = -1;

    private var refreshTimer as Timer.Timer = new Timer.Timer();
    private var delayedRefreshRequested as Boolean = false;

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
        Utils.log("Initial view loaded.");

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
            var location = getLocation(currentLocationIndex);
            var latitude = location["latitude"] as Float;
            var longitude = location["longitude"] as Float;

            var displayName = location["displayName"] as String;
            if ("".equals(displayName)) {
                currentPageTitle = Utils.locationToString(latitude, longitude);
            } else {
                currentPageTitle = displayName;
            }

            Utils.log("Loading view: " + currentPageTitle + " (" + latitude + ", " + longitude + ")");

            currentView = new BaseWeatherView(currentPageTitle, false);

            if (started) {
                switchView();
            }

            refreshWeatherCache(currentLocationIndex);
        }
    }

    private function refreshWeatherCache(startIndex as Number) as Void {
        for (var counter = 0; counter < locations.size(); counter++) {
            var index = (startIndex + counter) % locations.size();
            var location = getLocation(index);
            var latitude = location["latitude"] as Float;
            var longitude = location["longitude"] as Float;

            if (!reader.getWeatherData(latitude, longitude, index, method(:onWeatherDataReady)) && retryIndex == -1) {
                retryIndex = index;
                refreshTimer.start(method(:onRetryRequest), 1000, false);
            }
        }
    }

    function onRetryRequest() as Void {
        var index = retryIndex;
        retryIndex = -1;
        refreshWeatherCache(index);
    }

    private function getLocation(index as Number) as Dictionary<String, Float or String or Boolean> {
        return locations[index] as Dictionary<String, Float or String or Boolean>;
    }

    function onWeatherDataReady(weatherSeries as Array<Dictionary>?, handle as Number, requestIsCompleted as Boolean, dataIsStale as Boolean) as Void {
        if (handle == currentLocationIndex) {
            if (weatherSeries != null) {
                currentView = new WeatherView(weatherSeries, currentPageTitle, dataIsStale);
            } else {
                currentView = new BaseWeatherView(currentPageTitle, dataIsStale);
            }

            switchView();
        }

        if (dataIsStale && requestIsCompleted) {
            requestDelayedRefresh();
        }
    }

    private function requestDelayedRefresh() as Void {
        if (!delayedRefreshRequested) {
            Utils.log("Delayed refresh requested.");

            refreshTimer.start(method(:onDelayedRefresh), Constants.REFRESH_DELAY_S * 1000, false);

            delayedRefreshRequested = true;
        }
    }

    function onDelayedRefresh() as Void {
        Utils.log("Delayed refresh running.");

        delayedRefreshRequested = false;

        refreshWeatherCache(currentLocationIndex);
    }
}