require "nixio"

deadtime = 10 -- [sec]
prevOn = 0

-- http://wiki.linino.org/doku.php?id=wiki:lininoio_sysfs
f = assert(io.open("/sys/bus/iio/devices/iio:device0/enable", "w"))
f:write("1\n")
f:close()

-- f = assert(io.open("/sys/bus/iio/devices/iio:device0/in_voltage_A4_scale", "r"))
-- scale = f:read("*number")
-- f:close()

sock = nixio.socket("inet", "stream")
sock:connect("192.168.137.147", 6667)
sock:write("USER a b c d\r\nNICK detonPHS\r\n")
sock:setblocking(false)

while true do
  nixio.nanosleep(0, 100000000) -- 100ms

  f = assert(io.open("/sys/bus/iio/devices/iio:device0/in_voltage_A4_raw", "r"))
  v = f:read("*number")
  f:close()

  print(v)
  if v < 770 then
    now = os.time()
    diff = os.difftime(now, prevOn)
    if diff >= deadtime then
      print("PRIVMSG")
      sock:write("PRIVMSG deton :@deton RING (" .. v .. ")\r\n")
      prevOn = now
    end
  end
  
  ircmsg = sock:read(513)
  if ircmsg and string.find("" .. ircmsg, "PING ") then
    sock:write("PONG dummy")
  end
end

