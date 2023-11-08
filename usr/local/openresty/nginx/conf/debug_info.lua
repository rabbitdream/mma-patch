local lfs = require "lfs"
ngx.header['Access-Control-Allow-Origin'] = "*"
proto = "http://"
if ngx.var.httpsenable == "true" then
    proto = "https://"
end
for entry in lfs.dir(ngx.var.img_path) do
	if entry ~='.' and entry ~='..' then
		local url = proto..ngx.var.server_addr..":"..ngx.var.server_port..ngx.var.img_location.."/debug/"..entry
		ngx.say(url)	
	end
end
