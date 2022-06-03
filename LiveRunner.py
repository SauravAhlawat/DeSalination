from scp import SCPClient
import time
from paramiko import SSHClient

ssh = SSHClient()
ssh.load_system_host_keys()
ssh.connect('10.192.5.235', 22, 'pi', '325345745')

while 1:
    time.sleep(1)
    with SCPClient(ssh.get_transport()) as scp:
        scp.get('temp-data.txt')
    with open('temp-data.txt', 'r') as f:
        last_line = f.readlines()[-2]
    print(last_line)

    f = open("temp-data_tail.txt", "w")
    f.write(last_line)
    f.close()

# scp.get
# ls -lt junk2.txt
# #tail junk2.txt