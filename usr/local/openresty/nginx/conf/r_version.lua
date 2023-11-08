local f = io.open('/opt/tvu/R/iMatrix/patchversion.txt', 'rb')
local content = f:read("*all")
f:close()
chunks = {}
for substring in content:gmatch("%S+") do
   table.insert(chunks, substring)
end
local patch = 'unkonw'
if (table.getn(chunks) == 3)
then
	s_patch = chunks[3]
	if tonumber(s_patch) ~= nil
	then
		patch = s_patch
	end
end
local track_s = 'unkonw'
track2_info = io.popen("docker ps | grep tvutrack2 | wc -l")
lines = tonumber(track2_info:read("*line"))
-- check tvutrack2 exists, if exists, get the version
if  lines > 0 then
	track_f = assert(io.popen("docker exec tvutrack2 cat /home/tvu/mediamind_track/tvutrack2/version.txt |  sed '1!d'"))
	track_s_t = assert (track_f:read('*line'))
	if string.len(track_s_t) > 0
	then
		track_s = track_s_t
	end
	track_f:close()
else
	-- if exists, set the default value
	track_s = ""
end

local r_s = 'unkonw'
r_f = assert(io.popen("cat /opt/tvu/R/productversion"))
r_s_t = assert(r_f:read('*a'))
if string.len(r_s_t) > 0
then
	r_s = r_s_t
end
r_f:close()
-- ngx.print(track_s)
ngx.print('{"patch_version":"'..patch..'", "track_version":"'..track_s.. '","r_version":"'..r_s..'","port_aggregate":"true","port_aggregate_web":443}')
