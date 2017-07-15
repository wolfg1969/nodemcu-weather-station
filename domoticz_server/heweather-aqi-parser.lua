--[=====[ 
    "HeWeather5": [
        {
            "aqi": {
                "city": {
                    "aqi": "170",
                    "pm10": "96",
                    "pm25": "129",
                    "qlty": "Unhealthy"
                }
            },
            "basic": {
                "city": "fengtai",
                "cnty": "China",
                "id": "CN101010900",
                "lat": "39.86364365",
                "lon": "116.28696442",
                "update": {
                    "loc": "2017-07-06 08:49",
                    "utc": "2017-07-06 00:49"
                }
            },
            "status": "ok"
        }
    ]
}
--]=====]
s = request['content']

print("s="..s)

local deviceId = 22

local aqi = domoticz_applyJsonPath(s, '.HeWeather5[0].aqi.city.aqi')
local pm10 = domoticz_applyJsonPath(s, '.HeWeather5[0].aqi.city.pm10')
local pm25 = domoticz_applyJsonPath(s, '.HeWeather5[0].aqi.city.pm25')
local qlty = domoticz_applyJsonPath(s, '.HeWeather5[0].aqi.city.qlty')
local update = domoticz_applyJsonPath(s, '.HeWeather5[0].basic.update.loc')

local alert_level = 0  -- 0=gray, 1=green, 2=yellow, 3=orange, 4=red
aqi_value = tonumber(aqi)
if aqi_value >=0 and aqi_value<=50 then
  alert_level = 1
elseif aqi_value >=51 and aqi_value<=100 then
  alert_level = 2 
elseif aqi_value >=101 and aqi_value<=150 then
  alert_level = 3
elseif aqi_value >=151 then
  alert_level = 4
end

local short_qlty_desc = qlty .. ", " .. aqi
local long_qlty_desc = qlty .. ", " .. aqi .. " AQI" .. " @" .. update

print("aqi=" .. aqi .. " pm10=" .. pm10 .. " pm25=" .. pm25 .." qlty=" .. qlty)

domoticz_updateDevice(24, 0, aqi)
domoticz_updateDevice(25, 0, pm25)
domoticz_updateDevice(26, 0, pm10)
domoticz_updateDevice(27, 0, long_qlty_desc)
domoticz_updateDevice(28, alert_level, short_qlty_desc)
