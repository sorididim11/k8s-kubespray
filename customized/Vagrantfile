# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'vagrant/ui'


UI = Vagrant::UI::Colored.new

settings = YAML.load_file 'vagrantConf.yml'


# create dynamic inventory file. ansible provisioner 's dynamic inventory got some bugs
UI.info 'Create ansible dynamic inventory file...', bold: true
inventory_file = 'inventory/sample/hosts'
File.open(inventory_file, 'w') do |f|
  settings.each do |_, machine_info|
    f.puts(machine_info['name'] + ' ' + 'ansible_host=' + machine_info['ip'] + ' ' + 'ip=' + machine_info['ip']) 
  end

  %w(kube-master etcd kube-node).each do |section|
    f.puts("[#{section}]")
    settings.each do |_, machine_info|
      types = machine_info['type'].split(',') 
      types.each do |t|
        f.puts(machine_info['name']) if t == section 
      end
    end
    f.puts('')
  end
  f.write("[k8s-cluster:children]\nkube-master\nkube-node")
end

Vagrant.configure('2') do |config|
  config.vm.box = 'generic/rhel7'
  config.ssh.insert_key = false
  config.vm.synced_folder '.', '/vagrant', type: 'virtualbox'

  required_plugins = %w( vagrant-hostmanager vagrant-cachier vagrant-vbguest )
  required_plugins.each do |plugin|
    exec "vagrant plugin install #{plugin};vagrant #{ARGV.join(' ')}" unless Vagrant.has_plugin?(plugin) || ARGV[0] == 'plugin'
  end
  
  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.cache.scope = :box # :machine
  config.vbguest.auto_update = false

  #if Vagrant.has_plugin?('vagrant-proxyconf')
  #  config.proxy.http = 'http://web-proxy.kor.hp.com:8080'
  #  config.proxy.https = 'http://web-proxy.kor.hp.com:8080'

  #  no_proxy = 'localhost,127.0.0.1,' + settings.map { |_, v| "#{v['ip']},#{v['name']}" }.join(',')
  #  UI.info "no proxies: #{no_proxy}"
  #  config.proxy.no_proxy = no_proxy
  # end

  settings.each do |name, machine_info|
    config.vm.define name do |node|
      node.vm.hostname = machine_info['name']
      node.vm.network :private_network, ip: machine_info['ip']
      !machine_info['box'].nil? && node.vm.box = machine_info['box']

      node.vm.provider 'virtualbox' do |vb|
        vb.linked_clone = true
        vb.cpus = machine_info['cpus']
        vb.memory = machine_info['mem']
        vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
        # for dcos ntptime
        vb.customize ['guestproperty', 'set', :id, '/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold', 1000]
      end
      node.vm.provision 'shell', inline: 'swapoff -a'
  

      if machine_info['name'] == 'k8s-01'
        #node.vm.network 'forwarded_port', guest: 6443, host: 443
        ssh_prv_key = File.read("#{Dir.home}/.vagrant.d/insecure_private_key")
        UI.info 'Insert vagrant insecure key to bootstreap node...', bold: true
        node.vm.provision 'shell' do |sh|
          sh.inline = <<-SHELL
            [ ! -e /home/vagrant/.ssh/id_rsa ] && echo "#{ssh_prv_key}" > /home/vagrant/.ssh/id_rsa && chown vagrant:vagrant /home/vagrant/.ssh/id_rsa && chmod 600 /home/vagrant/.ssh/id_rsa
            echo Provisioning of ssh keys completed [Success].
          SHELL
        end

        node.vm.provision :ansible_local do |ansible|
          #ansible.install_mode = :pip # or default( by os package manager)
          ansible.install_mode = "pip_args_only"
          ansible.pip_args = "-r /vagrant/requirements.txt"
          #ansible.version = '2.4.3.0'
          ansible.config_file = 'ansible.cfg'
          ansible.inventory_path = inventory_file
          ansible.become = true
          ansible.limit = 'all'
          ansible.playbook = 'site.yml'
          ansible.verbose = 'true'
        end
      end
    end
  end
end
