# -*- mode: ruby -*-
# vi: set ft=ruby :

NUM_SERVERS = 3
NUM_AGENTS = 2

TERRAFORM_VERSION = "1.0.11"

IP_MGMT = "192.168.177.10"
IP_SERVER_BASE = "192.168.177.1"
IP_AGENT_BASE = "192.168.177.2"

Vagrant.configure("2") do |config|
  config.vm.box = ENV["VAGRANT_BOX"] ? ENV["VAGRANT_BOX"] : "centos/stream8"

  config.vm.provider :libvirt do |libvirt|
    libvirt.cpu_mode = 'host-passthrough'
    libvirt.graphics_type = 'none'
    libvirt.memory = 2048
    libvirt.cpus = 2
    libvirt.qemu_use_session = false
    libvirt.storage_pool_name = ENV["LIBVIRT_STORAGE_POOL"] ? ENV["LIBVIRT_STORAGE_POOL"] : "default"
  end

  config.vm.define "mgmt" do |mgmt|
    mgmt.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".git/", "tf/example/*.tfstate", "tf/example/k3s-ansible"]
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
        set -xeuo pipefail
      
        cat >/etc/profile.d/path_user_local_bin.sh <<EOF
        PATH=/usr/local/bin:$PATH
        export PATH
        EOF
      
        # Do this in subshell as os-release has some very generic variable names
        (
          . /usr/lib/os-release

          # Install Ansible
          dnf install -y epel-release
          if [[ (${NAME} == "CentOS Linux" && ${VERSION_ID} == "8") || (${NAME} == "AlmaLinux" && ${VERSION_ID} == 8.*) ]]; then
            dnf install -y ansible --setopt=install_weak_deps=False
          elif [[ ${NAME} == "CentOS Stream" && ${VERSION_ID} == "8" ]]; then
            dnf install -y ansible-core ansible-collection-ansible-posix ansible-collection-community-general
          else
            echo "Unknown distribution: ${NAME} ${VERSION}" 1>&2
            exit 1
          fi
        )
      
        # Install Terraform
        dnf install -y unzip git --setopt=install_weak_deps=False
        cd /usr/local/bin
        curl -sSL -o terraform.zip https://releases.hashicorp.com/terraform/#{TERRAFORM_VERSION}/terraform_#{TERRAFORM_VERSION}_linux_amd64.zip
        unzip -o terraform.zip
        rm terraform.zip
        # This augments ~/.bashrc
        sudo -u vagrant /usr/local/bin/terraform -install-autocomplete

        # Install MariaDB
        dnf install -y mariadb mariadb-server
        systemctl enable --now mariadb.service
        mysql -e "CREATE DATABASE k3s;"
        mysql -e "CREATE USER 'k3s'@'%' IDENTIFIED BY 'secret';"
        mysql -e "GRANT ALL PRIVILEGES ON k3s.* TO 'k3s'@'%';"
        mysql -e "FLUSH PRIVILEGES;"
        type -P firewall-cmd >/dev/null && firewall-cmd --permanent --add-port=3306/tcp || true
        type -P firewall-cmd >/dev/null && firewall-cmd --reload || true
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
          set -xeuo pipefail
          echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
          # So that our keepalived config finds the interface. Applies at least to the AlmaLinux 8 box. The
          # original CentOS 8 box used ethX. This as hacky as it gets but our test VMs are used only once.
          (ip link set ens5 down && ip link set ens5 name eth1 && ip link set eth1 up) || true

          # Setup LVM for TopoLVM
          dnf install -y lvm2
          dd if=/dev/zero of=/tmp/loop0.img bs=1M count=1100
          losetup /dev/loop0 /tmp/loop0.img
          pvcreate --force /dev/loop0
          vgcreate data-1 /dev/loop0
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
          set -xeuo pipefail
          echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys

          # Setup LVM for TopoLVM
          dnf install -y lvm2
          dd if=/dev/zero of=/tmp/loop0.img bs=1M count=1100
          losetup /dev/loop0 /tmp/loop0.img
          pvcreate --force /dev/loop0
          vgcreate data-1 /dev/loop0
        SHELL
      end
    end
  end
end


