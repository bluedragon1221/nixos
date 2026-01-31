{pkgs, ...}: let
  yo = pkgs.writeText "yo.lua" ''
    local SUDO = os.getenv("SUDO") or "sudo"

    local function collectArgs(start)
      local start = start or 2

      local flags = {}
      if arg[start] ~= nil then
        for i = start, #arg do
          table.insert(flags, arg[i])
        end
      end
      return flags
    end

    local function nixosRebuild(args)
      local sudo = (args.sudo or false) == true
      local verb = args.verb or "switch"
      local flake = args.flake or "/home/collin/nixos"
      local extraArgs = table.concat(args.extraArgs or {}, " ")

      cmd = ("nixos-rebuild %s --flake %s %s --log-format internal-json |& ${pkgs.nix-output-monitor}/bin/nom --json"):format(verb, flake, extraArgs)
      if sudo then
        local sudo_cmd = ("%s su -c '%s'"):format(SUDO, cmd)
        print("+ "..sudo_cmd)
        os.execute(sudo_cmd)
      else
        print("+ "..cmd)
        os.execute(cmd)
      end
    end

    if arg[1] == "deploy" or arg[1] == "dep" or arg[1] == "d" then
      local deploy_args = {}
      local nix_args = {}

      local found_dashes = false
      if arg[2] ~= nil then
        for i = 2, #arg do
          if arg[i] == "--" then
            found_dashes = true
          elseif found_dashes then
            table.insert(nix_args, arg[i])
          else
            table.insert(deploy_args, arg[i])
          end
        end
      end

      cmd = ("nix run github:serokell/deploy-rs -- --skip-checks %s -- --log-format internal-json %s |& ${pkgs.nix-output-monitor}/bin/nom --json"):format(table.concat(deploy_args, " "), table.concat(nix_args, " "))
      print("+ "..cmd)
      os.execute(cmd)
    elseif arg[1] == "switch" or arg[1] == "sw" or arg[1] == "s" then
      local target = "/home/collin/nixos"
      if arg[2] ~= nil and arg[2]:match("#") then
        target = arg[2]
      end

      nixosRebuild{
        sudo = true,
        verb = "switch",
        flake = target,
        extraArgs = collectArgs(3)
      }
    elseif arg[1] == "boot" or arg[1] == "bo" then
      nixosRebuild{sudo = true, verb = "boot", extraArgs = collectArgs()}
    elseif arg[1] == "test" or arg[1] == "t" then
      nixosRebuild{sudo = true, verb = "test", extraArgs = collectArgs()}
    elseif arg[1] == "build" or arg[1] == "bu" then
      local target = "/home/collin/nixos"
      if arg[2] ~= nil and arg[2]:match("#") then
        target = arg[2]
      end

      nixosRebuild{verb = "build", flake = target, extraArgs = collectArgs(3)}
    end
  '';
in
  pkgs.writeShellScriptBin "yo" ''
    exec ${pkgs.lua}/bin/lua ${yo} "$@"
  ''
