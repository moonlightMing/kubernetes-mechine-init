# -*- mode: ruby -*-
# vi: set ft=ruby :

# use vagrant plugin: vagrant-hostmanager

Vagrant.require_version ">= 1.6.0"

boxes = [
  {
      :hostname => "harbor.local",
      :ip => "192.168.33.50",
      :mem => "4096",
      :cpu => "2"
  },
  {
      :hostname => "m1",
      :ip => "192.168.33.51",
      :mem => "4096",
      :cpu => "2"
  },
  {
      :hostname => "w1",
      :ip => "192.168.33.56",
      :mem => "4096",
      :cpu => "2"
  },
  {
      :hostname => "w2",
      :ip => "192.168.33.57",
      :mem => "4096",
      :cpu => "2"
  }
]

Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"

  # https://github.com/devopsgroup-io/vagrant-hostmanager
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true

  boxes.each do |opts|
    config.vm.define opts[:hostname] do |config|
      config.vm.hostname = opts[:hostname]
      config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", opts[:mem]]
        v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
      end
      config.vm.network :private_network, ip: opts[:ip]
    end
  end

  # run setup.sh
  config.vm.provision "shell" do |s|
  	s.privileged = true
  	s.env = Hash["KUBE_VERSION" => "1.19.3"]
  	s.path = "setup.sh"
  end
end
