# openresty-traceid
在现今微服务多应用架构体系中，如何做到请求链路中端，服务之间调用可追踪，能迅速定位问题？这正是openresty-traceid项目所解决的问题。

openresty：是一个基于 Nginx 与 Lua 的高性能 Web 平台，其内部集成了大量精良的 Lua 库、第三方模块以及大多数的依赖项。用于方便地搭建能够处理超高并发、扩展性极高的动态 Web 应用、Web 服务和动态网关。

## 链路追踪如何实现
基于openresty编辑Lua脚本，在nginx请求接入时，生成唯一的请求ID。

## 算法
主机名 + 进程id + 毫秒时间戳 + 时间戳随机数 = 唯一ID

## Docker构建
cd openresty-traceid && docker build -t openresty-traceid .

docker run -p 80:80 openresty-traceid

如需要挂载自己的配置或者日志，请在docker run的时候加上-v 

## 日志格式
2f30a611f0119c263600e698a4e40359 - 172.17.0.1 - - [05/Jun/2018:06:40:45 +0000] "GET / HTTP/1.1" 200 1524 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36" "-"

## 代码
~~~
local hostname = ngx.var.hostname
local headers = ngx.req.get_headers()
local workerid = ngx.worker.id()
    if not headers["traceid"] then
        math.randomseed(tonumber(tostring(ngx.now()*1000):reverse():sub(1,9)))
        local randvar = string.format("%.0f",math.random(1000000000000000000,99223372036854775807))
        local onlyString = tostring(hostname .. workerid .. ngx.now()*1000 .. randvar)
        local traceid = ngx.md5(onlyString)
        ngx.req.set_header("traceid", traceid)
    else
        ngx.log(ngx.ERR, "worker-id:", workerid)
    end
~~~
