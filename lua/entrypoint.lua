local cjson 	= require "cjson"
local memcached = require "memcached_interface"

local tcpsock, err = ngx.req.socket(true)
if err then
	ngx.log(ngx.ERR, "ngx.req.socket:", err)
	ngx.exit(0)
end

local function cleanup()
    ngx.log(ngx.WARN, "do cleanup")
    ngx.exit(0)
end

local ok, err = ngx.on_abort(cleanup)
if not ok then
    ngx.log(ngx.ERR, "failed to register the on_abort callback: ", err)
    ngx.exit(0)
end

while true do
	ngx.log(ngx.WARN, "once")
	local line, err = tcpsock:receive("*l")
	if err and "timeout" ~= err then
		ngx.log(ngx.WARN, "receive failed:", err)
		break
	end

	local command = memcached.split(line, " ")
	if #command < 2 then
		break
	end
	local req_data= nil

	local name = command[1] 
	if "set" == name or "add" == name or "replace" == name then
		req_data, err = tcpsock:receive(tonumber(command[5]))
		if not err then
			tcpsock:receive(2)
		end
	end

	local rep_data = memcached.call(command[1], command, req_data)
	tcpsock:send(rep_data)
end

cleanup()