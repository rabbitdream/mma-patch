local cjson = require("cjson")
local http = require("resty.http")
ngx.req.read_body()
local args, err = ngx.req.get_uri_args()
local text = ngx.var.request_body
local data = cjson.decode(text)
local httpc = http.new()
local body_data
if data["parms"] ~= nil then
    body_data = data["parms"]
else
    body_data = ""
end
local res, err = httpc:request_uri(
    data["url"],
    {
            method = data["type"],
            body = body_data,
            ssl_verify = false
    }
)
if err ~= nil and not res then
    ngx.status = 403
    ngx.say(ngx.ERR, err)
    ngx.exit(403)
    return
end
if 200 ~= res.status then
    ngx.exit(res.status)
end
ngx.say()