import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;

class DivesiteWeatherView extends WatchUi.View {
    const VERTICAL_SPACE = 2;
    const HORIZONTAL_SPACE = 2;
    const LINE_WIDTH = 3;

    const COLOUR_BACKGROUND = Graphics.COLOR_BLACK;
    const COLOUR_FOREGROUND = Graphics.COLOR_WHITE;
    const COLOUR_WIND = 0x00ffff;
    const COLOUR_TEMPERATURE = 0xff5555;
    const COLOUR_WEATHER = Graphics.COLOR_YELLOW;

    const WIND_SYMBOL = 0xf050.toChar();
    const DEGREES_C_STRING = "°C";
    const SUN_CLOUD_SYMBOL = 0xf002.toChar();
    const SUN_SYMBOL = 0xf00d.toChar();
    const RAIN_SYMBOL = 0xf015.toChar();
    const CLOUD_SYMBOL = 0xf041.toChar();

    var weatherFont;

    function initialize() {
        View.initialize();

        weatherFont = WatchUi.loadResource(Rez.Fonts.WeatherFont);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    function drawDayForecast(dc, columnsX, cursorY,  nameString, windMS, temperatureC, morningWeatherSymbol, afternoonWeatherSymbol) {
        dc.setColor(COLOUR_FOREGROUND, COLOUR_BACKGROUND);
        dc.drawText(columnsX[0], cursorY, Graphics.FONT_SYSTEM_XTINY, nameString, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(COLOUR_WIND, COLOUR_BACKGROUND);
        dc.drawText(columnsX[1], cursorY, Graphics.FONT_SYSTEM_TINY, "" + windMS, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(COLOUR_TEMPERATURE, COLOUR_BACKGROUND);
        dc.drawText(columnsX[2], cursorY, Graphics.FONT_SYSTEM_TINY, "" + temperatureC, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(COLOUR_WEATHER, COLOUR_BACKGROUND);
        dc.drawText(columnsX[3], cursorY, weatherFont, "" + morningWeatherSymbol, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(columnsX[4], cursorY, weatherFont, "" + afternoonWeatherSymbol, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function calculateViewPortBoundaryX(y, fontHeight, width, height, rightSide) as Number {
        var circleOriginX = width / 2;
        var circleOriginY = height / 2;

        if (y > circleOriginY) {
            y += fontHeight;
        }
        var normalisedY = (circleOriginY - y) / circleOriginY;     
        var angle = Math.asin(normalisedY);
        if (rightSide) {
            angle += Math.PI;
        }
        var normalisedX = Math.cos(angle);
        return circleOriginX - (normalisedX * circleOriginX);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        dc.setColor(COLOUR_FOREGROUND, COLOUR_BACKGROUND);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var fontXtinyHeight = dc.getFontHeight(Graphics.FONT_SYSTEM_XTINY);
        var fontTinyHeight = dc.getFontHeight(Graphics.FONT_SYSTEM_TINY);
        var fontSmallHeight = dc.getFontHeight(Graphics.FONT_SYSTEM_SMALL);

        var todayString = WatchUi.loadResource(Rez.Strings.TodayName);
     
        var siteName = "Lake Coleridge";
        var currentWindMS = 2;
        var currentTemperatureC = 14;
    
        var cursorY = height * 0.1f;
        dc.drawText(width * 0.5f, cursorY, Graphics.FONT_SYSTEM_SMALL, siteName, Graphics.TEXT_JUSTIFY_CENTER);
        cursorY += fontSmallHeight + VERTICAL_SPACE;
        dc.setPenWidth(LINE_WIDTH);
        dc.drawLine(0, cursorY, width, cursorY);
        cursorY += LINE_WIDTH + VERTICAL_SPACE;

        var nameColumnX = calculateViewPortBoundaryX(cursorY, fontXtinyHeight, width, height, false);
        var nameColumnXBottom = calculateViewPortBoundaryX(cursorY + 4 * (fontTinyHeight + VERTICAL_SPACE), fontXtinyHeight, width, height, false);
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

        drawDayForecast(dc, columnsX, cursorY, todayString, currentWindMS, currentTemperatureC, SUN_CLOUD_SYMBOL, CLOUD_SYMBOL);
        cursorY += fontTinyHeight + VERTICAL_SPACE;

        var dayDuration = new Time.Duration(Gregorian.SECONDS_PER_DAY);
        var day = Time.now().add(dayDuration);
        var dayInfo = Gregorian.info(day, Time.FORMAT_LONG);

        drawDayForecast(dc, columnsX, cursorY, dayInfo.day_of_week + ", " + dayInfo.day, 10, 22, SUN_CLOUD_SYMBOL, SUN_SYMBOL);
        cursorY += fontTinyHeight + VERTICAL_SPACE;

        day = day.add(dayDuration);
        dayInfo = Gregorian.info(day, Time.FORMAT_LONG);

        drawDayForecast(dc, columnsX, cursorY, dayInfo.day_of_week + ", " + dayInfo.day, 1, -10, CLOUD_SYMBOL, RAIN_SYMBOL);
        cursorY += fontTinyHeight + VERTICAL_SPACE;

        day = day.add(dayDuration);
        dayInfo = Gregorian.info(day, Time.FORMAT_LONG);

        drawDayForecast(dc, columnsX, cursorY, dayInfo.day_of_week + ", " + dayInfo.day, currentWindMS, currentTemperatureC, SUN_CLOUD_SYMBOL, SUN_SYMBOL);
        cursorY += fontTinyHeight + VERTICAL_SPACE;

        day = day.add(dayDuration);
        dayInfo = Gregorian.info(day, Time.FORMAT_LONG);

        drawDayForecast(dc, columnsX, cursorY, dayInfo.day_of_week + ", " + dayInfo.day, currentWindMS, currentTemperatureC, CLOUD_SYMBOL, SUN_SYMBOL);
        cursorY += fontTinyHeight + VERTICAL_SPACE;
        
        dc.setColor(COLOUR_WIND, COLOUR_BACKGROUND);
        dc.drawText(windColumnX, cursorY, weatherFont, "" + WIND_SYMBOL, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(COLOUR_TEMPERATURE, COLOUR_BACKGROUND);
        dc.drawText(temperatureColumnX, cursorY, Graphics.FONT_SYSTEM_TINY, DEGREES_C_STRING, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }
}
