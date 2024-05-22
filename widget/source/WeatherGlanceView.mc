import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

(:glance)
class WeatherGlanceView extends WatchUi.GlanceView {
    private var location as Dictionary<String, Float or String>?;
    private var glanceTitle as String = WatchUi.loadResource(Rez.Strings.AppName) as String;
    private var windFromDirectionDegrees as Float?;
    private var windSpeedMs as Float?;
    private var airTemperatureC as Float?;
    private var morningWeatherSymbol as String?;
    private var afternoonWeatherSymbol as String?;

    function initialize(location as Dictionary?) {
        GlanceView.initialize();

        self.location = location as Dictionary<String, Float or String>?;
    }

    function onLayout(dc as Dc) as Void {
        try {
            if (location != null) {
                var latitude = location["latitude"] as Float;
                var longitude = location["longitude"] as Float;

                var displayName = location["displayName"] as String;
                if ("".equals(displayName)) {
                    glanceTitle = Utils.locationToString(latitude, longitude);
                } else {
                    glanceTitle = displayName;
                }

                var cache = YrDataCache.tryGetCachedData(latitude, longitude, true);

                if (cache != null) {
                    var index = 0;
                    while (index < cache.size()) {
                        var weatherInfo = cache[index];

                        var day = Gregorian.moment({
                            :year => ((weatherInfo["time"] as String).substring( 0, 4) as String).toNumber() as Number,
                            :month => ((weatherInfo["time"] as String).substring( 5, 7) as String).toNumber() as Number,
                            :day => ((weatherInfo["time"] as String).substring( 8, 10) as String).toNumber() as Number,
                        });

                        var todayInfo= Gregorian.info(Time.now(), Time.FORMAT_LONG);
                        var today = Gregorian.moment({
                            :year => todayInfo.year as Number,
                            :month => todayInfo.month as Number,
                            :day => todayInfo.day as Number,
                        });

                        if (day.compare(today) >= 0) {
                            var data = weatherInfo["data"] as Dictionary<String, Float or String>;
                            
                            windFromDirectionDegrees = data["max_wind_from_direction"] as Float?;
                            windSpeedMs = data["max_wind_speed"] as Float?;
                            airTemperatureC = data["max_air_temperature"] as Float?;
                            morningWeatherSymbol = data["morning_symbol_code"] as String?;
                            afternoonWeatherSymbol = data["afternoon_symbol_code"] as String?;

                            break;
                        }

                        index++;
                    }
                }
            }
        } catch (exception instanceof UnexpectedTypeException) {
            Utils.log("Data format problem: " + exception.getErrorMessage());
            exception.printStackTrace();
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(0, 0, Graphics.FONT_SYSTEM_TINY, glanceTitle, Graphics.TEXT_JUSTIFY_LEFT);

        var lineHeight = dc.getFontHeight(Graphics.FONT_SYSTEM_TINY);
        var secondLineY = lineHeight + Constants.VERTICAL_SPACE;

        var secondLineX = 0;
        var windText;
        if (windSpeedMs != null) {
            windText = Math.round(windSpeedMs as Float).format("%.0f") + Constants.METRES_PER_SECOND_STRING;
            dc.setColor(Constants.COLOUR_WIND, Constants.COLOUR_BACKGROUND);
            dc.drawText(secondLineX, secondLineY, Graphics.FONT_SYSTEM_TINY, windText, Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            windText = "5" + Constants.METRES_PER_SECOND_STRING;
        }

        secondLineX = secondLineX + dc.getTextWidthInPixels(windText, Graphics.FONT_SYSTEM_TINY);
        if (windFromDirectionDegrees != null) {
            var directionArrow = CoreIconManager.loadArrowIcon(windFromDirectionDegrees);
            if (directionArrow != null) {
                dc.drawBitmap(secondLineX, secondLineY, directionArrow);
            }
        }

        secondLineX = secondLineX + Constants.WIND_DIRECTION_ARROW_WIDTH + dc.getTextWidthInPixels(" ", Graphics.FONT_SYSTEM_TINY);
        var temperatureText;
        if (airTemperatureC != null) {
            temperatureText = Math.round(airTemperatureC as Float).format("%.0f") + Constants.DEGREES_C_STRING;
            dc.setColor(Constants.COLOUR_TEMPERATURE, Constants.COLOUR_BACKGROUND);
            dc.drawText(secondLineX, secondLineY, Graphics.FONT_SYSTEM_TINY, temperatureText, Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            temperatureText = "5" + Constants.DEGREES_C_STRING;
        }

        secondLineX = secondLineX + dc.getTextWidthInPixels(temperatureText + " ", Graphics.FONT_SYSTEM_TINY);
        if (morningWeatherSymbol != null) {
            var morningWeatherIcon = CoreIconManager.loadWeatherIcon(morningWeatherSymbol);
            if (morningWeatherIcon != null) {
                dc.drawBitmap(secondLineX, secondLineY, morningWeatherIcon);
            }
        }

        // Symbols are square, so their width is equal to lineHeight
        secondLineX = secondLineX + lineHeight + 2 * Constants.HORIZONTAL_SPACE_SYMBOLS;
        if (afternoonWeatherSymbol != null) {
            var afternoonWeatherIcon = CoreIconManager.loadWeatherIcon(afternoonWeatherSymbol);
            if (afternoonWeatherIcon != null) {
                dc.drawBitmap(secondLineX, secondLineY, afternoonWeatherIcon);
            }
        }
    }
}