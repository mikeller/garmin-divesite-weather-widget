import Toybox.System;
import Toybox.WatchUi;
import Toybox.Lang;

class WeatherBehaviorDelegate extends WatchUi.BehaviorDelegate {
    protected var locationIndex as Number;
    protected var displayWeatherForLocation as Method(locationIndex as Number) as Void;

    function initialize(locationIndex as Number, displayWeatherForLocation as Method(locationIndex as Number) as Void) {
        BehaviorDelegate.initialize();

        self.locationIndex = locationIndex;
        self.displayWeatherForLocation = displayWeatherForLocation;
    }

    function onSelect() {
        locationIndex++;

        displayWeatherForLocation.invoke(locationIndex);

        return false;
    }
}