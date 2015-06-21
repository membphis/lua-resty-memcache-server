local _M = {}

-- alternatively: local lrucache = require "resty.lrucache.pureffi"
local lrucache = require "resty.lrucache"

-- we need to initialize the cache on the lua module level so that
-- it can be shared by all the requests served by each nginx worker process:
local c = nil  -- allow up to 200 items in the cache

local function lur_init(  )
	c = lrucache.new(20000)  -- allow up to 200 items in the cache
	if not c then
	    return error("failed to create the cache: " .. (err or "unknown"))
	end
end
lur_init()

function _M.set(key, value, expire)
	if 0 == expire then
		expire = nil
	end
    c:set(key, value, expire)
end

function _M.get(key)
    return c:get(key)
end

function _M.flush_all(  )
	c = nil
	lur_init()
end

return _M