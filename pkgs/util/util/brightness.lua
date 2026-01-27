local lsdbus = require("lsdbus")

local function get_brightness()
  local proc = io.open("/sys/class/backlight/intel_backlight/brightness")
  local cur_brightness = tonumber(proc:read("*l"))
  return cur_brightness
end

local function get_max_brightness()
  local proc = io.open("/sys/class/backlight/intel_backlight/max_brightness")
  local max_brightness = tonumber(proc:read("*l"))
  return max_brightness
end

local function notify_brightness()
  local brightness_percent = math.floor((get_brightness() / get_max_brightness()) * 100)
  os.execute(string.format(
    "dunstify -t 2000 -h string:x-canonical-private-synchronous:brightness 'Brightness' -h int:value:%d",
    brightness_percent
  ))
end

local M = {}

function set_brightness(s, brightness)
  local brightness_proxy = lsdbus.proxy.new(s, 'org.freedesktop.login1', '/org/freedesktop/login1/session/1', "org.freedesktop.login1.Session")
  brightness_proxy("SetBrightness", "backlight", "intel_backlight", brightness)
end

function M.brightness_down(s, brightness)
  set_brightness(s, get_brightness() - 5*(get_max_brightness() / 100))
  notify_brightness()
end

function M.brightness_up(s, brightness)
  set_brightness(s, get_brightness() + 5*(get_max_brightness() / 100))
  notify_brightness()
end

return M
