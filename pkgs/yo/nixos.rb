module Nix
  def build_configuration(flake_path:, hostname:)
    flake_target = "#{flake_path}#nixosConfigurations.'#{hostname}'.config.system.build.toplevel"
    `nix build --no-link --print-out-paths #{flake_target}`.chomp.tap do
      raise "Build command failed" unless $?.success?
    end
  end

  def switch_to_configuration(store_path:, verb:, sudo_cmd: "sudo")
    create_gen_cmd = "nix build --no-link --profile /nix/var/nix/profiles/system #{store_path}"
    switch_cmd = "#{store_path}/bin/switch-to-configuration #{verb}"
    system("#{sudo_cmd} bash -c '#{create_gen_cmd}; #{switch_cmd}'") or raise "Switch command failed"
  end

  def switch_to_configuration_remote(store_path:, ssh_host:, use_magic_rollback: false)
    system("nix copy --to ssh://#{ssh_host} #{store_path}") or raise "Copy closure command failed"

    create_gen_cmd = "nix build --no-link --profile /nix/var/nix/profiles/system #{store_path}"
    switch_cmd = "#{store_path}/bin/switch-to-configuration switch"

    if use_magic_rollback
      test_cmd = "#{store_path}/bin/switch-to-configuration test"
      system(%[ssh #{ssh_host} 'bash -c "#{test_cmd}; shutdown -r +5"']) or raise "Remote test command failed"

      puts <<~MSG
        Remote deployment complete.
        If everything works, press ENTER to confirm and cancel rollback.
        If SSH dies, it will restart (reversing changes) automatically in 5 minutes
      MSG
      $stdin.gets

      system(%[ssh #{ssh_host} 'bash -c "shutdown -c; #{create_gen_cmd}; #{switch_cmd}"']) or raise "Remote switch command failed"
    else
      system(%[ssh #{ssh_host} 'bash -c "#{create_gen_cmd}; #{switch_cmd}"']) or raise "Remote switch command failed"
    end
  end
end
