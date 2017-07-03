local weather_sensor = {}

local BME280_installed = true
local using_BME280 = false

function readDHT11(dhtPin, callback)
  status, temp, humidity, temp_decimial, humi_decimial = dht.read11(dhtPin)
  if (status == dht.OK) then
    callback(temp, humidity)
  end
end


weather_sensor.init = function()
  result = bme280.setup()  -- 2 if sensor is BME280, 1 if sensor is BMP280
  if (result == nil) then
    BME280_installed = false
  elseif (result == 2) then
    using_BME280 = true
  end
end


weather_sensor.read = function(dhtPin, alt, callback)
  
  local inTemp = "?"
  local inHum = "?"
  local inPress = "?"
  
  if (not BME280_installed) then
    
    readDHT11(dhtPin, function(temp, humidity)
      inTemp = temp
      inHum = humidity
    end)
    
  else
    
    T, P, H, QNH = bme280.read(alt)
    
    local Tsgn = (T < 0 and -1 or 1) 
    T = Tsgn*T
    
    inTemp = string.format("%s%d.%.1d", Tsgn<0 and "-" or "", T/100, T%100)
    
    if (using_BME280) then
      inHum = string.format("%d.%.1d%%", H/1000, H%1000)
    else  -- BMP280 has no humidity data
      readDHT11(dhtPin, function(temp, humidity)
        inHum = humidity
      end)
    end
    
    inPress = string.format("%d.%.1d", QNH/1000, QNH%1000)
  end
  
  print(string.format("T=%s, H=%s, QNH=%s", inTemp, inHum, inPress))
  
  callback(inTemp, inHum, inPress)
  
end


return weather_sensor
