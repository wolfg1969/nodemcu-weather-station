sda = 1 -- SDA Pin, D1
scl = 2 -- SCL Pin, D2
dhtPin = 3 -- DHT Pin, D3

local data = {
    inTemp = "",
    outTemp = "",
    inPress = "",
    outCond = "",
    inHum = "",
    outHum = ""
}

local config = require('config')
local display = require("display")
local domoticz = require("domoticz")

-- setup I2c and connect to modules
function init()
    i2c.setup(0, sda, scl, i2c.SLOW)
end


function getIn() 

    status,temp,humidity,temp_decimial,humi_decimial = dht.read11(dhtPin)
    if (status == dht.OK) then
      data.inTemp = temp
      data.inHum = humidity
      print(temp..", "..humidity)
    else
      -- other possibilities are dht.ERROR_TIMEOUT and dht.ERROR_CHECKSUM
      data.inTemp = "?"
      data.inHum = "?"
    end
    display.render(data)
end


function getOut()
  domoticz.getSensorTempHumBaro(
    config.DOMOTICZ_API_URL,
    config.DOMOTICZ_USER,
    config.DOMOTICZ_PASSWD,
    config.DOMOTICZ_OUTDOOR_DEVICE_ID,
    function(outTemp, outHum, outCond)
        data.outTemp = outTemp or "?"
        data.outHum = outHum or "?"
        data.outCond = outCond or "?"
        display.render(data)
    end)
end


function update() 
    getIn()
    domoticz.updateSensorTempHum(
      config.DOMOTICZ_API_URL, 
      config.DOMOTICZ_USER,
      config.DOMOTICZ_PASSWD,
      config.DOMOTICZ_INDOOR_DEVICE_ID,
      data
    )
end


print("setting up")

init()

display.init(config.OLED_ADDR)
print("display inited")

getOut()
getIn()

tmr.alarm(0, 1*60*1000, 1, update) -- 1*60*1000 = every 1 minutes
tmr.alarm(2, 5*60*1000, 1, getOut) -- 5*60*1000 = every 5 minutes

print("all set")
