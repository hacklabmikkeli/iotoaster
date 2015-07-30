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

require("config")

-- Wi-Fi connect
wifi.setmode(wifi.STATION)
wifi.sta.config(IOTOASTER_SSID, IOTOASTER_PW, 0)
wifi.sta.connect()

-- Get toast time
sock = net.createConnection(net.TCP, false)
sock:on("connection", function (sock)
    sock:send(
        "GET " .. IOTOASTER_PATH .. " HTTP/1.1\r\n" ..
        "\r\n" ..
        "\r\n")
end)
sock:on("receive", function(sock, c)
    local time, time_str
    _, _, time_str= string.find("(%d+)$")
    time = tonumber(time_str) - tmr.now()
    if time < 0 then time = 0 end

    gpio.write(3, gpio.HIGH)
    tmr.alarm(0, time, function()
        gpio.write(4, gpio.LOW)
    end)
end)
sock:connect(IOTOASTER_PORT, IOTOASTER_HOST)
