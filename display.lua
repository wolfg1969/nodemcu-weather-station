local display = {}

local disp


display.init = function(oledAddr)
    disp = u8g.ssd1306_128x64_i2c(oledAddr)
end


function draw(data)
    local y = 0
    -- font options are font_10x20r,font_6x10,font_9x18r,font_helvR18r,font_helvR24
    -- create a new build with more options at http://frightanic.com/nodemcu-custom-build/

    y = y+10
    disp:setFont(u8g.font_9x18r)
    disp:drawStr(0, y, "In:")
    disp:drawStr(70, y, "Out:")
    
    y = y+30
    disp:setFont(u8g.font_helvR24)
    
    disp:drawStr(0, y, string.sub(data.inTemp, 1,-3)) 
    disp:setFont(u8g.font_6x10)
    disp:drawStr(36, y, string.sub(data.inTemp, -2)) 
    disp:setFont(u8g.font_helvR24)
    disp:drawStr(48, y, string.char(0xb0)) -- degree symbol
    
    disp:drawStr(72, y, data.outTemp .. string.char(0xb0))

    y = y+14
    disp:setFont(u8g.font_6x10)
    disp:drawStr(0, y, data.inPress .. " mbar")
    disp:drawStr(72, y, data.outCond)
    y = y+10
    disp:drawStr(0, y, data.inHum .. "% hum")
    disp:drawStr(72, y, data.outHum .. "% hum")
end


display.render = function(data)
    disp:firstPage()
    repeat
        draw(data)
    until disp:nextPage() == false
end


return display
