require("string")

-- Setup
-- Don't load config yet, because the user can't let go
-- of the lever until the electromagnet has been energized
gpio.mode(3, gpio.OUTPUT) -- Connect LED
gpio.mode(4, gpio.OUTPUT) -- Electromagnet
gpio.write(3, gpio.LOW)
gpio.write(4, gpio.HIGH)

-- Timeout
tmr.alarm(0, 60000, 0, function()
    gpio.write(4, gpio.LOW)
end)

require("config")

-- Wi-Fi connect
wifi.setmode(wifi.STATION)
wifi.sta.config(IOTOASTER_SSID, IOTOASTER_PW)

-- Get toast time
connected = false
conn = net.createConnection(net.TCP, false)

conn:on("receive", function(conn, c)
    print "receiving..."
    print("received string " .. c)
    local time, time_str
    result, _, time_str=string.find(c, "TOAST TIME: (%d+).")
    print(time_str)

    if result == nil then
        return
    end
    
    time = tonumber(time_str)

    gpio.write(3, gpio.HIGH)
    print(time)
    tmr.stop(0)
    tmr.alarm(0, time, 0, function()
        gpio.write(4, gpio.LOW)
    end)

    connected = true
end)

conn:on("connection", function(conn)
    print "sending..."
    conn:send("GET " .. IOTOASTER_PATH .. " HTTP/1.1\r\n" ..
              "Host: " .. IOTOASTER_HOST .. "\r\n" ..
              "Connection: close" .. "\r\n" ..
              "\r\n")
end)

tmr.alarm(1, 1000, 1, function() 
    if wifi.sta.getip()=="0.0.0.0" then
        print("Connect AP, Waiting...") 
    elseif connected == false then
        print("Connecting...")
        conn:connect(IOTOASTER_PORT, IOTOASTER_HOST)
    else
        print("Done")
        tmr.stop(1)
    end
end)
