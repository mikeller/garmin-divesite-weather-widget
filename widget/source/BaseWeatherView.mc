import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class BaseWeatherView extends WatchUi.View {
    protected var siteName as String = "";
    protected var dataIsStale as Boolean = false;

    protected var cursorY as Number = 0;

    function initialize(siteName as String, dataIsStale as Boolean) {
        View.initialize();

        self.siteName = siteName;
        self.dataIsStale = dataIsStale;
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Constants.COLOUR_FOREGROUND, Constants.COLOUR_BACKGROUND);
        dc.clear();

        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();

        if (dataIsStale) {
            dc.drawBitmap(screenWidth / 2 - 10, 2 * Constants.VERTICAL_SPACE, getConnectionProblemIcon());
        }

        var titleWidth = getTitleWidth(dc);

        cursorY = screenHeight / 10;
        dc.drawText(titleWidth / 2, cursorY, Graphics.FONT_SYSTEM_SMALL, siteName, Graphics.TEXT_JUSTIFY_CENTER);
        cursorY += dc.getFontHeight(Graphics.FONT_SYSTEM_SMALL) + Constants.VERTICAL_SPACE;
        dc.setPenWidth(Constants.LINE_WIDTH);
        dc.drawLine(0, cursorY, titleWidth, cursorY);
        cursorY += Constants.LINE_WIDTH + Constants.VERTICAL_SPACE;
    }

    (:colourDisplay)
    private function getConnectionProblemIcon() as BitmapReference {
        return WatchUi.loadResource(Rez.Drawables.ConnectionProblemIcon) as BitmapReference;
    }

    (:blackAndWhiteDisplay)
    private function getConnectionProblemIcon() as BitmapReference {
        return WatchUi.loadResource(Rez.Drawables.ConnectionProblemIconBlackAndWhite) as BitmapReference;
    }

    (:roundScreen)
    private function getTitleWidth(dc as Dc) as Number {
        return dc.getWidth();
    }

    (:semioctagonalScreen)
    private function getTitleWidth(dc as Dc) as Number {
        return 112;
    }
}
