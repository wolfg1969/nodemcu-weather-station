local weather_sensor = {}

local BME280_installed = true
local using_BME280 = false

function readDHT(dhtPin, callback)
  status, temp, humidity, temp_decimial, humi_decimial = dht.read(dhtPin)
  print("dht read status=" .. status .. ", temp=" .. temp .. ", hum=" .. humidity)
  if (status == dht.OK) then
    callback(temp, humidity)
  end
end


weather_sensor.init = function()
  result = bme280.setup()  -- 2 if sensor is BME280, 1 if sensor is BMP280
  print(result)
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
    
    readDHT(dhtPin, function(temp, humidity)
      if (temp <= 100) then
        inTemp = temp
      else
        inTemp = temp / 25.6
      end
      if (humidity <= 100) then
        inHum = humidity
      else
        inHum = humidity / 25.6
      end
      callback(inTemp, inHum, inPress)
    end)
    
  else
    
    T, P, H, QNH = bme280.read(alt)
    
    local Tsgn = 1
    if (T < 0) then
      Tsgn = -1
    end 
    T = Tsgn*T
    
    inTemp = string.format("%s%d.%.1d", Tsgn<0 and "-" or "", T/100, T%100)
    inPress = string.format("%d.%.1d", QNH/1000, QNH%1000)
    
    if (using_BME280) then
      inHum = string.format("%d.%.1d", H/1000, H%1000)
      callback(inTemp, inHum, inPress)
    else  -- BMP280 has no humidity data
      readDHT(dhtPin, function(temp, humidity)
        if (humidity <= 100) then
          inHum = humidity
        else
          inHum = humidity / 25.6
        end
        callback(inTemp, inHum, inPress)
      end)
    end
    
  end
    
end


return weather_sensor
