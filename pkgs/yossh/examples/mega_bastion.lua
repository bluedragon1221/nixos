-- situation: fictional network where there are three departments:
--   - tech (172.16.10.0/24)
--   - HR (172.16.20.0/24)
--   - Secretary (172.16.40.0/24)
-- Each department has
--   - an ssh bastion server at .1:22 (only way to access other devices on the subnet from outside the subnet)
--   - a shared sftp server at .2:25
-- 
-- This exact yoshi script would be deployed to all personal computers inside the network.
local yoshi = dofile"yoshi.lua"

local function inNetwork()
  -- company internal landing page
  local _, _, code = os.execute("nc -z -w1 172.16.0.1 443")
  return code == 0
end

local function currDept()
  local ip_addr = io.popen("hostname -I")
  local _, _, third_octet, _ = string.gmatch(ip_addr, "%d%.%d%.%d%.%d")

  return third_octet
end

local depts = {
  tech = 10,
  hr = 20,
  secretary = 40
}

yoshi.hosts["global-bastion"] = yoshi.ssh{
  HostName = "bastion.company-website.com",
  Port = 2222
}

for name, subnet in pairs(depts) do
  yoshi.hosts[name.."-bastion"] = function()
    return yoshi.ssh{
      HostName = "172.16."..subnet..".1",
      ProxyJump = inNetwork() or "global-bastion"
    }
  end

  yoshi.hosts[name.."-fileserver"] = function()
    return yoshi.ssh{
      HostName = "172.16."..subnet..".2",
      SessionType = "none",
      LocalForward = {2225, 25},
      ProxyJump = inNetwork() and currDept() == subnet or name.."-bastion"
    }
  end
end

yoshi.hosts[name.."-db"] = yoshi.ssh{
  HostName = "172.16.10.3",
  SessionType = "none",
  LocalForward = 5432,
  ProxyJump = inNetwork() and currDept() == subnet or "tech-bastion"
}

yoshi.run(arg, {dry_run = true})
