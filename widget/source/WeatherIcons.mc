import Toybox.Lang;
import Toybox.WatchUi;

class WeatherIcons extends CoreWeatherIcons {
    function initialize() {
        CoreWeatherIcons.initialize();
    }
    
    // This whole thing is pretty useless, but forced upon us by the poor way that Garmin handles resource access
    static function loadIcon(name as String) as BitmapResource? {
        var weatherIcon = CoreWeatherIcons.loadIcon(name);

        if (weatherIcon != null) {
            return weatherIcon;
        }

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





        case "clearsky_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.clearsky_night);

            break;
        case "clearsky_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.clearsky_polartwilight);

            break;
        case "fair_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.fair_night);

            break;
        case "fair_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.fair_polartwilight);

            break;
        case "heavyrainshowersandthunder_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavyrainshowersandthunder_night);

            break;
        case "heavyrainshowersandthunder_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavyrainshowersandthunder_polartwilight);

            break;
        case "heavyrainshowers_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavyrainshowers_night);

            break;
        case "heavyrainshowers_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavyrainshowers_polartwilight);

            break;
        case "heavysleetandthunder":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavysleetandthunder);

            break;
        case "heavysleet":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavysleet);

            break;
        case "heavysleetshowersandthunder_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavysleetshowersandthunder_day);

            break;
        case "heavysleetshowersandthunder_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavysleetshowersandthunder_night);

            break;
        case "heavysleetshowersandthunder_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavysleetshowersandthunder_polartwilight);

            break;
        case "heavysleetshowers_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavysleetshowers_day);

            break;
        case "heavysleetshowers_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavysleetshowers_night);

            break;
        case "heavysleetshowers_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavysleetshowers_polartwilight);

            break;
        case "heavysnowandthunder":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavysnowandthunder);

            break;
        case "heavysnow":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavysnow);

            break;
        case "heavysnowshowersandthunder_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavysnowshowersandthunder_day);

            break;
        case "heavysnowshowersandthunder_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavysnowshowersandthunder_night);

            break;
        case "heavysnowshowersandthunder_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavysnowshowersandthunder_polartwilight);

            break;
        case "heavysnowshowers_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavysnowshowers_day);

            break;
        case "heavysnowshowers_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavysnowshowers_night);

            break;
        case "heavysnowshowers_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavysnowshowers_polartwilight);

            break;
        case "lightrainshowersandthunder_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightrainshowersandthunder_night);

            break;
        case "lightrainshowersandthunder_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightrainshowersandthunder_polartwilight);

            break;
        case "lightrainshowers_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightrainshowers_night);

            break;
        case "lightrainshowers_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightrainshowers_polartwilight);

            break;
        case "lightsleetandthunder":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightsleetandthunder);

            break;
        case "lightsleet":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightsleet);

            break;
        case "lightsleetshowers_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightsleetshowers_day);

            break;
        case "lightsleetshowers_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightsleetshowers_night);

            break;
        case "lightsleetshowers_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightsleetshowers_polartwilight);

            break;
        case "lightsnowandthunder":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightsnowandthunder);

            break;
        case "lightsnow":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightsnow);

            break;
        case "lightsnowshowers_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightsnowshowers_day);

            break;
        case "lightsnowshowers_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightsnowshowers_night);

            break;
        case "lightsnowshowers_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightsnowshowers_polartwilight);

            break;
        case "lightssleetshowersandthunder_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightssleetshowersandthunder_day);

            break;
        case "lightssleetshowersandthunder_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightssleetshowersandthunder_night);

            break;
        case "lightssleetshowersandthunder_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightssleetshowersandthunder_polartwilight);

            break;
        case "lightssnowshowersandthunder_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightssnowshowersandthunder_day);

            break;
        case "lightssnowshowersandthunder_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightssnowshowersandthunder_night);

            break;
        case "lightssnowshowersandthunder_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightssnowshowersandthunder_polartwilight);

            break;
        case "partlycloudy_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.partlycloudy_night);

            break;
        case "partlycloudy_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.partlycloudy_polartwilight);

            break;
        case "rainshowersandthunder_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.rainshowersandthunder_night);

            break;
        case "rainshowersandthunder_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.rainshowersandthunder_polartwilight);

            break;
        case "rainshowers_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.rainshowers_night);

            break;
        case "rainshowers_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.rainshowers_polartwilight);

            break;
        case "sleetandthunder":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.sleetandthunder);

            break;
        case "sleet":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.sleet);

            break;
        case "sleetshowersandthunder_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.sleetshowersandthunder_day);

            break;
        case "sleetshowersandthunder_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.sleetshowersandthunder_night);

            break;
        case "sleetshowersandthunder_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.sleetshowersandthunder_polartwilight);

            break;
        case "sleetshowers_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.sleetshowers_day);

            break;
        case "sleetshowers_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.sleetshowers_night);

            break;
        case "sleetshowers_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.sleetshowers_polartwilight);

            break;
        case "snowandthunder":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.snowandthunder);

            break;
        case "snow":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.snow);

            break;
        case "snowshowersandthunder_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.snowshowersandthunder_day);

            break;
        case "snowshowersandthunder_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.snowshowersandthunder_night);

            break;
        case "snowshowersandthunder_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.snowshowersandthunder_polartwilight);

            break;
        case "snowshowers_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.snowshowers_day);

            break;
        case "snowshowers_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.snowshowers_night);

            break;
        case "snowshowers_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.snowshowers_polartwilight);

            break;
        }

        return weatherIcon;
    }
}
