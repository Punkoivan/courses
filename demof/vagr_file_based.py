__author__ = 'sergy'
import sys
import re
template_machine = '''
  config.vm.define "node%nodenum%" do |n%nodenum%|
    n%nodenum%.vm.network "private_network", ip: "192.168.0.%nodeip%"
    n%nodenum%.vm.network "forwarded_port", guest: 80, host: %nodeport%
    n%nodenum%.vm.hostname ="node%nodenum%"
  end
  '''

startip = 101
startport = 8081

base_file = open('Vagrantfile2')
base_data = base_file.read()
base_file.close()

current_machines_raw = re.findall(r'#machines [-]?\d+', base_data)
current_machines = int(current_machines_raw[0].split(' ')[1].strip())

command = sys.argv[-1]
command = 'add'
if command == 'add':
    machines_configs = ''
    for i in range(1, current_machines + 2):
        machines_configs = machines_configs + template_machine.replace('%nodenum%', str(i)).replace('%nodeip%', str(startip + i)).replace('%nodeport%', str(startport + i))
    vagr_file = open('Vagrantfile2', 'w')
    vagr_file.write(base_data.replace(current_machines_raw[0], '#machines ' + str(current_machines + 1)).replace(base_data[base_data.find('#machines-configs'):], '#machines-configs\n'+machines_configs+'\nend'))
    vagr_file.close()
elif command == 'remove':
    machines_configs = ''
    for i in range(1, current_machines):
        machines_configs = machines_configs + template_machine.replace('%nodenum%', str(i)).replace('%nodeip%', str(startip + i)).replace('%nodeport%', str(startport + i))
    vagr_file = open('Vagrantfile2', 'w')
    vagr_file.write(base_data.replace(current_machines_raw[0], '#machines ' + str(current_machines - 1)).replace(base_data[base_data.find('#machines-configs'):], '#machines-configs\n'+machines_configs+'\nend'))
    vagr_file.close()
else:
    print('aviable commands: "add" and "remove"')
