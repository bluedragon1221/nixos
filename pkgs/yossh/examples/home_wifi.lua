#!/bin/sh
yoshi = dofile'yoshi.lua'

local function isHome()
  local ok, reason, code = os.execute("nc -z -w1 192.168.50.2 2222")
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
      DynamicForward = 9090
    }
  end
end

yoshi.hosts["io"] = function()
  return yoshi.ssh{
    HostName = "192.168.50.3",
    User = "admin",
    ProxyJump = isHome() or "collin@ganymede",
  }
end

yoshi.run(arg, {dry_run = true})
