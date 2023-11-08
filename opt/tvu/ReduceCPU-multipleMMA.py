#Auther:  AriZheng added it at 15th Dec 2017
#Purpose: Deploy multiple R.
import shutil
import os
import sys
import xml.etree.ElementTree as ET


def DeleteNotNeededFiles(DirPath):
    for j in listDeleted:
        os.system('rm -rf '+DirPath+'/'+str(j))

def DeletePlugin(filestr,pluginstr):
    index_target=-1
    file_data=""
    index_i=0
    index_j=0
    fo = open(filestr, "r")
    for line in fo.readlines():
        index_i = index_i+1
        if pluginstr in line:
            index_target=index_i
    fo.close()
    fo1 = open(filestr, "r")
    for line in fo1.readlines():
        index_j = index_j+1
        if (index_j+1) == index_target:
            line=""
        if (index_j) == index_target:
            line=""
        if (index_j-1) == index_target:
            line=""
        file_data = file_data + line
    with open(filestr,"w") as f:
        f.write(file_data)

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
def ChangeRConfig(Rpath):
    tree = ET.parse(Rpath)
    root=tree.getroot()
    WebRList=root.findall('WebREncoder')
    if len(WebRList)<=0:
        WRE = ET.Element('WebREncoder')
        root.append(WRE)
    for WebREncoder in root.findall('WebREncoder'): 
        Enabled=WebREncoder.find('Enabled')
        if Enabled is None:
            Enabled = ET.Element('Enabled')
            Enabled.text='false'
            WebREncoder.append(Enabled)
        else:
            Enabled.text='false'

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

print 'disable dcap'
DeletePlugin("/opt/tvu/R/Plugin/Plugins_Console.json", "DCapStarter")
DeletePlugin("/opt/tvu/R##1##/Plugin/Plugins_Console.json", "DCapStarter")
print 'disable dcap success'

print 'disable SDI out'
ChangeLine("/opt/tvu/R/Config.xml", "<EnableSDI>1</EnableSDI>", "<EnableSDI>0</EnableSDI>")
ChangeLine("/opt/tvu/R##1##/Config.xml", "<EnableSDI>1</EnableSDI>", "<EnableSDI>0</EnableSDI>")
print 'disable SDI out success'

print 'disable ftpupload'
ChangeLine("/root/receiver.sh", "systemctl restart tvu.ftpupload", "#systemctl restart tvu.ftpupload")
os.system('systemctl stop tvu.ftpupload')
os.system('systemctl disable tvu.ftpupload')
print 'disable ftpupload success'

print 'disable thumbnail upload'
ChangeLine("/root/receiver.sh", "systemctl restart tvu.thumbnailupload", "#systemctl restart tvu.thumbnailupload")
os.system('systemctl stop tvu.thumbnailupload')
os.system('systemctl disable tvu.thumbnailupload')
print 'disable thumbnail upload success'

print 'disable thumbnail creation'
os.system('mv /opt/tvu/R/TVU.ThumbnailCreation.Creator3 /opt/tvu/R/TVU.ThumbnailCreation.Creator3--bak')
os.system('mv /opt/tvu/R##1##/TVU.ThumbnailCreation.Creator3 /opt/tvu/R##1##/TVU.ThumbnailCreation.Creator3--bak')
print 'disable thumbnail creation success'

print 'disable webrtc'
ChangeRConfig('/opt/tvu/R/Config.xml')
ChangeRConfig('/opt/tvu/R##1##/Config.xml')
DeletePlugin("/opt/tvu/R/Plugin/Plugins_Console.json", "WebREncoder")
DeletePlugin("/opt/tvu/R##1##/Plugin/Plugins_Console.json", "WebREncoder")
print 'disable webrtc success'

print 'disable colorbar'
ChangeLine("/opt/tvu/R/Config.xml", "<LastFrame>Logo</LastFrame>", "<LastFrame>Black</LastFrame>")
ChangeLine("/opt/tvu/R##1##/Config.xml", "<LastFrame>Logo</LastFrame>", "<LastFrame>Black</LastFrame>")
print 'disable colorbar success'

print 'change log level'
os.system("sed -i 's/=DEBUG/=ERROR/g' /opt/tvu/R/log4cplus*properties")
os.system("sed -i 's/=DEBUG/=ERROR/g' /opt/tvu/R##1##/log4cplus*properties")
print 'change log level success'

def ChangeRConfigDisableVision(Rpath):
    tree = ET.parse(Rpath)
    root=tree.getroot()
    VisionList=root.findall('VisionTag')
    if len(VisionList)<=0:
        VISION = ET.Element('VisionTag')
        root.append(VISION)
    for VisionTag in root.findall('VisionTag'): 
        Enabled=VisionTag.find('Enabled')
        if Enabled is None:
            Enabled = ET.Element('Enabled')
            Enabled.text='false'
            VisionTag.append(Enabled)
        else:
            Enabled.text='false'

    prettyXml(root, '  ', '\n')
    tree.write(Rpath)
    
def ChangeRConfigDisableCC(Rpath):
    tree = ET.parse(Rpath)
    root=tree.getroot()
    CCList=root.findall('SmartCaption')
    if len(CCList)<=0:
        CC = ET.Element('SmartCaption')
        root.append(CC)
    for SmartCaption in root.findall('SmartCaption'): 
        Enabled=SmartCaption.find('Enable')
        if Enabled is None:
            Enabled = ET.Element('Enable')
            Enabled.text='false'
            SmartCaption.append(Enabled)
        else:
            Enabled.text='false'

    prettyXml(root, '  ', '\n')
    tree.write(Rpath)

def disable_tvutrack2():
    print 'disable tvutrack2 docker'
    os.system("docker stop $(docker ps -a | grep tvutrack2 | awk '{print $1}')")
    os.system("docker rm $(docker ps -a | grep tvutrack2 | awk '{print $1}')")
    os.system("docker rmi $(docker images | grep tvutrack2 | awk '{print $3}')")
    print 'disable tvutrack2 docker success'

def disable_vision():
    print 'disable vision'
    os.system("systemctl stop tvu.vision")
    os.system("systemctl disable tvu.vision")
    os.system("systemctl stop tvu.vision1")
    os.system("systemctl disable tvu.vision1")
    os.system("mv /opt/tvu/R/iMatrix/vision_server /opt/tvu/R/iMatrix/vision_server--bak")
    os.system("mv /opt/tvu/R##1##/iMatrix/vision_server /opt/tvu/R##1##/iMatrix/vision_server--bak")
    ChangeRConfigDisableVision('/opt/tvu/R/Config.xml')
    ChangeRConfigDisableVision('/opt/tvu/R##1##/Config.xml')
    print 'disable vision success'

def disable_aiproxy():
    print 'disable aiproxy'
    os.system("systemctl stop tvu.aiproxy")
    os.system("systemctl stop tvu.aiproxy1")
    os.system("systemctl disable tvu.aiproxy")
    os.system("systemctl disable tvu.aiproxy1")
    
    os.system("mv /opt/tvu/R/iMatrix/aiproxy /opt/tvu/R/iMatrix/aiproxy--bak")
    os.system("mv /opt/tvu/R##1##/iMatrix/aiproxy /opt/tvu/R##1##/iMatrix/aiproxy--bak")
    print 'disable aiproxy success'

def disable_speech():
    print 'disable google_speech'
    os.system("systemctl stop tvu.speech")
    os.system("systemctl disable tvu.speech")
    ChangeRConfigDisableCC('/opt/tvu/R/Config.xml')
    ChangeRConfigDisableCC('/opt/tvu/R##1##/Config.xml')
    ChangeLine("/root/receiver.sh", "systemctl restart tvu.speech.service", "#systemctl restart tvu.speech.service")
    print 'disable google_speech success'
    
disable_tvutrack2()
disable_vision()
disable_aiproxy()
disable_speech()