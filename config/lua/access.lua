local hostname = ngx.var.hostname
local headers = ngx.req.get_headers()
local workerid = ngx.worker.id()
    if not headers["traceid"] then
        math.randomseed(tonumber(tostring(ngx.now()*1000):reverse():sub(1,9)))
        local randvar = string.format("%.0f",math.random(1000000000000000000,99223372036854775807))
        local onlyString = tostring(hostname .. workerid .. ngx.now()*1000 .. randvar)
        local traceid = ngx.md5(onlyString)
        ngx.req.set_header("traceid", traceid)
    end
