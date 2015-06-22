local _M = { _VERSION = '1.0' }
-- alternatively: local lrucache = require "resty.lrucache.pureffi"
local lrucache = require "resty.lrucache"

-- we need to initialize the cache on the lua module level so that
-- it can be shared by all the requests served by each nginx worker process:
local c = nil  -- allow up to 200 items in the cache

local function lur_init(  )
   if c then
      return 
   end
   
   c = lrucache.new(20000)  -- allow up to 200 items in the cache
   if not c then
       return error("failed to create the cache: " .. (err or "unknown"))
   end
end
lur_init()

function _M.call(fun_name, command, value )
	if nil == _M[fun_name] then
		return nil, "valid function name("..fun_name.. ")"
	end

	return _M[fun_name](command, value)
end

function _M.split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function _M.set( command, value )
   local expire = tonumber(command[4])
   if 0 == expire then
      expire = nil
   end
   c:set(command[2], value, expire)
   return "STORED" .. "\r\n"
end

function _M.get( command )
   local value = c:get(command[2])
   if value then
      return "VALUE "..command[2].." 0 ".. #value .. "\r\n" .. value .. "\r\n" .. "END" .. "\r\n"
   else
      return "END" .. "\r\n" 
   end
end

function _M.flush_all( command )
   c = nil
   lur_init()
   return "OK" .. "\r\n"
end

function _M.delete( command )
   if 2 ~= #command then
      return "END" .. "\r\n"
   end

   c:delete(command[2])
   return "DELETED" .. "\r\n"
end

function _M.version( command )
   return "VERSION 1.0(base on openresty)".."\r\n"
end

return _M
