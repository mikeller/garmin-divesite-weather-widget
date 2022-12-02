import Toybox.WatchUi;

class WeatherBehaviorDelegate extends WatchUi.BehaviorDelegate {
    protected var displayWeatherForCurrentLocation as Method() as Void;
    protected var nextLocation as Method() as Void;

    function initialize(displayWeatherForCurrentLocation as Method() as Void, nextLocation as Method() as Void) {
        BehaviorDelegate.initialize();

        self.displayWeatherForCurrentLocation = displayWeatherForCurrentLocation;
        self.nextLocation = nextLocation;
    }

    function onSelect() {
        nextLocation.invoke();

        displayWeatherForCurrentLocation.invoke();

        return false;
    }
}