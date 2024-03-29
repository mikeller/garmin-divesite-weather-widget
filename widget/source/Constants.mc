import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

(:glance)
class Constants {
    static const REFRESH_DELAY_S = 30;

    static const MAX_CONCURRENT_REQUESTS = 3;

    (:roundScreen)
    static const DAYS_TO_SHOW = 5;
    (:semioctagonalScreen)
    static const DAYS_TO_SHOW = 4;

    static const VERTICAL_SPACE as Number = 2;

    (:roundScreen)
    static const HORIZONTAL_SPACE as Number = 1;
    (:semioctagonalScreen)
    static const HORIZONTAL_SPACE as Number = 1;

    (:roundScreen)
    static const HORIZONTAL_SPACE_SYMBOLS as Number = 2;
    (:semioctagonalScreen)
    static const HORIZONTAL_SPACE_SYMBOLS as Number = 4;

    static const WIND_DIRECTION_ARROW_WIDTH as Number = 13;

    static const LINE_WIDTH as Number = 3;

    (:semioctagonalScreen)
    static const SEMIOCTAGONAL_CORNER_HEIGHT = 33;

    (:semioctagonalScreen)
    static const SUB_WINDOW_X = 113;

    (:semioctagonalScreen)
    static const SUB_WINDOW_Y = 1;

    (:semioctagonalScreen)
    static const SUB_WINDOW_SIZE = 62;

    static const COLOUR_BACKGROUND as Number = Graphics.COLOR_BLACK;
    static const COLOUR_FOREGROUND as Number = Graphics.COLOR_WHITE;

    (:colourDisplay)
    static const COLOUR_WIND as Number = 0x00ffff;
    (:blackAndWhiteDisplay)
    static const COLOUR_WIND as Number = Graphics.COLOR_WHITE;

    (:colourDisplay)
    static const COLOUR_TEMPERATURE as Number = 0xff5555;
    (:blackAndWhiteDisplay)
    static const COLOUR_TEMPERATURE as Number = Graphics.COLOR_WHITE;

    (:colourDisplay)
    static const COLOUR_WEATHER as Number = Graphics.COLOR_YELLOW;
    (:blackAndWhiteDisplay)
    static const COLOUR_WEATHER as Number = Graphics.COLOR_WHITE;

    static const WEATHER_SYMBOL_UNKNOWN_STRING as String = "  ?";

    static const METRES_PER_SECOND_STRING as String = WatchUi.loadResource(Rez.Strings.MetresPerSecond) as String;
    static const DEGREES_C_STRING as String = WatchUi.loadResource(Rez.Strings.DegreesCelsius) as String;

    static const TODAY_STRING as String = WatchUi.loadResource(Rez.Strings.TodayName) as String;
}
