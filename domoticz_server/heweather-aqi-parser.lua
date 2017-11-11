--[=====[ 
https://www.heweather.com/documents/api/s6/air-now
{
    "HeWeather6": [
        {
            "air_now_city": {
                "aqi": "19",
                "co": "0",
                "main": "",
                "no2": "34",
                "o3": "31",
                "pm10": "18",
                "pm25": "8",
                "pub_time": "2017-11-07 22:00",
                "qlty": "优",
                "so2": "2"
            },
            "air_now_station": [
                ...
            ],
            "basic": {
                "cid": "CN101010100",
                "location": "北京",
                "parent_city": "北京",
                "admin_area": "北京",
                "cnty": "中国",
                "lat": "39.90498734",
                "lon": "116.40528870",
                "tz": "+8.0"
            },
            "status": "ok",
            "update": {
                "loc": "2017-11-07 22:46",
                "utc": "2017-11-07 14:46"
            }
        }
    ]
}
--]=====]
s = request['content']

print("s="..s)

local deviceId = 22

local aqi = domoticz_applyJsonPath(s, '.HeWeather6[0].air_now_city.aqi')
local pm10 = domoticz_applyJsonPath(s, '.HeWeather6[0].air_now_city.pm10')
local pm25 = domoticz_applyJsonPath(s, '.HeWeather6[0].air_now_city.pm25')
local qlty = domoticz_applyJsonPath(s, '.HeWeather6[0].air_now_city.qlty')
local update = domoticz_applyJsonPath(s, '.HeWeather6[0].update.loc')

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
