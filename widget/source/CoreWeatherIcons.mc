import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class CoreWeatherIcons {
    // This whole thing is pretty useless, but forced upon us by the poor way that Garmin handles resource access
    static function loadIcon(name as String) as BitmapResource? {
        var weatherIcon;
        switch (name) {
        case "clearsky_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.clearsky_day);

            break;
        case "cloudy":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.cloudy);

            break;
        case "fair_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.fair_day);

            break;
        case "fog":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.fog);

            break;
        case "heavyrainandthunder":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavyrainandthunder);

            break;
        case "heavyrain":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavyrain);

            break;
        case "heavyrainshowersandthunder_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavyrainshowersandthunder_day);

            break;
        case "heavyrainshowers_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavyrainshowers_day);

            break;
        case "lightrainandthunder":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightrainandthunder);

            break;
        case "lightrain":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightrain);

            break;
        case "lightrainshowersandthunder_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightrainshowersandthunder_day);

            break;
        case "lightrainshowers_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightrainshowers_day);

            break;
        case "partlycloudy_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.partlycloudy_day);

            break;
        case "rainandthunder":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.rainandthunder);

            break;
        case "rain":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.rain);

            break;
        case "rainshowersandthunder_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.rainshowersandthunder_day);

            break;
        case "rainshowers_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.rainshowers_day);

            break;
        }

        return weatherIcon;
    }
}
