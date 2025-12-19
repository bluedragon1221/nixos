{pkgs, ...}: {
  files.".config/util.lua" = {
    text = let
      lua = pkgs.lua.withPackages (p: [p.lua-subprocess]);
    in
      # lua
      ''
        #!${lua}/bin/lua
        local subprocess = require("subprocess")

        local function get_volume()
          local proc, err = subprocess.popen({
            "wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@",
            stdout = subprocess.PIPE,
            stderr = subprocess.PIPE
          })
          if not proc then
            error("Failed to run wpctl get-volume: " .. tostring(err))
          end

          local out = proc.stdout:read("*a") or ""
          local _, _, code = proc:wait()
          if (code or 0) ~= 0 then
            local errout = proc.stderr and proc.stderr:read("*a") or ""
            error(("wpctl get-volume failed (code %d): %s"):format(code, errout))
          end

          local num = out:match("^Volume:%s*([%d%.]+)")
          if not num then
            error("Unexpected wpctl output: " .. out)
          end

          return tonumber(num) * 100
        end

        local function notify_volume()
          local ok, reason, code = subprocess.call({
            "dunstify", "-t", "300",
            "-h", "string:x-canonical-private-synchronous:audio",
            "Volume:", "-h", "int:value:"..get_volume()
          })
          if not ok then
            io.stderr:write(("dunstify failed (%s, code %s)\n"):format(reason or "?", code or "?"))
          end
        end

        local function set_volume(vol)
          local ok, reason, code = subprocess.call({
            "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", vol
          })
          if not ok then
            io.stderr:write(("wpctl set-volume failed (%s, code %s)\n"):format(reason or "?", code or "?"))
          end
        end

        local function get_brightness()
          local proc = subprocess.popen({
            "${pkgs.brightnessctl}/bin/brightnessctl", "-e", "get",
            stdout = subprocess.PIPE
          })
          if not proc then error("Failed to run brightnessctl get") end
          local cur = tonumber(proc.stdout:read("*a"))
          proc:wait()
          if not cur then error("Failed to parse brightnessctl get output") end

          local proc2 = subprocess.popen({
            "${pkgs.brightnessctl}/bin/brightnessctl", "-e", "max",
            stdout = subprocess.PIPE
          })
          if not proc2 then error("Failed to run brightnessctl max") end
          local max = tonumber(proc2.stdout:read("*a"))
          proc2:wait()
          if not max or max == 0 then error("Failed to parse brightnessctl max output") end

          return (cur / max) * 100
        end

        local function notify_brightness()
          local ok, reason, code = subprocess.call({
            "dunstify", "-t", "300",
            "-h", "string:x-canonical-private-synchronous:brightness",
            "Brightness", "-h", "int:value:"..get_brightness()
          })
          if not ok then
            io.stderr:write(("dunstify failed (%s, code %s)\n"):format(reason or "?", code or "?"))
          end
        end

        local function set_brightness(brightness)
          local ok, reason, code = subprocess.call({
            "${pkgs.brightnessctl}/bin/brightnessctl", "-e", "set", brightness
          })
          if not ok then
            io.stderr:write(("brightnessctl set failed (%s, code %s)\n"):format(reason or "?", code or "?"))
          end
        end

        local function list_music_players()
          local proc = subprocess.popen({
            "${pkgs.playerctl}/bin/playerctl", "-l",
            stdout = subprocess.PIPE
          })
          if not proc then error("Failed to run playerctl -l") end

          local cur = proc.stdout:lines()

          local out = {}
          for i in cur do
            table.insert(out, i)
          end

          return out
        end

        local function toggle_music()
          local ok, reason, code = subprocess.call({
            "${pkgs.playerctl}/bin/playerctl", "play-pause",
          })
          if not ok then
            io.stderr:write(("playerctl play-pause failed (%s, code %s)\n"):format(reason or "?", code or "?"))
          end
        end

        -- main logic
        if arg[2] and arg[2]:match("^(%d+)%%([%+%-])$") then
          if arg[1] == "vol" then
            set_volume(arg[2])
            notify_volume()
          elseif arg[1] == "brightness" then
            set_brightness(arg[2])
            notify_brightness()
          else
            error(("arg[2] '%s' incorrect format. Should look like 5%%+ or 10%%-"):format(tostring(arg[2])))
          end
        elseif arg[1] and arg[1] == "music" then
          if arg[2] == "play" then
            toggle_music()
          else
            error(("Invalid arg[2]: '%s'. should be `play`"):format(arg[3]))
          end
        else
          error("Unknown command: " .. tostring(arg[1]))
        end
      '';
    executable = true;
  };
}
