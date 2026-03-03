-- ChatGPT wrote my unit tests

local yoshi = dofile'yoshi.lua'
local tests = {}

----------------------------------------------------------------
-- Minimal assert functions
----------------------------------------------------------------

local function fail(msg)
  error("TEST FAILED: " .. msg, 2)
end

local function assertEqual(a, b, msg)
  if a ~= b then fail(msg or string.format("%s ~= %s", tostring(a), tostring(b))) end
end

local function assertNotEqual(a, b, msg)
  if a == b then fail(msg or string.format("%s == %s", tostring(a), tostring(b))) end
end

local function assertDeepEqual(a, b, msg)
  local function compare(x, y)
    if type(x) ~= type(y) then return false end
    if type(x) ~= "table" then return x == y end
    local k_checked = {}
    for k,v in pairs(x) do
      if not compare(v, y[k]) then return false end
      k_checked[k] = true
    end
    for k,_ in pairs(y) do
      if not k_checked[k] then return false end
    end
    return true
  end
  if not compare(a,b) then fail(msg or "Tables not equal") end
end

----------------------------------------------------------------
-- Helpers
----------------------------------------------------------------

-- reset hosts between tests
local function resetHosts()
  yoshi.hosts = {}
end

----------------------------------------------------------------
-- Tests
----------------------------------------------------------------

function tests.test_constructor()
  local cmd = yoshi.ssh{
    HostName = "localhost",
    User = "me",
    Port = 2222,
    SessionType = "none",
    DynamicForward = 8080,
    LocalForward = 8000,
    RemoteCommand = "ls -la",
  }

  assertEqual(cmd.HostName, "localhost")
  assertEqual(cmd.User, "me")
  assertEqual(cmd.Port, 2222)
  assertEqual(cmd.SessionType, "none")
  assertEqual(cmd.DynamicForward, 8080)
  assertDeepEqual(cmd.LocalForward, {8000,8000})
  assertEqual(cmd.RemoteCommand, "ls -la")
end

function tests.test_proxyjump()
  resetHosts()

  yoshi.hosts["bastion"] = function()
    return yoshi.ssh{HostName="bastion.internal", User="bastionuser"}
  end

  local cmd = yoshi.ssh{
    HostName = "server.internal",
    User = "admin",
    ProxyJump = "bastion",
  }

  assertEqual(#cmd.ProxyJumps, 1)
  assertEqual(cmd.ProxyJumps[1].host, "bastion.internal")
  assertEqual(cmd.ProxyJumps[1].user, "bastionuser")
end

function tests.test_nested_proxyjump()
  resetHosts()
  yoshi.hosts["jump1"] = function()
    return yoshi.ssh{HostName="jump1.host", ProxyJump="jump2"}
  end
  yoshi.hosts["jump2"] = function()
    return yoshi.ssh{HostName="jump2.host", User="jumpuser"}
  end

  local cmd = yoshi.ssh{
    HostName = "target.host",
    ProxyJump = "jump1"
  }

  local hops = cmd.ProxyJumps
  assertEqual(#hops, 2)
  assertEqual(hops[1].host, "jump2.host")
  assertEqual(hops[1].user, "jumpuser")
  assertEqual(hops[2].host, "jump1.host")
end

function tests.test_cli_hop_override()
  resetHosts()
  yoshi.hosts["ganymede"] = function() return yoshi.ssh{HostName="192.168.50.2"} end
  yoshi.hosts["io"] = function() return yoshi.ssh{HostName="192.168.50.3", ProxyJump="ganymede"} end

  local arg = {"collin@ganymede/io"}
  local target = yoshi.getHost("io")
  local path = {"collin@ganymede"}  -- simulate split_path(arg[1])

  local acc = {}
  for i = 1, #path do
    local hop = yoshi.parse_user_host_port(path[i])
    yoshi.collect_proxy_jumps(hop, acc)
  end

  target.ProxyJumps = acc
  assertEqual(#target.ProxyJumps, 1)
  assertEqual(target.ProxyJumps[1].user, "collin")
  assertEqual(target.ProxyJumps[1].host, "192.168.50.2")
end

function tests.test_toCommand()
  resetHosts()
  local cmd = yoshi.ssh{
    HostName = "localhost",
    User = "me",
    Port = 2222,
    DynamicForward = 8080,
    LocalForward = 8000,
    SessionType = "none",
    RemoteCommand = "ls"
  }

  local text = cmd:toCommand()
  assert(text:match("ssh"))
  assert(text:match("-D 8080"))
  assert(text:match("-L 8000:127.0.0.1:8000"))
  assert(text:match("-N"))
  assert(text:match("me@localhost"))
  assert(text:match("ls"))
end

function tests.test_LocalForward_tuple()
  local cmd = yoshi.ssh{
    HostName="localhost",
    LocalForward={9000,9001}
  }
  local text = cmd:toCommand()
  assert(text:match("-L 9000:127.0.0.1:9001"))
end

function tests.test_DynamicForward()
  local cmd = yoshi.ssh{
    HostName="localhost",
    DynamicForward=9999
  }
  local text = cmd:toCommand()
  assert(text:match("-D 9999"))
end

function tests.test_RemoteCommand()
  local cmd = yoshi.ssh{HostName="localhost", RemoteCommand="echo hello"}
  local text = cmd:toCommand()
  assert(text:match("echo hello"))
end

----------------------------------------------------------------
-- Run tests
----------------------------------------------------------------

local function main()
  tests.test_constructor()
  tests.test_proxyjump()
  tests.test_nested_proxyjump()
  tests.test_cli_hop_override()
  tests.test_toCommand()
  tests.test_LocalForward_tuple()
  tests.test_DynamicForward()
  tests.test_RemoteCommand  ()
end
