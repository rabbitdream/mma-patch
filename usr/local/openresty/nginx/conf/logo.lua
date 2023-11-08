local json = require("cjson")                                                                      
local args, err = ngx.req.get_uri_args()
if err ~= nil then
	ngx.say(ngx.ERR,err)
	ngx.exit(403)
	return
end
local enable = args["enable"]
local file = io.open("/opt/tvu/R/iMatrix/vision.json", "r")
local content = file:read("*a")
file:close()
local data = json.decode(content)
if enable == "1" then
	data.enable_logodet = true
else
    data.enable_logodet = false
end
local modifiedContent = json.encode(data)
local modifiedFile = io.open("/opt/tvu/R/iMatrix/vision.json", "w")
modifiedFile:write(modifiedContent)
modifiedFile:close()
ngx.say()
