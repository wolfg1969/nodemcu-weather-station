# 基于 NodeMCU 实现的室内气象站

可显示室内温度、湿度、气压和室外温度、湿度、天气状况。

## 硬件
* ESP8266
* 128x64 i2c OLED
* BMP280 Temp/Pressure sensor
* DHT11 Temp/Humidity sensor

花费约 70 元左右

## NodeMCU 固件定制

* dev 分支 commit: [4095c26](https://github.com/nodemcu/nodemcu-firmware/tree/4095c26bd0d3c859c5b66ad7e460485b068b8d8e)
* 需要的模块:
  * bme280
  * crypto
  * dht
  * gpio
  * http
  * i2c
  * sjson
  * tmr
  * u8g
  * wifi
* 字体
```
#define U8G_FONT_TABLE                          \
    U8G_FONT_TABLE_ENTRY(font_6x10)             \
    U8G_FONT_TABLE_ENTRY(font_helvR24)          \
    U8G_FONT_TABLE_ENTRY(font_9x18r)
#undef U8G_FONT_TABLE_ENTRY
```

## 参数配置
将 config.lua.txt 复制成 config.lua 并根据实际环境修改参数值
```lua
  OLED_ADDR = 0x3c,
  
  SDA_PIN = 1, -- SDA Pin, D1
  SCL_PIN = 2, -- SCL Pin, D2
  DHT_PIN = 3, -- DHT Pin, D3
  
  ALTITUDE = 72, -- 海拔高度
  
  WIFI_SSID = "<WIFI_SSID>",
  WIFI_PASSWD = "<WIFI_PASSWD>",
  
  DOMOTICZ_USER = "<DOMOTICZ_USER>",
  DOMOTICZ_PASSWD = "<DOMOTICZ_PASSWD>",
  DOMOTICZ_API_URL = "<DOMOTICZ_API_URL>",
  DOMOTICZ_INDOOR_DEVICE_ID = "<DOMOTICZ_INDOOR_DEVICE_ID>",
  DOMOTICZ_OUTDOOR_DEVICE_ID = "<DOMOTICZ_OUTDOOR_DEVICE_ID>"
```

## Domoticz 集成

* 室内传感器，接收 NodeMCU 上报的数据
  * 添加硬件，类型为 Dummy
  * 创建类型为 Temp + Humidity + Baro 的虚拟设备
  * 将此设备的 id 做为气象站的 DOMOTICZ_INDOOR_DEVICE_ID 参数值
* 室外传感器，从[和风天气](https://console.heweather.com)接口获取外部气象数据 [实况天气-now 接口](https://www.heweather.com/documents/api/v5/now)
  * 添加类型为 HTTP/HTTPS poller 的硬件
    * Method: GET
    * Content Type: application/json
    * URL: <pre>https://free-api.heweather.com/v5/now?city=[city code]&key=[auth key]&lang=en</pre>
    * Command: heweather-now-parser.lua
  * 创建类型为 Temp + Humidity + Baro 的虚拟设备
  * * 将此设备的 id 做为气象站的 DOMOTICZ_OUTDOOR_DEVICE_ID 参数值
  * 将 domoticz_server 目录下的 heweather-now-parser.lua 放到 Domoticz 服务器主目录下的 scripts/lua_parsers 目录中
  
