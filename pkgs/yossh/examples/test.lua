yoshi = dofile'yoshi.lua'

yoshi.hosts["you"] = function()
  return yoshi.ssh{
    HostName = "192.168.50.2",
    DynamicForward = 7320,
    Port = 27
  }
end

yoshi.hosts["me"] = function()
  return yoshi.ssh{
    HostName = "test.local",
    ProxyJump = "jumper@you"
  }
end

yoshi.run(arg, {dry_run = true})
