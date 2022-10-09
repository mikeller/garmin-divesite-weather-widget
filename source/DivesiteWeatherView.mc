import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;

class DivesiteWeatherView extends WatchUi.View {
    const VERTICAL_SPACE = 4;
    const HORIZONTAL_SPACE = 4;
    const BACKGROUND_COLOUR = Graphics.COLOR_BLACK;
    const FOREGROUND_COLOUR = Graphics.COLOR_WHITE;

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

    function drawText(dc, cursorX, cursorY, font, text, justify, color) as Number {
        dc.setColor(color, BACKGROUND_COLOUR);
        dc.drawText(cursorX, cursorY, font, text, justify);
        
        var textWidth;
        if (justify == Graphics.TEXT_JUSTIFY_RIGHT) {
            textWidth = -dc.getTextWidthInPixels(text, font);
         } else {
            textWidth = dc.getTextWidthInPixels(text, font);
        }
        return cursorX + textWidth;
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
        dc.setColor(FOREGROUND_COLOUR, BACKGROUND_COLOUR);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var fontXtinyHeight = dc.getFontHeight(Graphics.FONT_XTINY);
        var fontTinyHeight = dc.getFontHeight(Graphics.FONT_TINY);
        var fontSmallHeight = dc.getFontHeight(Graphics.FONT_SMALL);
     
        var siteName = "Lake Coleridge";
        var currentWind = "2Ξ";
        var currentTemperature = "14°";
        var sunCloud = 98.toChar();
        var sun = 71.toChar();
        var rain = 105.toChar();
        var cloud = 101.toChar();
    
        var cursorY = height * 0.1f;
        dc.drawText(width * 0.5f, cursorY, Graphics.FONT_SMALL, siteName, Graphics.TEXT_JUSTIFY_CENTER);
        cursorY += fontSmallHeight + VERTICAL_SPACE;
        dc.drawLine(0, cursorY, width, cursorY);
        cursorY += 1 + VERTICAL_SPACE;

        var cursorYFifthBlock = cursorY;
        var cursorX = calculateViewPortBoundaryX(cursorY, fontXtinyHeight, width, height, false);
        dc.setColor(FOREGROUND_COLOUR, BACKGROUND_COLOUR);
        dc.drawText(cursorX, cursorY, Graphics.FONT_XTINY, WatchUi.loadResource(Rez.Strings.TodayName), Graphics.TEXT_JUSTIFY_LEFT);
        cursorY += fontXtinyHeight;
        cursorX = calculateViewPortBoundaryX(cursorY, fontTinyHeight, width, height, false);
        cursorX = drawText(dc, cursorX, cursorY, Graphics.FONT_SYSTEM_TINY, currentWind, Graphics.TEXT_JUSTIFY_LEFT, Graphics.COLOR_BLUE) + 1;
        cursorX = drawText(dc, cursorX, cursorY, Graphics.FONT_SYSTEM_TINY, currentTemperature, Graphics.TEXT_JUSTIFY_LEFT, Graphics.COLOR_RED) + 1;
        cursorX = drawText(dc, cursorX, cursorY, weatherFont, sunCloud + " " + cloud, Graphics.TEXT_JUSTIFY_LEFT, Graphics.COLOR_YELLOW);
        cursorY += fontTinyHeight + VERTICAL_SPACE;

        var cursorYFourthBlock = cursorY;
        cursorX = calculateViewPortBoundaryX(cursorY, fontXtinyHeight, width, height, false);
        dc.setColor(FOREGROUND_COLOUR, BACKGROUND_COLOUR);
        dc.drawText(cursorX, cursorY, Graphics.FONT_XTINY, WatchUi.loadResource(Rez.Strings.TomorrowName), Graphics.TEXT_JUSTIFY_LEFT);
        cursorY += fontXtinyHeight;
        cursorX = calculateViewPortBoundaryX(cursorY, fontTinyHeight, width, height, false);
        cursorX = drawText(dc, cursorX, cursorY, Graphics.FONT_SYSTEM_TINY, currentWind, Graphics.TEXT_JUSTIFY_LEFT, Graphics.COLOR_BLUE) + 1;
        cursorX = drawText(dc, cursorX, cursorY, Graphics.FONT_SYSTEM_TINY, currentTemperature, Graphics.TEXT_JUSTIFY_LEFT, Graphics.COLOR_RED) + 1;
        cursorX = drawText(dc, cursorX, cursorY, weatherFont, sunCloud + " " + sun, Graphics.TEXT_JUSTIFY_LEFT, Graphics.COLOR_YELLOW);
        cursorY += fontTinyHeight + VERTICAL_SPACE;

        var dayDuration = new Time.Duration(Gregorian.SECONDS_PER_DAY);
        var day = Time.now().add(dayDuration).add(dayDuration);
        var dayInfo = Gregorian.info(day, Time.FORMAT_LONG);

        dc.setColor(FOREGROUND_COLOUR, BACKGROUND_COLOUR);
        dc.drawText(width / 2, cursorY, Graphics.FONT_XTINY, dayInfo.day_of_week + ", " + dayInfo.day, Graphics.TEXT_JUSTIFY_CENTER);
        cursorY += fontXtinyHeight;
        cursorX = calculateViewPortBoundaryX(cursorY, fontTinyHeight, width, height, false);
        cursorX = drawText(dc, cursorX, cursorY, Graphics.FONT_SYSTEM_TINY, currentWind, Graphics.TEXT_JUSTIFY_LEFT, Graphics.COLOR_BLUE) + 1;
        cursorX = drawText(dc, cursorX, cursorY, Graphics.FONT_SYSTEM_TINY, currentTemperature, Graphics.TEXT_JUSTIFY_LEFT, Graphics.COLOR_RED) + 1;
        cursorX = drawText(dc, cursorX, cursorY, weatherFont, cloud + " " + rain, Graphics.TEXT_JUSTIFY_LEFT, Graphics.COLOR_YELLOW);

        day = day.add(dayDuration);
        dayInfo = Gregorian.info(day, Time.FORMAT_LONG);

        cursorY = cursorYFourthBlock;
        cursorX = calculateViewPortBoundaryX(cursorY, fontXtinyHeight, width, height, true);
        dc.setColor(FOREGROUND_COLOUR, BACKGROUND_COLOUR);
        dc.drawText(cursorX, cursorY, Graphics.FONT_XTINY, dayInfo.day_of_week + ", " + dayInfo.day, Graphics.TEXT_JUSTIFY_RIGHT);
        cursorY += fontXtinyHeight;
        cursorX = calculateViewPortBoundaryX(cursorY, fontTinyHeight, width, height, true);
        cursorX = drawText(dc, cursorX, cursorY, weatherFont, sunCloud + " " + sun, Graphics.TEXT_JUSTIFY_RIGHT, Graphics.COLOR_YELLOW) - 1;
        cursorX = drawText(dc, cursorX, cursorY, Graphics.FONT_SYSTEM_TINY, currentTemperature, Graphics.TEXT_JUSTIFY_RIGHT, Graphics.COLOR_RED) - 1;
        cursorX = drawText(dc, cursorX, cursorY, Graphics.FONT_SYSTEM_TINY, currentWind, Graphics.TEXT_JUSTIFY_RIGHT, Graphics.COLOR_BLUE);

        day = day.add(dayDuration);
        dayInfo = Gregorian.info(day, Time.FORMAT_LONG);

        cursorY = cursorYFifthBlock;
        cursorX = calculateViewPortBoundaryX(cursorY, fontXtinyHeight, width, height, true);
        dc.setColor(FOREGROUND_COLOUR, BACKGROUND_COLOUR);
        dc.drawText(cursorX, cursorY, Graphics.FONT_XTINY, dayInfo.day_of_week + ", " + dayInfo.day, Graphics.TEXT_JUSTIFY_RIGHT);
        cursorY += fontXtinyHeight;
        cursorX = calculateViewPortBoundaryX(cursorY, fontTinyHeight, width, height, true);
        cursorX = drawText(dc, cursorX, cursorY, weatherFont, cloud + " " + sun, Graphics.TEXT_JUSTIFY_RIGHT, Graphics.COLOR_YELLOW) - 1;
        cursorX = drawText(dc, cursorX, cursorY, Graphics.FONT_SYSTEM_TINY, currentTemperature, Graphics.TEXT_JUSTIFY_RIGHT, Graphics.COLOR_RED) - 1;
        cursorX = drawText(dc, cursorX, cursorY, Graphics.FONT_SYSTEM_TINY, currentWind, Graphics.TEXT_JUSTIFY_RIGHT, Graphics.COLOR_BLUE);
     }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }
}
