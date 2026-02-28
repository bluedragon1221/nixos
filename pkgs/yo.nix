{pkgs, ...}: let
  yo = pkgs.writeText "yo.lua" ''
    local CONF_FILE = os.getenv("HOME") .. "/.config/yo.conf"

    local conf = {}
    for l in io.open(CONF_FILE):lines() do
      if l:match("^(%a+)%s") then
        local k, v = l:match("^(%a+)%s+(.*)$")
        conf[k] = v
      end
    end

    local SUDO = "sudo"
    if conf.sudo then
      SUDO = conf.sudo
    elseif os.getenv("SUDO") then
      SUDO = os.getenv("SUDO")
    end

    local TARGET = "/home/collin/nixos"

    local function getHostname()
      local f = io.popen("hostname")
      local h = f:read("*l")
      f:close()
      return h
    end

    local function buildConfiguration(args)
      local flake_path = args.flakePath
      local hostname = args.hostname
      local extra_args = table.concat(args.extraArgs or {}, " ")
      local build_cmd = ('nix build %s#nixosConfigurations."%s".config.system.build.toplevel --log-format internal-json %s |& ${pkgs.nix-output-monitor}/bin/nom --json'):format(flake_path, hostname, extra_args)
      print("+ "..build_cmd)
      os.execute(build_cmd)
    end

    local function switchToConfiguration(verb)
      local proc_store_path = io.popen(("readlink -f %s/result"):format(TARGET))
      local store_path = proc_store_path:read("*l")
      proc_store_path:close()

      -- create generation
      local create_gen_cmd = ("nix build --no-link --profile %s %s"):format("/nix/var/nix/profiles/system", store_path)

      local verb_cmd = ("%s/result/bin/switch-to-configuration %s"):format(TARGET, verb)

      local sudo_verb_cmd = ("%s ${pkgs.bashNonInteractive}/bin/bash -c '%s; %s'"):format(SUDO, create_gen_cmd, verb_cmd)
      print("+ "..sudo_verb_cmd)
      os.execute(sudo_verb_cmd)
    end

    local function deployConfiguration(args)
      local flake_path = args.flakePath
      cmd = ("nix run github:serokell/deploy-rs %s -- --skip-checks -- --log-format internal-json |& ${pkgs.nix-output-monitor}/bin/nom --json"):format(flake_path)
      print("+ "..cmd)
      os.execute(cmd)
    end

    if arg[1] == "deploy" or arg[1] == "dep" or arg[1] == "d" then
      deployConfiguration{
        flakePath = TARGET
      }
    elseif arg[1] == "switch" or arg[1] == "sw" then
      buildConfiguration{
        flakePath = TARGET,
        hostname = getHostname()
      }
      switchToConfiguration("switch")
    elseif arg[1] == "boot" then
      buildConfiguration {
        flakePath = TARGET,
        hostname = getHostname()
      }
      switchToConfiguration("boot")
    elseif arg[1] == "test" then
      buildConfiguration {
        flakePath = TARGET,
        hostname = getHostname()
      }
      switchToConfiguration("test")
    elseif arg[1] == "build" then
      local hostname = arg[2] or getHostname()
      buildConfiguration {
        flakePath = TARGET,
        hostname = hostname
      }
    end
  '';
in
  pkgs.writeShellScriptBin "yo" ''
    exec ${pkgs.lua}/bin/lua ${yo} "$@"
  ''
