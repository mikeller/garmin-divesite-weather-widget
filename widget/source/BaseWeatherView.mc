import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class BaseWeatherView extends WatchUi.View {
    protected const VERTICAL_SPACE as Number = 2;
    protected const HORIZONTAL_SPACE as Number = 2;
    protected const LINE_WIDTH as Number = 3;

    protected const COLOUR_BACKGROUND as Number = Graphics.COLOR_BLACK;
    protected const COLOUR_FOREGROUND as Number = Graphics.COLOR_WHITE;

    protected var siteName as String = "";
    protected var connectionProblem as Boolean = false;

    protected var cursorY as Number = 0;

    function initialize(siteName as String, connectionProblem as Boolean) {
        View.initialize();

        self.siteName = siteName;
        self.connectionProblem = connectionProblem;
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

    protected function calculateViewPortBoundaryX(y as Number, fontHeight as Number, screenWidth as Number, screenHeight as Number, rightSide as Boolean) as Number {
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
        return Math.round(circleOriginX - (normalisedX * circleOriginX));
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(COLOUR_FOREGROUND, COLOUR_BACKGROUND);
        dc.clear();

        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();

        if (connectionProblem) {
            var connectionProblemIcon = WatchUi.loadResource(Rez.Drawables.ConnectionProblemIcon) as BitmapReference;
            dc.drawBitmap(screenWidth / 2 - 10, 2 * VERTICAL_SPACE, connectionProblemIcon);
        }

        cursorY = screenHeight / 10;
        dc.drawText(screenWidth / 2, cursorY, Graphics.FONT_SYSTEM_SMALL, siteName, Graphics.TEXT_JUSTIFY_CENTER);
        cursorY += dc.getFontHeight(Graphics.FONT_SYSTEM_SMALL) + VERTICAL_SPACE;
        dc.setPenWidth(LINE_WIDTH);
        dc.drawLine(0, cursorY, screenWidth, cursorY);
        cursorY += LINE_WIDTH + VERTICAL_SPACE;
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }
}
