import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

(:glance)
class WeatherApp extends Application.AppBase {
    private var viewManager as WeatherViewManager?;
    protected var locations as Array<Dictionary> = [] as Array<Dictionary>;

    function initialize() {
        AppBase.initialize();

        var locations = WeatherAppProperties.getLocationsProperty();
        if (locations != null) {
            self.locations = locations;
        }
    }

    function getGlanceView() as Array<GlanceView>? {
        return [new WeatherGlanceView(locations != 0 ? locations[0] : null)] as Array<GlanceView>;
    }

    (:typecheck(disableGlanceCheck))
    function getInitialView() as Array<Views or InputDelegates>? {
        if (viewManager == null) {
            viewManager = new WeatherViewManager(locations);
        }

        return (viewManager as WeatherViewManager).getInitialView();
    }

    (:typecheck(disableGlanceCheck))
    function onStart(state as Dictionary?) as Void {
        System.println("App started at " + Conversions.dateToIsoString(Time.now()));
    }

    function onStop(state as Dictionary?) as Void {
    }
}

function getApp() as WeatherApp {
    return Application.getApp() as WeatherApp;
}