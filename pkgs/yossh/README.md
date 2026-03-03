# Yo SSH Host Initiator (Y.O.S.H.I)
Yoshi is a lua library that wraps the `ssh` client, allowing you to define complex host configurations using the power of a full programming langage (lua) instead of the `ssh_config` dsl.

Obligatory code example (`~/bin/yossh`):
```lua
#!/usr/bin/env lua
yoshi = require'yoshi'

local function isHome()
  local _, _, code = os.execute("nc -z -w1 192.168.50.2 2222")
  return code == 0
end

yoshi.hosts["ganymede"] = function()
  if isHome() then
    return yoshi.ssh{
      HostName = "192.168.50.2",
      Port = 2222,
      LocalForward = 8010
    }
  else
    return yoshi.ssh{
      HostName = "williamsfam.us.com",
      LocalForward = 8010,
      DynamicFoward = 9090
    }
  end
end

yoshi.hosts["io"] = function()
  if isHome() then
    return yoshi.ssh{HostName = "192.168.50.3"}
  else
    return yoshi.ssh{
      HostName = "192.168.50.3",
      User = "admin",
      ProxyJump = "collin@ganymede",
    }
  end
end

yoshi.run(arg)
```

```
$ yossh io
Connection to 192.168.50.2 2222 port [tcp/ethernet-ip-1] succeeded!
+ ssh admin@192.168.50.3
io:~$ 
```

## 🍄 Getting Started
First, clone this repo, and make sure you have ssh and lua installed.
```
sudo apt install ssh luajit5.4 # or whatever
git clone https://github.com/bluedragon1221/yoshi
```

Next, place `yoshi.lua` in a place that lua can find it.
Consult the [lua documentation](https://www.lua.org/pil/8.1.html) for help.

Now you can write a simple configuration.
As an example, let's look at the equivelant of this `ssh_config` block:
```
Host box
  HostName 192.168.50.3
  User yoshi
```

Using Yoshi, it would look like this:
```lua
-- yoshi_cfg.lua
yoshi = require'yoshi'

yoshi.hosts["box"] = yoshi.ssh{
  HostName = "192.168.50.3",
  User = "yoshi"
}

yoshi.run(arg)
```

> (To create more complicated configurations, read the [docs](./doc/lua_doc.md))

To test your Yoshi configuration, you can run `lua yoshi_cfg.lua`.
This would be annoying to type every time you need to access your remote server, though!
So we'll place the script in the `$PATH` (ex. `~/bin/yossh` or something), and use a shabang to tell the script to execute with lua:
```lua
#!/usr/bin/env lua
yoshi = require'yoshi'

yoshi.hosts["box"] = yoshi.ssh{
  HostName = "192.168.50.3",
  User = "yoshi"
}

yoshi.run(arg)
```

Assuming `~/bin` is in the `$PATH` and you made `yossh` executable with `chmod +x`, running `yossh` in the terminal will give you a nice help page:
```bash
$ yossh
yossh - smart SSH wrapper

USAGE:
  yossh <host>
  yossh <user@host>
  yossh <host:port>
  yossh <user@host:port>

AVAILABLE HOSTS:
  - box
```

And you can ssh into `box`:
```bash
$ yossh box
+ ssh yoshi@192.168.50.3
io:~$ whoami
yoshi
```

## 📖 Docs
- [`doc/lua_doc.md`](doc/lua_doc.md) contains comprehensive docs for the Yoshi lua api
- [`doc/nix.md`](doc/nix.md) discusses packaging your Yoshi configuration with nix

---

[![BrainMade](https://brainmade.org/88x31-dark.png)](https://brainmade.org)
