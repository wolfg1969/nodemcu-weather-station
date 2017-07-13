--[=====[ 
https://free-api.heweather.com/v5/weather?city=yourcity&key=yourkey
https://www.heweather.com/documents/api/v5/weather
{
    "HeWeather5": [
        {
            "alarms": [
                {
                    "level": "蓝色",
                    "stat": "预警中",
                    "title": "山东省青岛市气象台发布大风蓝色预警",
                    "txt": "青岛市气象台2016年08月29日15时24分继续发布大风蓝色预警信号：预计今天下午到明天，我市北风风力海上6到7级阵风9级，陆地4到5阵风7级，请注意防范。",
                    "type": "大风"
                }
            ],
            "aqi": {
                "city": {
                    "aqi": "60",
                    "co": "0",
                    "no2": "14",
                    "o3": "95",
                    "pm10": "67",
                    "pm25": "15",
                    "qlty": "良",  //共六个级别，分别：优，良，轻度污染，中度污染，重度污染，严重污染
                    "so2": "10"
                }
            },
            "basic": {
                "city": "青岛",
                "cnty": "中国",
                "id": "CN101120201",
                "lat": "36.088000",
                "lon": "120.343000",
                "prov": "山东"  //城市所属省份（仅限国内城市）
                "update": {
                    "loc": "2016-08-30 11:52",
                    "utc": "2016-08-30 03:52"
                }
            },
            "daily_forecast": [
                {
                    "astro": {
                        "mr": "03:09",
                        "ms": "17:06",
                        "sr": "05:28",
                        "ss": "18:29"
                    },
                    "cond": {
                        "code_d": "100",
                        "code_n": "100",
                        "txt_d": "晴",
                        "txt_n": "晴"
                    },
                    "date": "2016-08-30",
                    "hum": "45",
                    "pcpn": "0.0",
                    "pop": "8",
                    "pres": "1005",
                    "tmp": {
                        "max": "29",
                        "min": "22"
                    },
                    "vis": "10",
                    "wind": {
                        "deg": "339",
                        "dir": "北风",
                        "sc": "4-5",
                        "spd": "24"
                    }
                }
            ],
            "hourly_forecast": [
                {
                    "cond": {
                        "code": "100",
                        "txt": "晴"
                    },
                    "date": "2016-08-30 12:00",
                    "hum": "47",
                    "pop": "0",
                    "pres": "1006",
                    "tmp": "29",
                    "wind": {
                        "deg": "335",
                        "dir": "西北风",
                        "sc": "4-5",
                        "spd": "36"
                    }
                }
            ],
            "now": {
                "cond": {
                    "code": "100",
                    "txt": "晴"
                },
                "fl": "28",
                "hum": "41",
                "pcpn": "0",
                "pres": "1005",
                "tmp": "26",
                "vis": "10",
                "wind": {
                    "deg": "330",
                    "dir": "西北风",
                    "sc": "6-7",
                    "spd": "34"
                }
            },
            "status": "ok",
            "suggestion": {
                "comf": {
                    "brf": "较舒适",
                    "txt": "白天天气晴好，您在这种天气条件下，会感觉早晚凉爽、舒适，午后偏热。"
                },
                "cw": {
                    "brf": "较不宜",
                    "txt": "较不宜洗车，未来一天无雨，风力较大，如果执意擦洗汽车，要做好蒙上污垢的心理准备。"
                },
                "drsg": {
                    "brf": "热",
                    "txt": "天气热，建议着短裙、短裤、短薄外套、T恤等夏季服装。"
                },
                "flu": {
                    "brf": "较易发",
                    "txt": "虽然温度适宜但风力较大，仍较易发生感冒，体质较弱的朋友请注意适当防护。"
                },
                "sport": {
                    "brf": "较适宜",
                    "txt": "天气较好，但风力较大，推荐您进行室内运动，若在户外运动请注意防风。"
                },
                "trav": {
                    "brf": "适宜",
                    "txt": "天气较好，风稍大，但温度适宜，是个好天气哦。适宜旅游，您可以尽情地享受大自然的无限风光。"
                },
                "uv": {
                    "brf": "强",
                    "txt": "紫外线辐射强，建议涂擦SPF20左右、PA++的防晒护肤品。避免在10点至14点暴露于日光下。"
                }
            }
        }
    ]
}
--]=====]
s = request['content']

print("s="..s)

local temp = domoticz_applyJsonPath(s, '.HeWeather5[0].now.tmp')
local hum = domoticz_applyJsonPath(s, '.HeWeather5[0].now.hum')
local pres = domoticz_applyJsonPath(s, '.HeWeather5[0].now.pres')
local condCode = tonumber(domoticz_applyJsonPath(s, '.HeWeather5[0].now.cond.code'))

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

domoticz_updateDevice(22, 0, temp .. ";" .. hum .. ";" .. "0;" .. pres .. ";" .. cond)

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
local wb = domoticz_applyJsonPath(s, '.HeWeather5[0].now.wind.deg')
local wd = domoticz_applyJsonPath(s, '.HeWeather5[0].now.wind.dir')
local ws = domoticz_applyJsonPath(s, '.HeWeather5[0].now.wind.spd')  -- km/h
ws = 10 * tonumber(ws) * 1000 / 3600
--local wg = domoticz_applyJsonPath(s, '.HeWeather5[0].now.wind.sc')
domoticz_updateDevice(39, 0, wb .. ";" .. wd .. ";" .. ws .. ";" .. "0" .. ";".. temp .. ";0")

-- air quality
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

local qlty_desc = qlty .. ", " .. aqi .. " AQI" .. " @" .. update

print("aqi=" .. aqi .. " pm10=" .. pm10 .. " pm25=" .. pm25 .." qlty=" .. qlty)

domoticz_updateDevice(24, 0, aqi)
domoticz_updateDevice(25, 0, pm25)
domoticz_updateDevice(26, 0, pm10)
domoticz_updateDevice(27, 0, qlty_desc)
domoticz_updateDevice(28, alert_level, qlty_desc)


