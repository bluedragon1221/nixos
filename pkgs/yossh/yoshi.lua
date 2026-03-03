local SSHTarget = {}

function SSHTarget:clone()
   return {
      user = self.user,
      host = self.host,
      port = self.port
   }
end

local function parse_user_host_port(input)
   local user, rest = input:match("^(.-)@(.*)$")
   if not rest then rest = input end

   local host, port_str = rest:match("^(.-):(%d+)$")
   local port
   if not host then
      host = rest
   else
      port = tonumber(port_str)
   end

   return {
      user = user,
      host = host,
      port = port,
   }
end

local function split_path(path)
   local t = {}
   for seg in path:gmatch("[^/]+") do
      table.insert(t, seg)
   end
   return t
end

local yoshi = {
   hosts = {}
}

local SSHConfig = {}
local SSHCommand = {}

function SSHCommand:clone()
   local new_proxy_jumps
   if self.proxy_jumps then
      new_proxy_jumps = {}
      for _, j in ipairs(self.proxy_jumps) do
         table.insert(new_proxy_jumps, {
            user = j.user,
            host = j.host,
            port = j.port,
         })
      end
   end

   return setmetatable({
      target = {
         user = self.target.user,
         host = self.target.host,
         port = self.target.port,
      },
      session_type = self.session_type,
      dynamic_forward = self.dynamic_forward,
      local_forward = self.local_forward and { self.local_forward[1], self.local_forward[2] } or nil,
      remote_command = self.remote_command,
      proxy_jumps = new_proxy_jumps,
   }, { __index = SSHCommand })
end

function SSHCommand:overlayTarget(target)
   local new = self:clone()
   if target.user then
      new.target.user = target.user
   end

   if target.port then
      new.target.port = target.port
   end

   return new
end

function yoshi.getHost(hostname)
   local base = yoshi.hosts[hostname]
   if not base then
      error("Unknown host: " .. hostname)
   end

   local cmd = base()
   if cmd then
      return cmd
   else
      error("Calling host returned nil")
   end
end

function yoshi.ssh(o)
   local local_forward
   local l = o.LocalForward
   if type(l) == "number" then
      local_forward = { l, l }
   else
      local_forward = l
   end

   local proxy_jumps = {}
   if o.ProxyJump then
      local u = parse_user_host_port(o.ProxyJump)
      local jmp = yoshi.getHost(u.host):overlayTarget(u)

      table.insert(proxy_jumps, jmp.target)
      if #jmp.proxy_jumps ~= 0 then
         for _, p in ipairs(jmp.proxy_jumps) do
            table.insert(proxy_jumps, p)
         end
      end
   end

   local self = setmetatable({
      target = {
         user = o.User,
         host = o.HostName,
         port = o.Port or 22,
      },
      session_type = o.SessionType or "default",
      dynamic_forward = o.DynamicForward,
      local_forward = local_forward,
      remote_command = o.RemoteCommand,

      proxy_jumps = proxy_jumps,
   }, { __index = SSHCommand })

   return self
end

function SSHCommand:toCommand()
   local ret = { "ssh" }

   if self.dynamic_forward then
      table.insert(ret, "-D")
      table.insert(ret, tostring(self.dynamic_forward))
   end

   if self.local_forward then
      table.insert(ret, "-L")
      local lf = self.local_forward
      table.insert(ret,
      lf[1] .. ":127.0.0.1:" .. lf[2])

   end

   if self.session_type == "none" then
      table.insert(ret, "-N")
   end

   if self.proxy_jumps and #self.proxy_jumps > 0 then
      local js = {}
      for _, j in ipairs(self.proxy_jumps) do
         local s = (j.user and j.user .. "@" or "") .. j.host
         if j.port and j.port ~= 22 then s = s .. ":" .. j.port end
         table.insert(js, s)
      end
      table.insert(ret, "-J")
      table.insert(ret, table.concat(js, ","))
   end

   if self.target.port and self.target.port ~= 22 then
      table.insert(ret, "-p")
      table.insert(ret, tostring(self.target.port))
   end

   table.insert(ret, (self.target.user and self.target.user .. "@" or "") .. self.target.host)

   if self.remote_command then
      table.insert(ret, "-t")
      table.insert(ret, "'" .. self.remote_command .. "'")
   end

   return table.concat(ret, " ")
end

function SSHCommand:overlayCliOpts(cli_args)
   local new = self:clone()

   local i = 2
   while i <= #cli_args do
      local a = cli_args[i]

      if a == "-D" then
         new.dynamic_forward = tonumber(cli_args[i + 1])
         i = i + 2

      elseif a == "-L" then
         local spec = cli_args[i + 1]

         local port = tonumber(spec)
         if port then
            new.local_forward = { port, port }
            i = i + 2

         else
            local l, r = spec:match("^(%d+):.*:(%d+)$")
            if not l or not r then
               error("Invalid -L spec: " .. spec)
            end
            new.local_forward = { tonumber(l), tonumber(r) }
            i = i + 2
         end

      elseif a == "-N" then
         new.session_type = "none"
         i = i + 1

      elseif a == "--" then
         local parts = {}
         for j = i + 1, #cli_args do
            table.insert(parts, cli_args[j])
         end
         new.remote_command = table.concat(parts, " ")
         break

      else
         error("Unknown or unsupported ssh option: " .. a)
      end
   end

   return new
end

local function show_help()
   print("Usage: ssh <[jumphost/...]host> [options] [-- command]")
   print("\nAvailable hosts:")
   for h, _ in pairs(yoshi.hosts) do
      print("  - " .. h)
   end
end

function yoshi.run(cli_opts, opts)
   if not cli_opts then
      error("Please pass `arg` to yoshi.run (ex. `yoshi.run(arg)`)")
   end

   if cli_opts[1] == nil then
      show_help()
      os.exit(0)
   end

   local path = split_path(cli_opts[1])
   local destName = path[#path]

   local target = yoshi.getHost(destName)

   local acc = {}
   if #path > 1 then
      for i = 1, #path - 1 do
         local hop = parse_user_host_port(path[i])
         table.insert(acc, {
            user = hop.user,
            host = hop.host,
            port = hop.port,
         })
      end
      target.proxy_jumps = acc
   end

   local cmd = target:overlayCliOpts(cli_opts)
   print("+ " .. cmd:toCommand())

   if not opts or not opts.dry_run then
      os.execute(cmd)
   end
end

return yoshi
