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


function getIn() 
  
  sensor.read(config.DHT_PIN, config.ALTITUDE, function(inTemp, inHum, inPress)
    data.inTemp = inTemp
    data.inHum = inHum
    data.inPress = inPress
    
    print(data.inTemp .. ", " .. data.inHum .. ", " .. data.inPress)
    if (config.HAS_DISPLAY) then
      display.render(data)
    else
      reportToDomoticz()
    end
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

i2c.setup(0, config.SDA_PIN, config.SCL_PIN, i2c.SLOW)
if (config.HAS_DISPLAY) then
  display.init(config.OLED_ADDR)
end
sensor.init()

-- delay 5 seconds to wait for sensor
tmr.alarm(0, 5*1000, tmr.ALARM_SINGLE, function()
  getIn()
  if (config.HAS_DISPLAY) then
    getOut()
  end
end)


tmr.alarm(1, 1*60*1000, tmr.ALARM_AUTO, getIn) -- 1*60*1000 = every 1 minutes
if (config.HAS_DISPLAY) then
  tmr.alarm(2, 5*60*1000, tmr.ALARM_AUTO, getOut) -- 1*60*1000 = every 5 minutes
end

print("all set")
