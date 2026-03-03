# Lua Documentation
Lua API documentation for Yoshi

## `yoshi.hosts`
- Description: List of defined ssh hosts. Each entry must be a function that returns an `sshCommand` when called.
- Type: table of `function(): sshCommand`
- Example:
```lua
yoshi.hosts["webserver"] = function()
  -- this is just a random example to show why you might want yoshi.hosts[host] to be a function
  if os.getenv("IM_FEELING") == "sad" then
    return yoshi.ssh{HostName = "sad.webserver.local"}
  else
    return yoshi.ssh{HostName = "happy.webserver.local"}
  end
end
```

## `yoshi.ssh`
- Description: Constructs an `sshCommand`
- Type: `function(table): sshCommand`
- Example:
```lua
yoshi.ssh{
  HostName = "webserver.local",
  Port = 2227,
  ProxyJump = "bastion"
}
```

## `yoshi.sshCommand.User`
- Description: Specifies the target user in the ssh connection. Analogous to the `User` key in `ssh_config`
- Type: string or nil
- Example: `yoshi`, `collin123`

## `yoshi.sshCommand.HostName`
- Description: Specifies the target host in the ssh connection. The only required element to `yoshi.sshCommand`. Analogous to the `HostName` key in `ssh_config`
- Type: string
- Example: `192.168.0.27`, `github.com`, `140.82.114.3`

## `yoshi.sshCommand.Port`
- Description: Specifies the target port in the ssh connection. Defaults to `22` if unspecified. Analagous to the `Port` key in `ssh_config`
- Type: integer, `0 <= i <= 65535`
- Examples: `22`, `2222`, `2225`

## `yoshi.sshCommand.RemoteCommand`
- Description: Specifies a command to run on the target host instead of the default shell. Analagous to the `RemoteCommand` key in `ssh_config`
- Type: string
- Examples: `whoami`, `nixos-rebuild switch --flake /etc/nixos`, `tmux new-session -A`

## `yoshi.sshCommand.SessionType`
- Description: Specifies the type of ssh session. "none" means that no shell access is provded. Analogous to the `SessionType` key in `ssh_config`
- Type: "subsystem", "none", or "default"
- Examples: `"none"`

## `yoshi.sshCommand.LocalForward`
- Description: Specifies a port on the target host to forward to the local host in the format `{local_port, target_port}`. If no local port is specified, will assume host port and local port are the same. Analagous to the `LocalForward` key in `ssh_config` or the `-L` flag on the command line
- Type: `table[2] of integer` or integer, `0 <= i <= 65535`
- Examples: `8010`, `{8010, 80}`

## `yoshi.sshCommand.DynamicForward`
- Description: Specifies a port on the local host to serve as a SOCKS5 proxy, forwarding all traffic through the target host. Analagous to the `DynamicForward` key in `ssh_config` or the `-D` option on the command line
- Type: integer, `0 <= i <= 65535`
- Examples: `9090`

## `yoshi.sshCommand.ProxyJump`
- Description: Specifies a host to act as a gateway to the target host if not directly accessable by the local host. It will inherit `User`, `Port`, and `HostName` options from `yoshi.hosts[host]` if it exists. Analagous to the `ProxyJump` key in `ssh_config` or the `-J` flag on the command line
- Type: string in the form `user@host:port`
- Example: `box`, `yoshi@box`, `box:27`, `yoshi@box:27`
- Full Example:
```lua
yoshi.hosts["bastion"] = sshCommand.ssh{
  HostName = "bastion.mywebsite.com",
  Port = 23,
}

yoshi.hosts["server"] = sshCommand.ssh{
  HostName = "192.168.0.2",
  ProxyJump = "myuser@bastion"
}

assert_eq(
  yoshi.getHost("server"):toCommand(),
  "ssh -J myuser@bastion.mywebsite.com:23 server"
)
```

## `yoshi.sshCommand:toCommand`
- Description: Formats `self` as a valid `ssh` command to be run in the terminal.
- Type: `sshCommand:function(): string`
- Example:
```lua
os.execute(yoshi.getHost("io"):toCommand())
```

## `yoshi.getHost`
- Description: Looks up and evaluates `yoshi.hosts[hostname]`, returning the resulting `sshCommand`. Raises an error if the host is not found or the host function returns nil.
- Type: `function(string): sshCommand`
- Example:
```lua
yoshi.hosts["webserver"] = function()
  return yoshi.ssh{
    HostName = "webserver.local",
    Port = 22,
    ProxyJump = "bastion"
  }
end

os.execute(yoshi.getHost("webserver"):toCommand())
```

## `yoshi.run`
- Description: Executes the ssh command associated with the given target host as provided by `arg`, a list of commandline arguments. If no arguments are provided, prints a help page. The first argument is a path of the form `[jumphost/.../]host`, where any leading path segments are used as explicit proxy jump hops. Subsequent arguments may include ssh flags such as `-D`, `-L`, `-N`, or `-- command`.
- Type: `function(table of string, table of any)`
- Example:
```lua
yoshi.run(arg, {dry_run = true}) -- arg is the global name for the lua program's commandline arguments
```
