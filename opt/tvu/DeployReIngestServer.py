import shutil
import os
import sys

def delete_line(file_path, flag_str):
    file_data = ''
    with open(file_path, 'r') as f:
        for line in f:
            if flag_str in line:
                line = ''
            file_data += line
    with open(file_path, 'w') as f:
        f.write(file_data)

print 'prepare file'
os.system('curl -o /tmp/ReIngest.zip http://211.160.178.29:61000/share/gittar/ReIngest.zip')
os.system('unzip -o -d /tmp /tmp/ReIngest.zip')
os.system('\cp -rf /tmp/ReIngest/Config.xml /opt/tvu/R')
os.system('\cp -rf /tmp/ReIngest/Plugins_Console.json /opt/tvu/R/Plugin')
os.system('\cp -rf /tmp/ReIngest/hosts /etc')
os.system('\cp -rf /tmp/ReIngest/Reingest.conf /opt/tvu/R/NginxConf')
os.system('\cp -rf /tmp/ReIngest/tvu.r.service /etc/systemd/system')
os.system('\cp -rf /tmp/ReIngest/tvu.reingest.service /etc/systemd/system')
os.system('\cp -rf /tmp/ReIngest/EnvironmentFile.txt /opt/tvu/config')
os.system('unzip -o -d /opt/tvu /tmp/ReIngest/MMAController.zip')
os.system('systemctl stop tvu.speech.service')
os.system('systemctl disable tvu.speech')
delete_line('/root/receiver.sh', 'systemctl restart tvu.speech.service')
print 'prepare file success'

print 'enable reingest'
os.system('systemctl enable tvu.reingest.service')
os.system('systemctl restart tvu.reingest.service')
os.system('systemctl restart tvu.r.service')
print 'enable reingest success'