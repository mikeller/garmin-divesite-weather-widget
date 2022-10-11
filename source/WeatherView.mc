import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class WeatherView extends BaseWeatherView {
    protected const COLOUR_WIND as Number = 0x00ffff;
    protected const COLOUR_TEMPERATURE as Number = 0xff5555;
    protected const COLOUR_WEATHER as Number = Graphics.COLOR_YELLOW;

    protected const WIND_SYMBOL as Char = 0xf050.toChar();
    protected const DEGREES_C_STRING as String = "°C";
    protected const SUN_CLOUD_SYMBOL as Char = 0xf002.toChar();
    protected const SUN_SYMBOL as Char = 0xf00d.toChar();
    protected const RAIN_SYMBOL as Char = 0xf015.toChar();
    protected const CLOUD_SYMBOL as Char = 0xf041.toChar();

    protected const TODAY_STRING as String = WatchUi.loadResource(Rez.Strings.TodayName);
     
    protected const weatherFont as FontResource = WatchUi.loadResource(Rez.Fonts.WeatherFont);

    protected var weatherData as Array;

    function initialize(weatherData as Array) {
        BaseWeatherView.initialize();

        self.weatherData = weatherData;
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

    function drawDayForecast(dc, columnsX, cursorY,  nameString, windMS, temperatureC, morningWeatherSymbol, afternoonWeatherSymbol) {
        dc.setColor(COLOUR_FOREGROUND, COLOUR_BACKGROUND);
        dc.drawText(columnsX[0], cursorY, Graphics.FONT_SYSTEM_XTINY, nameString, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(COLOUR_WIND, COLOUR_BACKGROUND);
        dc.drawText(columnsX[1], cursorY, Graphics.FONT_SYSTEM_TINY, "" + Math.round(windMS).format("%.0f"), Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(COLOUR_TEMPERATURE, COLOUR_BACKGROUND);
        dc.drawText(columnsX[2], cursorY, Graphics.FONT_SYSTEM_TINY, "" + Math.round(temperatureC).format("%.0f"), Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(COLOUR_WEATHER, COLOUR_BACKGROUND);
        dc.drawText(columnsX[3], cursorY, weatherFont, "" + morningWeatherSymbol, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(columnsX[4], cursorY, weatherFont, "" + afternoonWeatherSymbol, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onUpdate(dc as Dc) as Void {
        BaseWeatherView.onUpdate(dc);

        var nameColumnX = calculateViewPortBoundaryX(cursorY, fontXtinyHeight, screenWidth, screenHeight, false);
        var nameColumnXBottom = calculateViewPortBoundaryX(cursorY + 4 * (fontTinyHeight + VERTICAL_SPACE), fontXtinyHeight, screenWidth, screenHeight, false);
        if (nameColumnXBottom > nameColumnX) {
            nameColumnX = nameColumnXBottom;
        }

        var windColumnX = nameColumnX + dc.getTextWidthInPixels("Mon, 22", Graphics.FONT_SYSTEM_XTINY) + HORIZONTAL_SPACE + dc.getTextWidthInPixels("10", Graphics.FONT_SYSTEM_TINY);
        var temperatureColumnX = windColumnX + HORIZONTAL_SPACE + dc.getTextWidthInPixels("-10", Graphics.FONT_SYSTEM_TINY);
        var morningWeatherColumnX = temperatureColumnX + 2 * HORIZONTAL_SPACE + dc.getTextWidthInPixels("" + SUN_CLOUD_SYMBOL, weatherFont) / 2;
        var afternoonWeatherColumnX = morningWeatherColumnX + HORIZONTAL_SPACE + dc.getTextWidthInPixels("" + SUN_CLOUD_SYMBOL, weatherFont);

        var columnsX = [
            nameColumnX,
            windColumnX,
            temperatureColumnX,
            morningWeatherColumnX,
            afternoonWeatherColumnX,
        ];

        drawDayForecast(dc, columnsX, cursorY, TODAY_STRING, weatherData[0], weatherData[1], SUN_CLOUD_SYMBOL, CLOUD_SYMBOL);
        cursorY += fontTinyHeight + VERTICAL_SPACE;

        var dayDuration = new Time.Duration(Gregorian.SECONDS_PER_DAY);
        var day = Time.now().add(dayDuration);
        var dayInfo = Gregorian.info(day, Time.FORMAT_LONG);

        drawDayForecast(dc, columnsX, cursorY, dayInfo.day_of_week + ", " + dayInfo.day, weatherData[0], weatherData[1], SUN_CLOUD_SYMBOL, SUN_SYMBOL);
        cursorY += fontTinyHeight + VERTICAL_SPACE;

        day = day.add(dayDuration);
        dayInfo = Gregorian.info(day, Time.FORMAT_LONG);

        drawDayForecast(dc, columnsX, cursorY, dayInfo.day_of_week + ", " + dayInfo.day, weatherData[0], weatherData[1], CLOUD_SYMBOL, RAIN_SYMBOL);
        cursorY += fontTinyHeight + VERTICAL_SPACE;

        day = day.add(dayDuration);
        dayInfo = Gregorian.info(day, Time.FORMAT_LONG);

        drawDayForecast(dc, columnsX, cursorY, dayInfo.day_of_week + ", " + dayInfo.day, weatherData[0], weatherData[1], SUN_CLOUD_SYMBOL, SUN_SYMBOL);
        cursorY += fontTinyHeight + VERTICAL_SPACE;

        day = day.add(dayDuration);
        dayInfo = Gregorian.info(day, Time.FORMAT_LONG);

        drawDayForecast(dc, columnsX, cursorY, dayInfo.day_of_week + ", " + dayInfo.day, weatherData[0], weatherData[1], CLOUD_SYMBOL, SUN_SYMBOL);
        cursorY += fontTinyHeight + VERTICAL_SPACE;
        
        dc.setColor(COLOUR_WIND, COLOUR_BACKGROUND);
        dc.drawText(columnsX[1], cursorY, weatherFont, "" + WIND_SYMBOL, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(COLOUR_TEMPERATURE, COLOUR_BACKGROUND);
        dc.drawText(columnsX[2], cursorY, Graphics.FONT_SYSTEM_TINY, DEGREES_C_STRING, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }
}
