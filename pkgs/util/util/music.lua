local lsdbus = require("lsdbus")

function list_players(b)
  local dbus = lsdbus.proxy.new(b,
    'org.freedesktop.DBus',
    '/org/freedesktop/DBus',
    'org.freedesktop.DBus'
  )
  local all_services = dbus("ListNames")

  local players = {}
  for _, name in ipairs(all_services) do
    if name:match("^org.mpris.MediaPlayer2") then
      table.insert(players, name)
    end
  end
  return players
end

local function get_player_proxy(b, player)
  local ok, res = pcall(function() return lsdbus.proxy.new(b,
    player,
    '/org/mpris/MediaPlayer2',
    'org.mpris.MediaPlayer2.Player'
  ) end)
  if ok then
    return res
  end
end

local function list_playing_players(b)
  local playing = {}
  for _, player in ipairs(list_players(b)) do
    local proxy = get_player_proxy(b, player)
    if proxy and proxy.PlaybackStatus == "Playing" then
      -- print(player)
      table.insert(playing, player)
    end
  end
  return playing
end

local function solo_player(b, player)
  for _, i in list_playing_players(b) do
    if i ~= player then
      get_player_proxy(b, player)"Pause"
    end
  end
end

local STATE_FILE = os.getenv("HOME") .. "/.local/state/music_player_paused"
local function write_state(state_file, player)
  local f, _ = io.open(state_file, "w")
  f:write(player.."\n")
  f:close()
end

local function read_state(state_file)
  local f, _ = io.open(state_file, "r")
  local read = f:read("*l")
  f:close()
  return read
end

local M = {}

local function notify_music(b, player)
  local player_proxy = lsdbus.proxy.new(b, player, '/org/mpris/MediaPlayer2', 'org.mpris.MediaPlayer2.Player')
  local meta = player_proxy.Metadata

  os.execute(string.format(
    "dunstify -t 2000 -h string:x-canonical-private-synchronous:music -i '%s' '%s' '%s' -h int:value:%d",
    meta["mpris:artUrl"] or "",
    player_proxy.PlaybackStatus .. " " .. meta["xesam:title"] or "",
    "by " .. meta["xesam:artist"][1],
    math.floor(player_proxy.Position / meta["mpris:length"])
  ))
end

function M.toggle_play(b)
  local current_playing = list_playing_players(b)
  local state = read_state(STATE_FILE)

  if #current_playing == 0 and state ~= "" then
    local p = get_player_proxy(b, state)
    if p then
      p("Play")
      notify_music(b, state)
    end
    return
  end

  if #current_playing == 1 then
    local c = current_playing[1]
    write_state(STATE_FILE, c)
    get_player_proxy(b, c)("Pause")
    notify_music(b, c)
    return
  end

  if #current_playing > 1 then
    for _, player in ipairs(current_playing) do
      get_player_proxy(b, player)"Pause"
    end
  end
end

function M.next_song(b)
  local currently_playing = list_playing_players(b)
  if #currently_playing ~= 0 then
    local player_proxy = lsdbus.proxy.new(b, currently_playing[1], '/org/mpris/MediaPlayer2', 'org.mpris.MediaPlayer2.Player')
    player_proxy("Next")
  end
end

function M.prev_song(b)
  local currently_playing = list_playing_players(b)
  if #currently_playing ~= 0 then
    local player_proxy = lsdbus.proxy.new(b, currently_playing[1], '/org/mpris/MediaPlayer2', 'org.mpris.MediaPlayer2.Player')
    player_proxy("Previous")
  end
end

return M
