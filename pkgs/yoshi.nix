{
  pkgs,
  inputs,
  ...
}: let
  yossh =
    pkgs.writeText "yossh.lua"
    # lua
    ''
      yoshi = dofile'${inputs.yoshi-lua}/yoshi.lua'

      local function isHome()
        local _, _, code = os.execute("nc -z -w1 192.168.50.2 2222")
        return code == 0
      end

      yoshi.hosts["ganymede"] = function()
        if isHome() then
          return yoshi.ssh{
            HostName = "192.168.50.2",
            Port = 2222
          }
        else
          return yoshi.ssh{
            HostName = "williamsfam.us.com",
            DynamicForward = 9090
          }
        end
      end

      yoshi.hosts["io"] = function()
        if isHome() then
          return yoshi.ssh{
            HostName = "192.168.50.3",
            User = "admin",
          }
        else
          return yoshi.ssh{
            HostName = "192.168.50.3",
            User = "admin",
            ProxyJump = "collin@ganymede",
          }
        end
      end

      yoshi.run(arg)
    '';
in
  pkgs.writeShellScriptBin "yossh" ''
    exec ${pkgs.lua}/bin/lua ${yossh} "$@"
  ''
