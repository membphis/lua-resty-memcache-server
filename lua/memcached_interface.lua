local _M = { _VERSION = '1.0' }
local lru_store = require "lru_store"

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
   lru_store.set(command[2], value, tonumber(command[4]))
   return "STORED" .. "\r\n"
end

function _M.get( command )
   local value = lru_store.get(command[2])
   if value then
      return "VALUE "..command[2].." 0 ".. #value .. "\r\n" .. value .. "\r\n" .. "END" .. "\r\n"
   else
      return "END" .. "\r\n" 
   end
end

function _M.flush_all( command )
   lru_store.flush_all()
   return "OK" .. "\r\n"
end

function _M.subtract(self, params )
	if "table" ~= type(params) then
		return nil, "param check failed"
	end

	if 2 == #params then
		return params[1]-params[2]
	end

	return nil, "param input valid"
end

return _M
