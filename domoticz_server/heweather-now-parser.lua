-- {
--     "HeWeather5": [
--         {
--             "basic": { //基本信息
--                 "city": "北京",  //城市名称
--                 "cnty": "中国",   //国家
--                 "id": "CN101010100",  //城市ID
--                 "lat": "39.904000", //城市维度
--                 "lon": "116.391000", //城市经度
--                 "prov": "北京",  //城市所属省份（仅限国内城市）
--                 "update": {  //更新时间
--                     "loc": "2016-08-31 11:52",  //当地时间
--                     "utc": "2016-08-31 03:52" //UTC时间
--                 }
--             },
--             "now": {  //实况天气
--                 "cond": {  //天气状况
--                     "code": "104",  //天气状况代码
--                     "txt": "阴"  //天气状况描述
--                 },
--                 "fl": "11",  //体感温度
--                 "hum": "31",  //相对湿度（%）
--                 "pcpn": "0",  //降水量（mm）
--                 "pres": "1025",  //气压
--                 "tmp": "13",  //温度
--                 "vis": "10",  //能见度（km）
--                 "wind": {  //风力风向
--                     "deg": "40",  //风向（360度）
--                     "dir": "东北风",  //风向
--                     "sc": "4-5",  //风力
--                     "spd": "24"  //风速（kmph）
--                 }
--             },
--             "status": "ok"  //接口状态
--         }
--     ]
-- }
s = request['content']

print("s="..s)

local deviceId = 22

local temp = domoticz_applyJsonPath(s, '.HeWeather5[0].now.fl')
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

domoticz_updateDevice(deviceId, 0, temp .. ";" .. hum .. ";" .. "0;" .. pres .. ";" .. cond)

