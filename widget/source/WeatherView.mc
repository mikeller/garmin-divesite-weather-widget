import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class WeatherView extends BaseWeatherView {
    protected const COLOUR_WIND as Number = 0x00ffff;
    protected const COLOUR_TEMPERATURE as Number = 0xff5555;
    protected const COLOUR_WEATHER as Number = Graphics.COLOR_YELLOW;

    protected const WEATHER_SYMBOL_UNKNOWN_STRING as String = "  ?";
    protected const METRES_PER_SECOND_STRING as String = "m/s";
    protected const DEGREES_C_STRING as String = "°C";

    protected const TODAY_STRING as String = WatchUi.loadResource(Rez.Strings.TodayName) as String;

    protected var dateFont as Graphics.FontDefinition = Graphics.FONT_SYSTEM_TINY;

    protected var weatherSeries as Array<Dictionary> = [{}] as Array<Dictionary>;
    protected var displayName as String = "";

    function initialize(weatherSeries as Array<Dictionary>, displayName as String, connectionProblem as Boolean) {
        BaseWeatherView.initialize(displayName, connectionProblem);

        self.weatherSeries = weatherSeries;
        self.displayName = displayName;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        BaseWeatherView.onLayout(dc);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        BaseWeatherView.onShow();
    }

    protected function drawDayForecast(dc as Graphics.Dc, columnsX as Array<Number>, cursorY as Number, day as Moment or String, weatherInfo as Dictionary<String, String or Dictionary>) as Void {
        var nameString;
        if (day instanceof String) {
            nameString = day;
        } else {
            var dayInfo = Gregorian.info(day, Time.FORMAT_LONG);
            nameString = dayInfo.day_of_week + ", " + dayInfo.day;
        }

        try {
            var data = weatherInfo["data"] as Dictionary<String, Float or String>;

            dc.setColor(COLOUR_FOREGROUND, COLOUR_BACKGROUND);
            dc.drawText(columnsX[0], cursorY, dateFont, nameString, Graphics.TEXT_JUSTIFY_LEFT);

            var windSpeedMs = data["max_wind_speed"];
            if (windSpeedMs != null) {
                dc.setColor(COLOUR_WIND, COLOUR_BACKGROUND);
                dc.drawText(columnsX[1], cursorY, Graphics.FONT_SYSTEM_TINY, "" + Math.round(windSpeedMs as Float).format("%.0f"), Graphics.TEXT_JUSTIFY_RIGHT);
            }

            var airTemperatureC = data["max_air_temperature"];
            if (airTemperatureC != null) {
                dc.setColor(COLOUR_TEMPERATURE, COLOUR_BACKGROUND);
                dc.drawText(columnsX[2], cursorY, Graphics.FONT_SYSTEM_TINY, "" + Math.round(airTemperatureC as Float).format("%.0f"), Graphics.TEXT_JUSTIFY_RIGHT);
            }

            var morningWeatherSymbol = data["morning_symbol_code"];
            if (morningWeatherSymbol != null) {
                var morningWeatherIcon = loadWeatherIcon(morningWeatherSymbol as String);
                if (morningWeatherIcon != null) {
                    dc.drawBitmap(columnsX[3], cursorY, morningWeatherIcon);
                } else {
                    dc.setColor(COLOUR_WEATHER, COLOUR_BACKGROUND);
                    dc.drawText(columnsX[3], cursorY, Graphics.FONT_SYSTEM_TINY, WEATHER_SYMBOL_UNKNOWN_STRING, Graphics.TEXT_JUSTIFY_LEFT);
                }
            }

            var afternoonWeatherSymbol = data["afternoon_symbol_code"];
            if (afternoonWeatherSymbol != null) {
                var afternoonWeatherIcon = loadWeatherIcon(afternoonWeatherSymbol as String);
                if (afternoonWeatherIcon != null) {
                    dc.drawBitmap(columnsX[4], cursorY, afternoonWeatherIcon);
                } else {
                    dc.setColor(COLOUR_WEATHER, COLOUR_BACKGROUND);
                    dc.drawText(columnsX[4], cursorY, Graphics.FONT_SYSTEM_TINY, WEATHER_SYMBOL_UNKNOWN_STRING, Graphics.TEXT_JUSTIFY_LEFT);
                }
            }

        } catch (exception instanceof UnexpectedTypeException) {
            // our input data is bad and cannot be displayed
        }
    }

    function onUpdate(dc as Dc) as Void {
        BaseWeatherView.onUpdate(dc);

        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();

        var lineHeight = dc.getFontHeight(Graphics.FONT_SYSTEM_TINY);
        if (dc.getFontHeight(Graphics.FONT_SYSTEM_XTINY) == lineHeight) {
            dateFont = Graphics.FONT_SYSTEM_XTINY;
        }

        var nameColumnX = calculateViewPortBoundaryX(cursorY, lineHeight, screenWidth, screenHeight, false);
        var nameColumnXBottom = calculateViewPortBoundaryX(cursorY + 4 * (lineHeight + VERTICAL_SPACE), lineHeight, screenWidth, screenHeight, false);
        if (nameColumnXBottom > nameColumnX) {
            nameColumnX = nameColumnXBottom;
        }

        var windColumnX = nameColumnX + dc.getTextWidthInPixels("Mon, 22", dateFont) + HORIZONTAL_SPACE + dc.getTextWidthInPixels("10", Graphics.FONT_SYSTEM_TINY);
        var temperatureColumnX = windColumnX + HORIZONTAL_SPACE + dc.getTextWidthInPixels("-10", Graphics.FONT_SYSTEM_TINY);
        var morningWeatherColumnX = temperatureColumnX + 2 * HORIZONTAL_SPACE;
        // Symbols are square, so their width is equal to lineHeight
        var afternoonWeatherColumnX = morningWeatherColumnX + HORIZONTAL_SPACE + lineHeight;

        var columnsX = [
            nameColumnX,
            windColumnX,
            temperatureColumnX,
            morningWeatherColumnX,
            afternoonWeatherColumnX,
        ] as Array<Number>;

        var index = 0;
        var count = 0;
        while (count < 5 && index < weatherSeries.size()) {
            var weatherInfo = weatherSeries[index];

            var day = Gregorian.moment({
                :year => ((weatherInfo["time"] as String).substring( 0, 4) as String).toNumber(),
                :month => ((weatherInfo["time"] as String).substring( 5, 7) as String).toNumber(),
                :day => ((weatherInfo["time"] as String).substring( 8, 10) as String).toNumber(),
            });

            var todayInfo= Gregorian.info(Time.now(), Time.FORMAT_LONG);
            var today = Gregorian.moment({
                :year => todayInfo.year as Number,
                :month => todayInfo.month as Number,
                :day => todayInfo.day as Number,
            });

            if (day.compare(today) >= 0) {
                if (day.compare(today) == 0) {
                    day = TODAY_STRING;
                }
                drawDayForecast(dc, columnsX, cursorY, day, weatherInfo as Dictionary<String, String or Dictionary>);
                cursorY += lineHeight + VERTICAL_SPACE;

                count++;
            }

            index++;
        }

        dc.setColor(COLOUR_WIND, COLOUR_BACKGROUND);
        dc.drawText(columnsX[1], cursorY, Graphics.FONT_SYSTEM_TINY, METRES_PER_SECOND_STRING, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(COLOUR_TEMPERATURE, COLOUR_BACKGROUND);
        dc.drawText(columnsX[2], cursorY, Graphics.FONT_SYSTEM_TINY, DEGREES_C_STRING, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // This whole thing is pretty useless, but forced upon us by the poor way that Garmin handles resource access
    protected function loadWeatherIcon(name as String) as BitmapResource? {
        var weatherIcon;
        switch (name) {
        case "clearsky_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.clearsky_day);

            break;
        case "clearsky_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.clearsky_night);

            break;
        case "clearsky_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.clearsky_polartwilight);

            break;
        case "cloudy":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.cloudy);

            break;
        case "fair_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.fair_day);

            break;
        case "fair_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.fair_night);

            break;
        case "fair_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.fair_polartwilight);

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
        case "heavyrainshowersandthunder_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavyrainshowersandthunder_night);

            break;
        case "heavyrainshowersandthunder_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavyrainshowersandthunder_polartwilight);

            break;
        case "heavyrainshowers_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.heavyrainshowers_day);

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
        case "lightrainandthunder":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightrainandthunder);

            break;
        case "lightrain":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightrain);

            break;
        case "lightrainshowersandthunder_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightrainshowersandthunder_day);

            break;
        case "lightrainshowersandthunder_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightrainshowersandthunder_night);

            break;
        case "lightrainshowersandthunder_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightrainshowersandthunder_polartwilight);

            break;
        case "lightrainshowers_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.lightrainshowers_day);

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
        case "partlycloudy_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.partlycloudy_day);

            break;
        case "partlycloudy_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.partlycloudy_night);

            break;
        case "partlycloudy_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.partlycloudy_polartwilight);

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
        case "rainshowersandthunder_night":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.rainshowersandthunder_night);

            break;
        case "rainshowersandthunder_polartwilight":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.rainshowersandthunder_polartwilight);

            break;
        case "rainshowers_day":
            weatherIcon = WatchUi.loadResource(Rez.Drawables.rainshowers_day);

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
