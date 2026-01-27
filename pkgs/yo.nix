{pkgs, ...}: let
  yo = pkgs.writeText "yo.lua" ''
    local verb

    local flags = {}
    if arg[2] ~= nil then
      for a = 2, #arg do
        table.insert(flags, a)
      end
    end

    if arg[1] == "deploy" or arg[1] == "dep" or arg[1] == "d" then
      cmd = ("${pkgs.deploy-rs}/bin/deploy-rs --skip-checks %s -- --log-format internal-json |& ${pkgs.nix-output-monitor}/bin/nom --json"):format(table.concat(flags, " "))
      print("+ "..cmd)
      os.execute(cmd)
    elseif arg[1] == "switch" or arg[1] == "sw" or arg[1] == "s" then
      verb = "switch"
    elseif arg[1] == "boot" or arg[1] == "b" then
      verb = "boot"
    elseif arg[1] == "test" or arg[1] == "t" then
      verb = "test"
    end

    if verb then
      cmd = ("run0 sh -c 'nixos-rebuild %s --flake /home/collin/nixos %s --log-format internal-json |& ${pkgs.nix-output-monitor}/bin/nom --json'"):format(verb, table.concat(flags, " "))
      print("+ "..cmd)
      os.execute(cmd)
    end
  '';
in
  pkgs.writeShellScriptBin "yo" ''
    exec ${pkgs.lua}/bin/lua ${yo} "$@"
  ''
