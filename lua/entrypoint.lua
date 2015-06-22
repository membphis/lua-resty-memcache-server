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

while not ngx.worker.exiting() do
	ngx.log(ngx.WARN, "once")
	local line, err = tcpsock:receive("*l")
	if err and "timeout" ~= err then
		ngx.log(ngx.WARN, "receive failed:", err)
		break
	end

	local command = memcached.split(line, " ")
	if #command < 1 then
		break
	end
	local req_data= nil

	local name = string.lower(command[1])
	if "set" == name or "add" == name or "replace" == name then
		req_data, err = tcpsock:receive(tonumber(command[5])+2)
		if err then
			ngx.log(ngx.WARN, "receive value failed:", err)
			break
		end

		if "\r\n" ~= req_data:sub(-2, -1) then
			ngx.log(ngx.WARN, "receive last is not \\r\\n")
			break
		end
	end

	local rep_data, err = memcached.call(name, command, req_data and req_data:sub(1, -3))
	if err then
		ngx.log(ngx.WARN, "call the function failed: ", err)
		break
	end
	tcpsock:send(rep_data)
end

cleanup()