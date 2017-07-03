local domoticz = {}

domoticz.updateSensorTempHum = function(apiURL, user, pass, deviceId, data)
  
  local auth_code = crypto.toBase64(user .. ":" .. pass)
  
  http.get(apiURL .. "?type=command&param=udevice&idx=" .. deviceId .. 
    "&nvalue=0&svalue=" .. data.inTemp .. ";" .. data.inHum .. ";0" .. data.inPress .. ";0",
    
    "Authorization: Basic " .. auth_code .. "\r\n",
    
    function(code, data)
      if (code < 0) then
        print("HTTP request failed")
      else
        print(code, data)
      end
    end
  )
  
end


domoticz.getSensorTempHumBaro = function(apiURL, user, pass, deviceId, callback)
  
  weather = {}
  mt = {}
  t = {metatable = mt}
  mt.__newindex = function(table, key, value)
    if 
    (key == "Temp") or 
    (key == "Humidity") or 
    (key == "ForecastStr")
    then
        rawset(weather, key, value)
    end
  end
  
  obj = sjson.decoder(t)
  
  local auth_code = crypto.toBase64(user .. ":" .. pass)
  
  http.get(apiURL .. "?type=devices&rid=" .. deviceId,
    
    "Authorization: Basic " .. auth_code .. "\r\n",
    
    function(code, data)
      if (code < 0) then
        print("http request failed")
        callback()
      else
        obj:write(data)
        for k, v in pairs(weather) do
          print(k, v)
        end 
        data = nil
        collectgarbage()
        callback(weather.Temp, weather.Humidity, weather.ForecastStr)    
      end 
    end
  )
  
end

return domoticz
