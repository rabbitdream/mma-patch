--ngx.say("<p>hllo</p>")
--ngx.say(ngx.var.finshpath)
--
--ngx.var.fmp4abspath
--ngx.var.mp4abspath
--ngx.var.finshpath
--
--/opt/tvu/R/ExEncoder30/TVU264.exe -logfile log/fmp4tomp4.log -i /data/www/5552458542000000168EFDF2E43_4D7446C8141EE167_1557110113779_c7227dcd-8236-4c0d-8c4a-3a7b049ce4a2_1.mp4 -c copy -f mp4 -movflags faststart -y /tmp/test.mp4
local lfs = require "lfs"
local mp4filename = ngx.unescape_uri(ngx.var.arg_mp4)
local mp4path = ngx.var.indexpath..ngx.var.mp4disk..mp4filename
ngx.header['Access-Control-Allow-Origin'] = "*"

a,b,c = string.find(mp4filename, '/')
if(a == 1)
then
	mp4filename = string.sub(mp4filename, 4, -1)
end

a,b,c = string.find(mp4filename, '/')
if(a ~= nil)
then
	local dir = string.sub(mp4filename, 1, a)
	file, err = io.open(ngx.var.indexpath..ngx.var.mp4disk..dir)
	if(err ~= nil)
	then
		cmd = "mkdir -p "..ngx.var.indexpath..ngx.var.mp4disk..dir
		ngx.log(ngx.DEBUG, "syscmd :", cmd)
		os.execute(cmd)
	end

	file, err = io.open(ngx.var.indexpath..ngx.var.memdisk..dir)
	if(err ~= nil)
	then
		cmd = "mkdir -p "..ngx.var.indexpath..ngx.var.memdisk..dir
		ngx.log(ngx.DEBUG, "syscmd :", cmd)
		os.execute(cmd)
	end
end
file,err = io.open(mp4path)
if(err == nil)
then
        ngx.say("http://"..ngx.var.server_addr..":"..ngx.var.server_port.."/mp4rec/"..ngx.var.mp4disk..mp4filename)
        ngx.exit(200)
end
local fmp4path = ngx.var.fmp4indexpath..mp4filename
file,err = io.open(fmp4path)
if(err ~= nil)
then
        ngx.exit(500)
end
local finpath = ngx.var.fmp4indexpath..mp4filename..".finish"
ngx.log(ngx.DEBUG, "fin file path :", finpath)
local change = lfs.attributes(fmp4path)["change"]
file, err = io.open(finpath)
local move = false
if(err == nil or change + 86400 <= os.time())
then
        move = true
end
local cmd = "cd /opt/tvu/R; /opt/tvu/R/ExEncoder30/TVU264.exe -logfile /opt/tvu/R/log/fmp4tomp4.log -i "..fmp4path.." -c copy -f mp4 -movflags faststart -y "..ngx.var.indexpath..ngx.var.memdisk..mp4filename
ngx.log(ngx.DEBUG, "tvu264cmd :", cmd)
os.execute(cmd)
ngx.log(ngx.DEBUG, "move :", move)
ngx.say("http://"..ngx.var.server_addr..":"..ngx.var.server_port.."/mp4rec/"..ngx.var.memdisk..mp4filename)
if(move)
then
        os.execute("mv -f "..ngx.var.indexpath..ngx.var.memdisk..mp4filename.." "..ngx.var.indexpath..ngx.var.mp4disk..mp4filename)
        move = false
end


--local change = lfs.attributes(path)["change"]
--ngx.say(change)
--if(change + 86400 <= os.time())
--then
--        ngx.say(ngx.var.mp4abspath..mp4filename.."is new")
--        --tvu264 wtire in momery
--else
--        ngx.say(ngx.var.mp4abspath..mp4filename.."is up")
--end
--
