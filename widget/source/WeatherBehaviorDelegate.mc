import Toybox.System;
import Toybox.WatchUi;

class WeatherBehaviorDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        System.println("Menu behavior triggered");
        return false;
    }
}