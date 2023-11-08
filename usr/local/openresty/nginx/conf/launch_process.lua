require("videoapi")
local cjson =require("cjson")
ngx.log(ngx.NOTICE,".................enter20181101,client_ip=",ngx.var.remote_addr,"client_port=",ngx.var.remote_port," testport=",ngx.var.forwardport)
-- ngx.log(ngx.NOTICE,"cpath=",package.cpath)
ngx.var.forwardport = ngx.var.remote_port+10
-- local Flv_forwardport = ngx.var.forwardport
-- local Tvu264_forwardport = ngx.var.forwardport + 1


function getPid(uri)
	local beginindex,endindex =string.find(uri,"/meta")
	return string.sub(uri,2,beginindex-1)
end


function mysplit(inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			t[i] = str
			i = i + 1
	end
	return t
end

local ClientUri = ngx.var.uri
local Pid = getPid(ClientUri)
ngx.log(ngx.NOTICE,"pid="..Pid.." uri="..ClientUri)


jsonstr =""
local confilePath ="conf/videoconf.json"
local fp = io.open(confilePath, "r")
if nil == fp then
	ngx.log(ngx.ERR,"the video conf file is not exit,path="..confilePath)
	return -1
end
for line in fp:lines() do
	jsonstr = jsonstr..line
end
fp:close()
ngx.log(ngx.NOTICE,"jsonstr=",jsonstr)

local jsoncf = cjson.decode(jsonstr)
local FilePrefix = jsoncf[Pid].video_directory
local flvPath =jsoncf[Pid].flv_path
local tvu264Path = jsoncf[Pid].video_codec_path
local tvu264Args = jsoncf[Pid].codec_arg



-- local FilePrefix = "D:\\video"
-- local flvPath ="C:\\TVUTransporterR\\FlvGoLive.exe"
-- local tvu264Path = "C:\\TVUTransporterR\\ExEncoder30\\TVU264.exe"
-- local tvu264Args = " -re -ss {tvu264_time} -i \"{tvu264_file}\" -map 0:v:0 -map 0:a:0 -s 640x360 -sws_flags fast_bilinear -vcodec h264_qsv -preset veryfast -profile:v baseline -level 3.0 -async_depth 1 -b:v 600K -maxrate 20000K -look_ahead 0 -g 30 -strict -2 -acodec aac -ab 64K -ar 44100 -ac 2 -send_head 1 -vsync -1 -f flv tvuhttp://0.0.0.0:{tvu264_port}"

-- local FilePrefix = ngx.var.video_directory
-- local flvPath =ngx.var.flv_path
-- local tvu264Path = ngx.var.video_codec_path
-- local tvu264Args = ngx.var.codec_arg

local flvArgs =" /listen 0.0.0.0:{flv_port} /httpflv http://127.0.0.1:{tvu264_port} /buffer 512"
ngx.log(ngx.NOTICE,"FilePrefix=",FilePrefix," flvPath=",flvPath," tvu264Path=",tvu264Path)
ngx.log(ngx.NOTICE,"tvu264Args=",tvu264Args)

--local uriNoArgUri =FilePrefix..ngx.var.uri
local uriNoArgUri =string.gsub(ClientUri, "/"..Pid.."/meta",FilePrefix, 1)
ngx.log(ngx.NOTICE,"uriNoargUri=",uriNoArgUri)
local ArgUriArr = mysplit(uriNoArgUri,"@")
local tvuFile = ArgUriArr[1]
local tvuTime = ArgUriArr[2]
ngx.log(ngx.NOTICE,"tvuFile=",tvuFile," tvuTime=",tvuTime)


if nil == tvuTime then
	return -1
end
ngx.log(ngx.NOTICE,"tvuFile=",tvuFile," ts=",tvuTime,"===>")

tvu264Args = string.gsub(tvu264Args,"{tvu264_time}",tvuTime)
tvu264Args = string.gsub(tvu264Args,"{tvu264_file}",tvuFile)
tvu264Args = string.gsub(tvu264Args,"{live_time}",os.time())

ngx.log(ngx.NOTICE,"tvu264 args=",tvu264Args)


flvPort,tvuEncoderPid,flvPid = videoapi.createFlvTvu264MulUser2(flvPath,flvArgs,tvu264Path,tvu264Args)
ngx.log(ngx.NOTICE,"flvPort=",flvPort," tvuEncoderPid=",tvuEncoderPid," flvPid=",flvPid)

monitorStr = string.format( "monitor_port_pid.exe %d %d %d %d",10,flvPort,tvuEncoderPid,flvPid)
ngx.log(ngx.NOTICE,"monitorStr=",monitorStr)
exe_ret = videoapi.create_process("monitor_port_pid.exe", monitorStr)
ngx.var.forwardport = flvPort
--ngx.sleep(5)


-- ngx.log(ngx.NOTICE,"python cmmand=",processToKill," port=",MonitorPort)
-- monitorStr = string.format( "monitor_port_pid.exe %d %s %s",sleepTime,MonitorPort,processToKill)
-- exe_ret = videoapi.create_process("monitor_port_pid.exe", monitorStr)
-- ngx.log(ngx.NOTICE,"python command=",monitorStr,"  monitor_pid=",exe_ret)

ngx.log(ngx.NOTICE,"begin set uri and agrs")
ngx.req.set_uri("/media", false)


--ngx.encode_args(nil)
--ngx.req.set_uri_args("")
--ngx.var.args = nil
ngx.log(ngx.NOTICE,"modify1 uri=",ngx.var.uri," args=",ngx.var.args)


