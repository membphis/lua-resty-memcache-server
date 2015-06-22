local tb    = require "resty.iresty_test"
local memcached = require "resty.memcached"
local test = tb.new({unit_name="memcache server"})    

function tb:init(  )
    self:log("init complete")
    local memc, err = memcached:new()
    if not memc then
        error("failed to instantiate memc: " .. err)
        return
    end

    self.memc = memc
    self.host = "127.0.0.1"
    self.port = 8000
end

function tb:memc_connect( )
    self.memc:set_timeout(1000) -- 1 sec
    local ok, err = self.memc:connect(self.host, self.port)
    if not ok then
        error("failed to connect: " .. err)
    end
end

function tb:test_001_flush_all(  )
    self:memc_connect() 

    local ok, err = self.memc:flush_all()
    if not ok then
        error("failed to flush all: " .. err)
    end
end

function tb:test_002_set(  )
    self:memc_connect()

    local ok, err = self.memc:set("dog", 32)
    if not ok then
        error("failed to set dog: " .. err)
        return
    end
end

function tb:test_003_get(  )
    self:memc_connect()

    local res, flags, err = self.memc:get("dog")
    if err then
        error("failed to get dog: " .. err)
    end
    if not res then
        error("dog not found")
    end
end

function tb:test_004_delete(  )
    self:memc_connect()

    local ok, err = self.memc:delete("dog")
    if not ok then
        error("failed to delete dog: " .. err)
    end
end

function tb:test_005_version(  )
    self:memc_connect()

    local ok, err = self.memc:version()
    if not ok then
        error("failed to get version: " .. err)
    end
end

test:run()

