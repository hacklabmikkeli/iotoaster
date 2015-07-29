-- Setup
-- Don't load config yet, because the user can't let go
-- of the lever until the electromagnet has been energized
gpio.mode(3, gpio.OUTPUT) -- Connect LED
gpio.mode(4, gpio.OUTPUT) -- Electromagnet
gpio.write(3, gpio.LOW)
gpio.write(4, gpio.HIGH)

-- Timeout
tmr.alarm(0, 60000, function()
    gpio.write(4, gpio.LOW)
end)

require("config.lua")

-- Wi-Fi connect
wifi.setmode(wifi.STATION)
wifi.sta.config(IOTOASTER_SSID, IOTOASTER_PW)
gpio.write(3, gpio.HIGH)
