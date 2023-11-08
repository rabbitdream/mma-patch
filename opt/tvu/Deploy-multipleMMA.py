#Auther:  AriZheng added it at 15th Dec 2017
#Purpose: Deploy multiple R.
import shutil
import os
import hashlib
import sys
import xml.etree.ElementTree as ET


def DeleteNotNeededFiles(DirPath):
    for j in listDeleted:
        os.system('rm -rf '+DirPath+'/'+str(j))



def ChangeLine(filestr,old_str,new_str):
    file_data = ""
    with open(filestr, "r") as f:
        for line in f:
            if old_str in line:
                line = line.replace(old_str,new_str)
            file_data += line
    with open(filestr,"w") as f:
        f.write(file_data)

def DeleteLine(filestr,stand_str):
    file_data = ""
    with open(filestr, "r") as f:
        for line in f:
            if stand_str in line:
                line = ""
            file_data += line
    with open(filestr,"w") as f:
        f.write(file_data)

def AddLine(filestr,stand_str,new_str):
    file_data = ""
    with open(filestr, "r") as f:
        for line in f:
            if stand_str in line:
                line = line+new_str
            file_data += line
    with open(filestr,"w") as f:
        f.write(file_data)

#Define a method to change Config.xml
def ChangeConfig(Rn,Rpath):
    for Terminal in root.findall('Terminal'):
        ExternalPort=Terminal.find('ExternalPort')
        ExternalPort.text=str(Rn)+'8088'
         
        LocalPort=Terminal.find('LocalPort')
        LocalPort.text=str(Rn)+'8088'

        URL=Terminal.find('URL')
        URL.text='url=0:'+str(Rn)+'9999/xyz'

        PlayURL=Terminal.find('PlayURL')
        PlayURL.text='http://127.0.0.1:'+str(Rn)+'9999/xyz'

        SwitcherPort=Terminal.find('SwitcherPort')
        if SwitcherPort is None:
            SP = ET.Element('SwitcherPort')
            SP.text=str(7001+Rn)
            Terminal.append(SP)
        else:
            SwitcherPort.text=str(7001+Rn)
     
        SwitcherIndex=Terminal.find('SwitcherIndex')
        if SwitcherIndex is None:
            SI = ET.Element('SwitcherIndex')
            SI.text=str(Rn)
            Terminal.append(SI)
        else:
            SwitcherIndex.text=str(Rn)

        FilterGrpcPort = Terminal.find('FilterGrpcPort')
        if FilterGrpcPort is None:
            FGP = ET.Element('FilterGrpcPort')
            FGP.text = str(50051 + Rn)
            Terminal.append(FGP)
        else:
            FilterGrpcPort.text = str(50051 + Rn)

    for DeckLink in root.findall('DeckLink'):
        CardNumber=DeckLink.find('CardNumber')
        if CardNumber is None:
            CN = ET.Element('CardNumber')
            CN.text=str(Rn)
            DeckLink.append(CN)
        else:
            CardNumber.text=str(Rn)
    
    VFBList=root.findall('VideoFeedback')
    if len(VFBList)<=0:
        VFB = ET.Element('VideoFeedback')
        root.append(VFB)
    for VideoFeedback in root.findall('VideoFeedback'): 
        PortSdi=VideoFeedback.find('Port')
        if PortSdi is None:
            PSDI = ET.Element('Port')
            PSDI.text=str(10004+Rn*1000)
            VideoFeedback.append(PSDI)
        else:
            PortSdi.text=str(10004+Rn*1000)
    
        PortPack=VideoFeedback.find('PortPack')
        if PortPack is None:
            PPack = ET.Element('PortPack')
            PPack.text=str(40001+Rn*1000)
            VideoFeedback.append(PPack)
        else:
            PortPack.text=str(40001+Rn*1000)

    WebRList=root.findall('WebREncoder')
    if len(WebRList)<=0:
        WRE = ET.Element('WebREncoder')
        root.append(WRE)
    for WebREncoder in root.findall('WebREncoder'): 
        Port=WebREncoder.find('Port')
        if Port is None:
            PR = ET.Element('Port')
            PR.text=str(40002+Rn*1000)
            WebREncoder.append(PR)
        else:
            Port.text=str(40002+Rn*1000)
        
        FlvGoList=WebREncoder.findall('FlvGoLive')
        if len(FlvGoList)<=0:
            WRE = ET.Element('FlvGoLive')
            WebREncoder.append(WRE)
        for FlvGoLive in WebREncoder.findall('FlvGoLive'):
            WebSocketLocalPort=FlvGoLive.find('WebSocketLocalPort')
            if WebSocketLocalPort is None:
                WSLP = ET.Element('WebSocketLocalPort')
                WSLP.text=str(40004+Rn*1000)
                FlvGoLive.append(WSLP)
            else:
                WebSocketLocalPort.text=str(40004+Rn*1000)

    for FecTransport in root.findall('FecTransport'):
        RpcServerPort=FecTransport.find('RpcServerPort')
        if RpcServerPort is None:
            RSP = ET.Element('RpcServerPort')
            RSP.text=str(6530+Rn*10000)
            FecTransport.append(RSP)
        else:
            RpcServerPort.text=str(6530+Rn*10000)

    ExEncoderList=root.findall('ExEncoder')
    if len(ExEncoderList)<=0:
        EE = ET.Element('ExEncoder')
        root.append(EE)
    for ExEncoder in root.findall('ExEncoder'):
        StartPort=ExEncoder.find('StartPort')
        if StartPort is None:
            ESP = ET.Element('StartPort')
            ESP.text=str(30000+Rn*100)
            ExEncoder.append(ESP)
        else:
            StartPort.text=str(30000+Rn*100)

    LiveEncoderList=root.findall('LiveEncoder')
    if len(LiveEncoderList)<=0:
        LE = ET.Element('LiveEncoder')
        root.append(LE)
    for LiveEncoder in root.findall('LiveEncoder'):
        StartPort=LiveEncoder.find('StartPort')
        if StartPort is None:
            LSP = ET.Element('StartPort')
            LSP.text=str(31000+Rn*100)
            LiveEncoder.append(LSP)
        else:
            StartPort.text=str(31000+Rn*100)

    ProducerList=root.findall('Producer')
    if len(ProducerList)<=0:
        PRO = ET.Element('Producer')
        root.append(PRO)
    for Producer in root.findall('Producer'):
        StartPort=Producer.find('StartPort')
        if StartPort is None:
            PSP = ET.Element('StartPort')
            PSP.text=str(35000+Rn*100)
            Producer.append(PSP)
        else:
            StartPort.text=str(35000+Rn*100)

    StudioList=root.findall('Studio')
    if len(StudioList)<=0:
        STU = ET.Element('Studio')
        root.append(STU)
    for Studio in root.findall('Studio'):
        StartPort=Studio.find('StartPort')
        if StartPort is None:
            SSP = ET.Element('StartPort')
            SSP.text=str(37000+Rn*100)
            Studio.append(SSP)
        else:
            StartPort.text=str(37000+Rn*100)

    prettyXml(root, '  ', '\n')
    tree.write(Rpath)

#Define a method to pretty xml
def prettyXml(element, indent, newline, level = 0):
    if len(element.items()):
        if element.text == None or element.text.isspace():
            element.text = newline + indent * (level + 1)
        else:    
            element.text = newline + indent * (level + 1) + element.text.strip() + newline + indent * (level + 1)    
    #else:
        #element.text = newline + indent * (level + 1) + element.text.strip() + newline + indent * level    
    temp = list(element)
    for subelement in temp:
        if temp.index(subelement) < (len(temp) - 1):
            subelement.tail = newline + indent * (level + 1)
        else:
            subelement.tail = newline + indent * level
        prettyXml(subelement, indent, newline, level = level + 1)

def AddSymbolLink(src, dst):
    os.system('rm -rf ' + dst)
    if not os.path.isdir(src):
        os.makedirs(src)
    try:
        os.symlink(src, dst)
    except:
        print 'not need add symlink'

def Checkupdate():
    strtmp = os.popen("ps -ef |grep -w /home/tvu/MMAPATCH/update | grep -v grep |wc -l")
    cmdback = strtmp.read().strip()
    print cmdback
    if not cmdback == "0":
        print 'update is running... please wait'
        sys.exit();
    strtmp = os.popen("ps -ef |grep -w /usr/sbin/updateTrack | grep -v grep |wc -l")
    cmdback = strtmp.read().strip()
    if not cmdback == "0":
        print 'update is running... please wait'
        sys.exit();

pythonPath = '/bin/python'

print 'check update first...'
Checkupdate()

#Set input 2
val=2

#Deploy dural R instances
os.system('deployTVU -p 2')
#Use right config.xml for R##1##
os.system('systemctl stop tvu.r1')
os.system('\cp -rf /opt/tvu/configMMA/Config1.xml /opt/tvu/R##1##/Config.xml ')
os.system('\cp -rf /opt/tvu/R/Plugin/Plugins_Console.json /opt/tvu/R##1##/Plugin/Plugins_Console.json ')
os.system('systemctl restart tvu.r1')


#Change Nginx.conf
print 'Start change Nginx.conf...'
nginxConfPath = '/etc/nginx/conf.d/transceiver.conf'
os.chdir('/opt/tvu/R##1##')
os.system('chmod a+x LinuxR_PrintPeerID.py')
result = os.popen('./LinuxR_PrintPeerID.py').readlines()
PeerID = result[-1][2:18]
PeerIDMD5 = hashlib.md5(PeerID+'T1279').hexdigest()
os.system("sed -i 's/MMAR2/"+PeerID+"/g' /etc/nginx/conf.d/transceiver.conf")
os.system("sed -i 's/MMAMD5R2/"+PeerIDMD5+"/g' /etc/nginx/conf.d/transceiver.conf")

print 'Change nginx config files for R##1## success!'

#restart-nginx-server
os.system('systemctl restart openresty')
#print 'Restart nginx success!'