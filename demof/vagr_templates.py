__author__ = 'sergy'

import sys

vagr_script_template = '''$todo = <<END
   inline: "puppet agent --test --server gate.demo.dp.ua"
   inline: "systemctl stop firewalld"
END


Vagrant.configure("2") do |config|
 config.vm.provider "virtualbox" do |vb|
  vb.gui = false
  vb.memory=256
  vb.cpus=1
  vb.check_guest_additions=false
  config.vm.synced_folder "src/", "/var/www/html", type: "rsync"
  config.vm.boot_timeout=600
  config.vm.box_check_update=false
  config.vm.box_download_insecure=true
  config.vm.box="puppetlabs/centos-7.2-64-puppet"
 end


  config.vm.provision "puppet_server" do |puppet|
    puppet.puppet_server = "gate.demo.dp.ua"
  end

  config.vm.provision "shell",
inline: $todo

%machine%

end'''

template_machine = '''
  config.vm.define "node%nodenum%" do |n%nodenum%|
    n%nodenum%.vm.network "private_network", ip: "192.168.0.%nodeip%"
    n%nodenum%.vm.network "forwarded_port", guest: 80, host: %nodeport%
    n%nodenum%.vm.hostname ="node%nodenum%"
  end
  '''

number = sys.argv[-1]
startip = 100
startport = 8080
if number.isdigit():
    machines = ''
    for i in range(1, int(number) + 1):
        machines = machines + template_machine.replace('%nodenum%', str(i)).replace('%nodeip%', str(startip + i)).replace('%nodeport%', str(startport + i))
    vagr_file = open('Vagrantfile', 'w')
    vagr_file.write(vagr_script_template.replace('%machine%', machines))
    vagr_file.close()
else:
    print('you should specify number of machines by parameter')