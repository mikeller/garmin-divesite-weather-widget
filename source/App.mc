import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class App extends Application.AppBase {

    var reader as YrDataReader;

    function initialize() {
        AppBase.initialize();

        reader = new YrDataReader();
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

        reader.readWeatherData(method(:onWeatherDataReady));
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new BaseWeatherView() ] as Array<Views or InputDelegates>;
    }

    function onWeatherDataReady(weatherData as Array<Float>) as Void {
        WatchUi.switchToView(new WeatherView(weatherData), new WeatherBehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }
}

function getApp() as App {
    return Application.getApp() as App;
}