import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

(:glance)
class WeatherGlanceView extends WatchUi.GlanceView {
    private var location as Dictionary<String, Float or String>?;
    private var glanceTitle as String = "Divesite Weather";
    private var glanceContent as String = "[data missing]";

    function initialize(location as Dictionary?) {
        GlanceView.initialize();

        self.location = location as Dictionary<String, Float or String>?;
    }

    function onLayout(dc as Dc) as Void {
        try {
            var cache = null;
            if (location != null) {
                var latitude = location["latitude"] as Float;
                var longitude = location["longitude"] as Float;

                var displayName = location["displayName"] as String;
                if ("".equals(displayName)) {
                    glanceTitle = Conversions.locationToString(latitude, longitude);
                } else {
                    glanceTitle = displayName;
                }

                cache = YrDataCache.tryGetCachedData(latitude, longitude, true);
            }

            if (cache != null) {
                var index = 0;
                while (index < cache.size()) {
                    var weatherInfo = cache[index];

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
                        var data = weatherInfo["data"] as Dictionary<String, Float or String>;

                        glanceContent = "";
                        
                        var windSpeedMs = data["max_wind_speed"];
                        if (windSpeedMs != null) {
                            glanceContent = glanceContent + "W: " + Math.round(windSpeedMs as Float).format("%.0f");
                        }

                        var airTemperatureC = data["max_air_temperature"];
                        if (airTemperatureC != null) {
                            glanceContent = glanceContent + "T: " + Math.round(airTemperatureC as Float).format("%.0f");
                        }

                        break;
                    }

                    index++;
                }
            }
        } catch (exception instanceof UnexpectedTypeException) {
            // our input data is bad and cannot be displayed
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(0, 0, Graphics.FONT_SYSTEM_TINY, glanceTitle, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(0, 26, Graphics.FONT_SYSTEM_TINY, glanceContent, Graphics.TEXT_JUSTIFY_LEFT);
    }
}