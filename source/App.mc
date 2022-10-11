import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class App extends Application.AppBase {

    var reader as YrDataReader;

    function initialize() {
        AppBase.initialize();

        reader = new YrDataReader();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        reader.readWeatherData(method(:onWeatherDataReady));
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new BaseWeatherView() ] as Array<Views or InputDelegates>;
    }

    function onWeatherDataReady(weatherData as Array) as Void {
        WatchUi.switchToView(new WeatherView(weatherData), new WeatherBehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }
}

function getApp() as App {
    return Application.getApp() as App;
}