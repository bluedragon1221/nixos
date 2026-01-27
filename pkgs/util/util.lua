#!@lua@/bin/lua
local lsdbus = require("lsdbus")

local music = dofile"@out@/lib/util/music.lua"
local brightness = dofile"@out@/lib/util/brightness.lua"
local volume = dofile"@out@/lib/util/volume.lua"

local b = lsdbus.open()
local s = lsdbus.open("system")

if arg[1] == "music" then
  if arg[2] == "toggle" then
    music.toggle_play(b)
  elseif arg[2] == "next" then
    music.next_song(b)
  elseif arg[2] == "prev" then
    music.prev_song(b)
  end
elseif arg[1] == "brightness" then
  if arg[2] == "up" then
    brightness.brightness_up(s)
  elseif arg[2] == "down" then
    brightness.brightness_down(s)
  else
    error(("arg[2] '%s' incorrect format. Should be `up` or `down`"):format(tostring(arg[2])))
  end
elseif arg[1] == "volume" then
  if arg[2] == "up" then
    volume.volume_up()
  elseif arg[2] == "down" then
    volume.volume_down()
  else
    error(("arg[2] '%s' incorrect format. Should be `up` or `down`"):format(tostring(arg[2])))
  end
end
