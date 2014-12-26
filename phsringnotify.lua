#!/usr/bin/lua
require "nixio"

ircserver = arg[1]
botnick = arg[2]
channel = arg[3]
targetnick = arg[4]
if targetnick == nil then
  print("Usage: lua phsringnotify.lua <ircserver> <botnick> <channel> <targetnick>")
  print("   ex: lua phsringnotify.lua 10.254.166.45 '[PHSdeto]' '#projA' deton")
  os.exit(1)
end
privmsg = "PRIVMSG " .. channel .. " :@" .. targetnick .. " RING"

threshold = 100
deadtime = 20 -- [sec]
prevOn = 0

-- http://wiki.linino.org/doku.php?id=wiki:lininoio_sysfs
f = assert(io.open("/sys/bus/iio/devices/iio:device0/enable", "w"))
f:write("1\n")
f:close()

sock = nixio.socket("inet", "stream")
sock:connect(ircserver, 6667)
sock:write("USER a b c d\r\nNICK " .. botnick .. "\r\nJOIN " .. channel .. "\r\n")
sock:setblocking(false)

while true do
  nixio.nanosleep(0, 600000000) -- 600ms

  local f = assert(io.open("/sys/bus/iio/devices/iio:device0/in_voltage_A5_raw", "r"))
  local v = f:read("*number")
  f:close()

  io.write(v, " ")
  io.flush()
  if v > threshold then
    local now = os.time()
    local diff = os.difftime(now, prevOn)
    if diff >= deadtime then
      print("PRIVMSG")
      sock:write(privmsg .. " (" .. v .. ")\r\n")
      prevOn = now
    end
  end
  
  local ircmsg = sock:read(513)
  if ircmsg and string.find("" .. ircmsg, "PING ") then
    sock:write("PONG dummy\r\n")
  end
end
