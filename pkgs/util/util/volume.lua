local function get_volume()
  local handle = io.popen("wpctl get-volume @DEFAULT_AUDIO_SINK@")
  local out = handle:read("*a")
  handle:close()
  
  local num = out:match("^Volume:%s*([%d%.]+)")
  if not num then
    error("Unexpected wpctl output: " .. out)
  end
  
  return tonumber(num) * 100
end

local function notify_volume()
  os.execute(string.format(
    "dunstify -t 2000 -h string:x-canonical-private-synchronous:audio 'Volume' -h int:value:%d",
    math.floor(get_volume())
  ))
end

local M = {}

function M.set_volume(vol)
  os.execute(string.format("wpctl set-volume @DEFAULT_AUDIO_SINK@ %.2f", vol / 100))
  notify_volume()
end

function M.volume_up(step)
  step = step or 5
  local current = get_volume()
  local new_volume = math.min(150, current + step)
  M.set_volume(new_volume)
end

function M.volume_down(step)
  step = step or 5
  local current = get_volume()
  local new_volume = math.max(0, current - step)
  M.set_volume(new_volume)
end

function M.toggle_mute()
  os.execute("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
  notify_volume()
end

return M
