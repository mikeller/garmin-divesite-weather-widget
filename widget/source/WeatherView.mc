import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class WeatherView extends BaseWeatherView {
    private var dateFont as Graphics.FontDefinition = Graphics.FONT_SYSTEM_TINY;

    private var weatherSeries as Array<Dictionary> = [{}] as Array<Dictionary>;
    private var displayName as String = "";

    function initialize(weatherSeries as Array<Dictionary>, displayName as String, connectionProblem as Boolean) {
        BaseWeatherView.initialize(displayName, connectionProblem);

        self.weatherSeries = weatherSeries;
        self.displayName = displayName;
    }

    function onLayout(dc as Dc) as Void {
        BaseWeatherView.onLayout(dc);
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

            dc.setColor(Constants.COLOUR_FOREGROUND, Constants.COLOUR_BACKGROUND);
            dc.drawText(columnsX[0], cursorY, dateFont, nameString, Graphics.TEXT_JUSTIFY_LEFT);

            var windSpeedMs = data["max_wind_speed"];
            if (windSpeedMs != null) {
                dc.setColor(Constants.COLOUR_WIND, Constants.COLOUR_BACKGROUND);
                dc.drawText(columnsX[1], cursorY, Graphics.FONT_SYSTEM_TINY, "" + Math.round(windSpeedMs as Float).format("%.0f"), Graphics.TEXT_JUSTIFY_RIGHT);
            }

            var airTemperatureC = data["max_air_temperature"];
            if (airTemperatureC != null) {
                dc.setColor(Constants.COLOUR_TEMPERATURE, Constants.COLOUR_BACKGROUND);
                dc.drawText(columnsX[2], cursorY, Graphics.FONT_SYSTEM_TINY, "" + Math.round(airTemperatureC as Float).format("%.0f"), Graphics.TEXT_JUSTIFY_RIGHT);
            }

            var morningWeatherSymbol = data["morning_symbol_code"];
            if (morningWeatherSymbol != null) {
                var morningWeatherIcon = WeatherIcons.loadIcon(morningWeatherSymbol as String);
                if (morningWeatherIcon != null) {
                    dc.drawBitmap(columnsX[3], cursorY, morningWeatherIcon);
                } else {
                    dc.setColor(Constants.COLOUR_WEATHER, Constants.COLOUR_BACKGROUND);
                    dc.drawText(columnsX[3], cursorY, Graphics.FONT_SYSTEM_TINY, Constants.WEATHER_SYMBOL_UNKNOWN_STRING, Graphics.TEXT_JUSTIFY_LEFT);
                }
            }

            var afternoonWeatherSymbol = data["afternoon_symbol_code"];
            if (afternoonWeatherSymbol != null) {
                var afternoonWeatherIcon = WeatherIcons.loadIcon(afternoonWeatherSymbol as String);
                if (afternoonWeatherIcon != null) {
                    dc.drawBitmap(columnsX[4], cursorY, afternoonWeatherIcon);
                } else {
                    dc.setColor(Constants.COLOUR_WEATHER, Constants.COLOUR_BACKGROUND);
                    dc.drawText(columnsX[4], cursorY, Graphics.FONT_SYSTEM_TINY, Constants.WEATHER_SYMBOL_UNKNOWN_STRING, Graphics.TEXT_JUSTIFY_LEFT);
                }
            }

        } catch (exception instanceof UnexpectedTypeException) {
            Utils.log("Data format problem: " + exception.getErrorMessage());
            exception.printStackTrace();
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
        var nameColumnXBottom = calculateViewPortBoundaryX(cursorY + 4 * (lineHeight + Constants.VERTICAL_SPACE), lineHeight, screenWidth, screenHeight, false);
        if (nameColumnXBottom > nameColumnX) {
            nameColumnX = nameColumnXBottom;
        }

        var windColumnX = nameColumnX + dc.getTextWidthInPixels("Mon, 22", dateFont) + Constants.HORIZONTAL_SPACE + dc.getTextWidthInPixels("10", Graphics.FONT_SYSTEM_TINY);
        var temperatureColumnX = windColumnX + Constants.HORIZONTAL_SPACE + dc.getTextWidthInPixels("-10", Graphics.FONT_SYSTEM_TINY);
        var morningWeatherColumnX = temperatureColumnX + 2 * Constants.HORIZONTAL_SPACE;
        // Symbols are square, so their width is equal to lineHeight
        var afternoonWeatherColumnX = morningWeatherColumnX + Constants.HORIZONTAL_SPACE + lineHeight;

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

            var todayInfo = Gregorian.info(Time.now(), Time.FORMAT_LONG);
            var today = Gregorian.moment({
                :year => todayInfo.year as Number,
                :month => todayInfo.month as Number,
                :day => todayInfo.day as Number,
            });

            if (day.compare(today) >= 0) {
                if (day.compare(today) == 0) {
                    day = Constants.TODAY_STRING;
                }
                drawDayForecast(dc, columnsX, cursorY, day, weatherInfo as Dictionary<String, String or Dictionary>);
                cursorY += lineHeight + Constants.VERTICAL_SPACE;

                count++;
            }

            index++;
        }

        dc.setColor(Constants.COLOUR_WIND, Constants.COLOUR_BACKGROUND);
        dc.drawText(columnsX[1], cursorY, Graphics.FONT_SYSTEM_TINY, Constants.METRES_PER_SECOND_STRING, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(Constants.COLOUR_TEMPERATURE, Constants.COLOUR_BACKGROUND);
        dc.drawText(columnsX[2], cursorY, Graphics.FONT_SYSTEM_TINY, Constants.DEGREES_C_STRING, Graphics.TEXT_JUSTIFY_RIGHT);
    }
}
