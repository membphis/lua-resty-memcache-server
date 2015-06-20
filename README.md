# lua-resty-memcached-server
================
That is a memcached server base on openresty(with nginx-tcp-lua-server patch). Its only support the set/get operation now.


Use exmaple(memcache protocal)
================
Syntax:

```
--> set key1 0 0 3
--> val
<-- STORED
--> get key1
<-- VALUE key1 0 3
<-- val
<-- END
<-- 
```


Add your interface
================
please take a look with lua/memcached_interface.lua, you can add new operation as the "set/get" in same way

```
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

```

The nginx config
================

```
http {
    # set search paths for pure Lua external libraries (';;' is the default path):
    lua_package_path '$prefix/lua/?.lua;;';

    lua_socket_log_errors off;
    lua_code_cache off;

    server {
        listen       8000;
        server_name  localhost;
        default_head "GET /entry HTTP/1.1\r\nHost: 127.0.0.1\r\n\r\n";

        location /entry {
            lua_check_client_abort on;
            access_by_lua_file lua/entrypoint.lua;
        }
    }

}
```

Pay attention
================
It base on openresty, but you need to make a patch with the original openresty. please take a look at nginx-tcp-lua-server . its the most simple way to get the nginx tcp server. 

provide by membphis@gmail.com

if you have any question, please let me know. 
