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
local sensor = require("weather_sensor")

-- setup I2c and connect to modules
function init()
    i2c.setup(0, config.OLED_SDA_PIN, config.OLED_SCL_PIN, i2c.SLOW)
    i2c.setup(0, config.BME280_SDA_PIN, config.BME280_SCL_PIN, i2c.SLOW)
    
    display.init(config.OLED_ADDR)

    sensor.init()
end


function getIn() 
  
  sensor.read(config.DHT_PIN, config.ALTITUDE, function(inTemp, inHum, inPress)
    data.inTemp = inTemp
    data.inHum = inHum
    data.inPress = inPress
    display.render(data)
  end)
end


function reportToDomoticz() 
  -- update sensor
  domoticz.updateSensorTempHum(
    config.DOMOTICZ_API_URL, 
    config.DOMOTICZ_USER,
    config.DOMOTICZ_PASSWD,
    config.DOMOTICZ_INDOOR_DEVICE_ID,
    data
  )
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
        reportToDomoticz()
        
    end)
end


print("setting up")

init()

getIn()
getOut()

tmr.alarm(0, 1*60*1000, 1, getIn) -- 1*60*1000 = every 1 minutes
tmr.alarm(2, 5*60*1000, 1, getOut) -- 1*60*1000 = every 5 minutes

print("all set")
