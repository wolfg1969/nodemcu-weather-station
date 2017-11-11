--[=====[ 
https://www.heweather.com/documents/api/s6/weather-now
https://free-api.heweather.com/v5/weather?location=yourcity&key=yourkey
{
    "HeWeather6": [
        {
            "basic": {
                "cid": "CN101010100",
                "location": "北京",
                "parent_city": "北京",
                "admin_area": "北京",
                "cnty": "中国",
                "lat": "39.90498734",
                "lon": "116.40528870",
                "tz": "0.0"
            },
            "now": {
                "cond_code": "101",
                "cond_txt": "多云",
                "fl": "16",
                "hum": "73",
                "pcpn": "0",
                "pres": "1017",
                "tmp": "14",
                "vis": "1",
                "wind_deg": "11",
                "wind_dir": "北风",
                "wind_sc": "微风",
                "wind_spd": "6"
            },
            "status": "ok",
            "update": {
                "loc": "2017-10-26 17:29",
                "utc": "2017-10-26 09:29"
            }
        }
    ]
}
--]=====]
s = request['content']

print("s="..s)

local temp = domoticz_applyJsonPath(s, '.HeWeather6[0].now.tmp')
local hum = tonumber(domoticz_applyJsonPath(s, '.HeWeather6[0].now.hum'))
local pres = domoticz_applyJsonPath(s, '.HeWeather6[0].now.pres')
local condCode = tonumber(domoticz_applyJsonPath(s, '.HeWeather6[0].now.cond_code'))

local humStat = 0
if hum < 25 then
  humStat = 2
elseif hum > 60 then
  humStat = 3
elseif hum >= 25 and hum <= 60 then
  humStat = 1
end

local cond = 0
if condCode == 100 then
  cond = 1
elseif condCode == 103 then
  cond = 2
elseif condCode == 101 then
  cond = 3
elseif condCode >= 300 and condCode < 400 then
  cond = 4
end

print("temp=" .. temp .. " hum=" .. hum .. " pres=" .. pres .." cond=" .. cond)

domoticz_updateDevice(22, 0, temp .. ";" .. hum .. ";" .. humStat .. ";" .. pres .. ";" .. cond)

-- feel temp
local fl = domoticz_applyJsonPath(s, '.HeWeather5[0].now.fl')
domoticz_updateDevice(38, 0, fl)

--[=====[ 
 wind
 /json.htm?type=command&param=udevice&idx=IDX&nvalue=0&svalue=WB;WD;WS;WG;22;24
 IDX = id of your device (This number can be found in the devices tab in the column "IDX")
 WB = Wind bearing (0-359)
 WD = Wind direction (S, SW, NNW, etc.)
 WS = 10 * Wind speed [m/s]
 WG = 10 * Gust [m/s]
 22 = Temperature
 24 = Temperature Windchill
--]=====]
local wb = domoticz_applyJsonPath(s, '.HeWeather6[0].now.wind_deg')
local wd = domoticz_applyJsonPath(s, '.HeWeather6[0].now.wind_dir')
local ws = domoticz_applyJsonPath(s, '.HeWeather6[0].now.wind_spd')  -- km/h
ws = 10 * tonumber(ws) * 1000 / 3600
--local wg = domoticz_applyJsonPath(s, '.HeWeather5[0].now.wind.sc')
local wg = "0"
domoticz_updateDevice(39, 0, wb .. ";" .. wd .. ";" .. ws .. ";" .. wg .. ";".. temp .. ";" .. fl)
