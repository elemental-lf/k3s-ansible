# -*- mode: ruby -*-
# vi: set ft=ruby :

NUM_SERVERS = 3
NUM_AGENTS = 2

TERRAFORM_VERSION = "1.0.3"

IP_MGMT = "192.168.177.10"
IP_SERVER_BASE = "192.168.177.1"
IP_AGENT_BASE = "192.168.177.2"

Vagrant.configure("2") do |config|
  config.vm.box = "centos/8"

  config.vm.provider :libvirt do |libvirt|
    libvirt.cpu_mode = 'host-passthrough'
    libvirt.graphics_type = 'none'
    libvirt.memory = 2048
    libvirt.cpus = 2
    libvirt.qemu_use_session = false
  end

  config.vm.define "mgmt" do |mgmt|
    mgmt.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: ".git/"
    mgmt.ssh.forward_agent = true

    mgmt.vm.hostname = "mgmt"
    mgmt.vm.network :private_network,
                    :ip => "#{IP_MGMT}",
                    :libvirt__network_name => "k3s-ansible",
                    :libvirt__forward_mode => "nat",
                    :autostart => true

    mgmt.vm.provision "shell" do |s|
      ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
      s.inline = <<~SHELL
        echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
      SHELL
    end

    mgmt.vm.provision "shell" do |s|
      s.inline = <<~SHELL
        set -euo pipefail
      
        cat >/etc/profile.d/path_user_local_bin.sh <<EOF
        PATH=/usr/local/bin:$PATH
        export PATH
        EOF
      
        # Install Ansible
        dnf install -y epel-release
        dnf install -y ansible --setopt=install_weak_deps=False
      
        # Install Terraform
        dnf install -y unzip --setopt=install_weak_deps=False
        cd /usr/local/bin
        curl -sSL -o terraform.zip https://releases.hashicorp.com/terraform/#{TERRAFORM_VERSION}/terraform_#{TERRAFORM_VERSION}_linux_amd64.zip
        unzip -o terraform.zip
        rm terraform.zip
        # This augments ~/.bashrc
        sudo -u vagrant /usr/local/bin/terraform -install-autocomplete
      SHELL
    end
  end

  (1..NUM_SERVERS).each do |i|
    config.vm.define "server-#{i}" do |server|
      server.vm.synced_folder ".", "/vagrant", disabled: true

      server.vm.hostname = "server-#{i}"
      server.vm.network :private_network,
                        :ip => "#{IP_SERVER_BASE}" + i.to_s.rjust(2, '0'),
                        :libvirt__network_name => "k3s-ansible",
                        :libvirt__forward_mode => "nat",
                        :autostart => true

      server.vm.provision "shell" do |s|
        ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
        s.inline = <<~SHELL
          echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
        SHELL
      end

      server.vm.provision "shell" do |s|
        s.inline = <<-SHELL

        SHELL
      end
    end
  end

  (1..NUM_AGENTS).each do |i|
    config.vm.define "agent-#{i}" do |agent|
      agent.vm.synced_folder ".", "/vagrant", disabled: true

      agent.vm.hostname = "agent-#{i}"
      agent.vm.network :private_network,
                        :ip => "#{IP_AGENT_BASE}" + i.to_s.rjust(2, '0'),
                        :libvirt__network_name => "k3s-ansible",
                        :libvirt__forward_mode => "nat",
                        :autostart => true

      agent.vm.provision "shell" do |s|
        ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
        s.inline = <<~SHELL
          echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
        SHELL
      end

      agent.vm.provision "shell" do |s|
        s.inline = <<-SHELL

        SHELL
      end
    end
  end
end


