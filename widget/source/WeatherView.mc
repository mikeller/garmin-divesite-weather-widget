import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class WeatherView extends BaseWeatherView {
    private var dateFont as Graphics.FontDefinition = Graphics.FONT_SYSTEM_TINY;

    private var weatherSeries as Array<Dictionary> = [{}] as Array<Dictionary>;
        
    function initialize(weatherSeries as Array<Dictionary>, displayName as String, dataIsStale as Boolean) {
        BaseWeatherView.initialize(displayName, dataIsStale);

        self.weatherSeries = weatherSeries;
    }

    protected function drawDayForecast(dc as Graphics.Dc, columnsX as Array<Number>, cursorY as Number, day as Moment or String, weatherInfo as Dictionary<String, String or Dictionary>, isFirstLine as Boolean) as Void {
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
                dc.drawText(columnsX[1], cursorY, Graphics.FONT_SYSTEM_TINY, Math.round(windSpeedMs as Float).format("%.0f"), Graphics.TEXT_JUSTIFY_RIGHT);
            }

            var windFromDirectionDegrees = data["max_wind_from_direction"];
            if (windFromDirectionDegrees != null) {
                var directionArrow = IconManager.loadArrowIcon(windFromDirectionDegrees as Float);
                if (directionArrow != null) {
                    dc.drawBitmap(columnsX[2], cursorY, directionArrow);
                }
            }

            var airTemperatureC = data["max_air_temperature"] as Float?;
            var morningWeatherSymbol = data["morning_symbol_code"] as String?;
            var afternoonWeatherSymbol = data["afternoon_symbol_code"] as String?;
            drawTemperatureSymbols(dc, airTemperatureC, morningWeatherSymbol, afternoonWeatherSymbol, columnsX[3], columnsX[4], columnsX[5], cursorY, isFirstLine);
        } catch (exception instanceof UnexpectedTypeException) {
            Utils.log("Data format problem: " + exception.getErrorMessage());
            exception.printStackTrace();
        }
    }

    private function drawTemperatureInternal(dc as Dc, airTemperatureC as Float?, cursorX as Number, cursorY as Number, justification as TextJustification) as Void {
        if (airTemperatureC != null) {
            dc.setColor(Constants.COLOUR_TEMPERATURE, Constants.COLOUR_BACKGROUND);
            dc.drawText(cursorX, cursorY, Graphics.FONT_SYSTEM_TINY, Math.round(airTemperatureC).format("%.0f"), justification);
        }
    }

    private function drawSymbolsInternal(dc as Dc, morningWeatherSymbol as String?, afternoonWeatherSymbol as String?, morningX as Number, afternoonX as Number, cursorY as Number) as Void {
        if (morningWeatherSymbol != null) {
            var morningWeatherIcon = IconManager.loadWeatherIcon(morningWeatherSymbol as String);
            if (morningWeatherIcon != null) {
                dc.drawBitmap(morningX, cursorY, morningWeatherIcon);
            } else {
                dc.setColor(Constants.COLOUR_WEATHER, Constants.COLOUR_BACKGROUND);
                dc.drawText(morningX, cursorY, Graphics.FONT_SYSTEM_TINY, Constants.WEATHER_SYMBOL_UNKNOWN_STRING, Graphics.TEXT_JUSTIFY_LEFT);
            }
        }

        if (afternoonWeatherSymbol != null) {
            var afternoonWeatherIcon = IconManager.loadWeatherIcon(afternoonWeatherSymbol as String);
            if (afternoonWeatherIcon != null) {
                dc.drawBitmap(afternoonX, cursorY, afternoonWeatherIcon);
            } else {
                dc.setColor(Constants.COLOUR_WEATHER, Constants.COLOUR_BACKGROUND);
                dc.drawText(afternoonX, cursorY, Graphics.FONT_SYSTEM_TINY, Constants.WEATHER_SYMBOL_UNKNOWN_STRING, Graphics.TEXT_JUSTIFY_LEFT);
            }
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
        // We accept that the day name of the last day may be truncated
        var nameColumnXBottom = calculateViewPortBoundaryX(cursorY + (Constants.DAYS_TO_SHOW - 2) * (lineHeight + Constants.VERTICAL_SPACE), lineHeight, screenWidth, screenHeight, false);
        if (nameColumnXBottom > nameColumnX) {
            nameColumnX = nameColumnXBottom;
        }

        var windSpeedColumnX = nameColumnX + dc.getTextWidthInPixels("Mon, 22", dateFont) + Constants.HORIZONTAL_SPACE + dc.getTextWidthInPixels("10", Graphics.FONT_SYSTEM_TINY);
        var windDirectionColumnX = windSpeedColumnX;
        var temperatureColumnX = windDirectionColumnX + Constants.WIND_DIRECTION_ARROW_WIDTH + Constants.HORIZONTAL_SPACE + dc.getTextWidthInPixels("-10", Graphics.FONT_SYSTEM_TINY);
        var morningWeatherColumnX = temperatureColumnX + 2 * Constants.HORIZONTAL_SPACE_SYMBOLS;
        // Symbols are square, so their width is equal to lineHeight
        var afternoonWeatherColumnX = morningWeatherColumnX + Constants.HORIZONTAL_SPACE_SYMBOLS + lineHeight;

        var columnsX = [
            nameColumnX,
            windDirectionColumnX,
            windSpeedColumnX,
            temperatureColumnX,
            morningWeatherColumnX,
            afternoonWeatherColumnX,
        ] as Array<Number>;

        var index = 0;
        var count = 0;
        while (count < Constants.DAYS_TO_SHOW && index < weatherSeries.size()) {
            var weatherInfo = weatherSeries[index];

            var day = Gregorian.moment({
                :year => ((weatherInfo["time"] as String).substring( 0, 4) as String).toNumber() as Number,
                :month => ((weatherInfo["time"] as String).substring( 5, 7) as String).toNumber() as Number,
                :day => ((weatherInfo["time"] as String).substring( 8, 10) as String).toNumber() as Number,
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
                drawDayForecast(dc, columnsX, cursorY, day, weatherInfo as Dictionary<String, String or Dictionary>, count == 0);
                cursorY += lineHeight + Constants.VERTICAL_SPACE;

                count++;
            }

            index++;
        }

        if (count > 0) {
            dc.setColor(Constants.COLOUR_WIND, Constants.COLOUR_BACKGROUND);
            dc.drawText(columnsX[2] + Constants.WIND_DIRECTION_ARROW_WIDTH, cursorY, Graphics.FONT_SYSTEM_TINY, Constants.METRES_PER_SECOND_STRING, Graphics.TEXT_JUSTIFY_RIGHT);
            dc.setColor(Constants.COLOUR_TEMPERATURE, Constants.COLOUR_BACKGROUND);
            dc.drawText(columnsX[3], cursorY, Graphics.FONT_SYSTEM_TINY, Constants.DEGREES_C_STRING, Graphics.TEXT_JUSTIFY_RIGHT);
        }
    }

   (:roundScreen)
    private function calculateViewPortBoundaryX(y as Number, fontHeight as Number, screenWidth as Number, screenHeight as Number, rightSide as Boolean) as Number {
        var circleOriginX = screenWidth / 2;
        var circleOriginY = screenHeight / 2;

        if (y > circleOriginY) {
            y += fontHeight;
        }
        var normalisedY = 1.0f * (circleOriginY - y) / circleOriginY;     
        var angle = Math.asin(normalisedY);
        if (rightSide) {
            angle += Math.PI;
        }
        var normalisedX = Math.cos(angle);
        return Math.round(circleOriginX - (normalisedX * circleOriginX)).toNumber();
    }

    (:semioctagonalScreen)
    private function calculateViewPortBoundaryX(y as Number, fontHeight as Number, screenWidth as Number, screenHeight as Number, rightSide as Boolean) as Number {        
        if (y > screenHeight / 2) {
            y += fontHeight;
        }

        var x;
        if (y < Constants.SEMIOCTAGONAL_CORNER_HEIGHT) {
            x = Constants.SEMIOCTAGONAL_CORNER_HEIGHT - y;
        } else if (y < screenHeight - Constants.SEMIOCTAGONAL_CORNER_HEIGHT) {
            x = 0;
        } else {
            x = y - (screenHeight - Constants.SEMIOCTAGONAL_CORNER_HEIGHT);
        }

        if (rightSide) {
            x = screenWidth - x;
        }

        return x;
    }

    (:roundScreen)
    private function drawTemperatureSymbols(dc as Dc, airTemperatureC as Float?, morningWeatherSymbol as String?, afternoonWeatherSymbol as String?, temperatureX as Number, morningX as Number, afternoonX as Number, cursorY as Number, isFirstLine as Boolean) as Void {
        drawTemperatureInternal(dc, airTemperatureC, temperatureX, cursorY, Graphics.TEXT_JUSTIFY_RIGHT);
        drawSymbolsInternal(dc, morningWeatherSymbol, afternoonWeatherSymbol, morningX, afternoonX, cursorY);
    }

    (:semioctagonalScreen)
    private function drawTemperatureSymbols(dc as Dc, airTemperatureC as Float?, morningWeatherSymbol as String?, afternoonWeatherSymbol as String?, temperatureX as Number, morningX as Number, afternoonX as Number, cursorY as Number, isFirstLine as Boolean) as Void {
        if (isFirstLine) {
            var lineHeight = dc.getFontHeight(Graphics.FONT_SYSTEM_TINY);
            var subWindowTemperatureX = Constants.SUB_WINDOW_X + Constants.SUB_WINDOW_SIZE / 2;
            var subWindowTemperatureY = Constants.SUB_WINDOW_Y + Constants.SUB_WINDOW_SIZE - Constants.VERTICAL_SPACE - lineHeight;
            drawTemperatureInternal(dc, airTemperatureC, subWindowTemperatureX, subWindowTemperatureY, Graphics.TEXT_JUSTIFY_CENTER);

            var subWindowMorningX = Constants.SUB_WINDOW_X + Constants.HORIZONTAL_SPACE_SYMBOLS;
            var subWindowAfternoonX = subWindowMorningX + afternoonX - morningX;
            var subWindowSymbolY = subWindowTemperatureY - Constants.VERTICAL_SPACE - lineHeight;
            drawSymbolsInternal(dc, morningWeatherSymbol, afternoonWeatherSymbol, subWindowMorningX, subWindowAfternoonX, subWindowSymbolY);
        } else {
            drawTemperatureInternal(dc, airTemperatureC, temperatureX, cursorY, Graphics.TEXT_JUSTIFY_RIGHT);
            drawSymbolsInternal(dc, morningWeatherSymbol, afternoonWeatherSymbol, morningX, afternoonX, cursorY);
        }
    }
}