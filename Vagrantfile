# -*- mode: ruby -*-
# vi: set ft=ruby :
#Vagrant::DEFAULT_SERVER_URL.replace('https://vagrantcloud.com')
# Require YAML module
require 'yaml'

config = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))

base_box=config['environment']['base_box']
base_box_version=config['environment']['base_box_version']

master_ip=config['environment']['masterip']

domain=config['environment']['domain']

engine_version=config['environment']['engine_version']
kubernetes_version=config['environment']['kubernetes_version']
kubernetes_token=config['environment']['kubernetes_token']


calico_url=config['environment']['calico_url']

boxes = config['boxes']

boxes_hostsfile_entries=""

 boxes.each do |box|
   boxes_hostsfile_entries=boxes_hostsfile_entries+box['mgmt_ip'] + ' ' +  box['name'] + ' ' + box['name']+'.'+domain+'\n'
 end

#puts boxes_hostsfile_entries

disable_swap = <<SCRIPT
    swapoff -a 
    sed -i '/swap/ s/^\(.*\)$/#\1/g' /etc/fstab
SCRIPT

update_hosts = <<SCRIPT
    echo "127.0.0.1 localhost" >/etc/hosts
    echo -e "#{boxes_hostsfile_entries}" |tee -a /etc/hosts
SCRIPT


$install_docker_engine = <<SCRIPT
  #curl -sSk $1 | sh
  DEBIAN_FRONTEND=noninteractive apt-get remove -qq docker docker-engine docker.io
  DEBIAN_FRONTEND=noninteractive apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -qq \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common \
  bridge-utils
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | DEBIAN_FRONTEND=noninteractive apt-key add -
  add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
  DEBIAN_FRONTEND=noninteractive apt-get -qq update
  DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce=$1
  usermod -aG docker vagrant >/dev/null
#  iptables -t nat -F
#  systemctl stop docker
#  ip link set docker0 down
#  ip link delete docker0
#  brctl addbr cbr0
#  ip addr add 172.16.0.0/16 dev cbr0
#  ip link set dev cbr0 up

#   echo "auto cbr0
#         iface cbr0 inet static
##	    address 172.16.0.0
#    	    netmask 255.255.0.0" >>/etc/network/interfaces

#  printf '{\n
#  	"iptables": false, \n
#	"ip-masq": false, \n
#	"bridge": "cbr0" \n
#	}\n
#  ' >/etc/docker/daemon.json
 
#  systemctl start docker
SCRIPT
#  echo "auto cbr0
# iface cbr0 inet static
# bridge_ports eth1
#    address 172.16.0.0
#    netmask 255.255.0.0" >>/etc/network/interfaces



$install_kubernetes = <<SCRIPT
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list 
  apt-get update -qq
  apt-get install -y --allow-unauthenticated kubelet=$1 kubeadm=$1 kubectl=$1 kubernetes-cni
  sed -i \'9s/^/Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"\\n/\' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
  systemctl daemon-reload
  systemctl enable kubelet
  echo "Kubelet Configured without Swap"
SCRIPT

$create_kubernetes_cluster = <<SCRIPT
  kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address $1
  sleep 30
	mkdir -p ~vagrant/.kube
	cp -i /etc/kubernetes/admin.conf ~vagrant/.kube/config
	chown vagrant:vagrant ~vagrant/.kube/config
  kubeadm token list |awk '/default-node-token/ { print $1 }'> /tmp_deploying_stage/token
  while true;do curl -ksSL https://$1:6443 && break;done
  kubectl --kubeconfig=/home/vagrant/.kube/config  apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml
SCRIPT

$join_kubernetes_cluster = <<SCRIPT
  kubeadm join $1:6443 --token "$(cat /tmp_deploying_stage/token)" --discovery-token-unsafe-skip-ca-verification
SCRIPT


Vagrant.configure(2) do |config|
   VAGRANT_COMMAND = ARGV[0]
#   if VAGRANT_COMMAND == "ssh"
#    config.ssh.username = 'ubuntu'
#    config.ssh.password = 'ubuntu'
#   end
  config.vm.box = base_box
  config.vm.box_version = base_box_version
  config.vm.synced_folder "tmp_deploying_stage/", "/tmp_deploying_stage",create:true
  config.vm.synced_folder "src/", "/src",create:true
  boxes.each do |node|
    config.vm.define node['name'] do |config|
      config.vm.hostname = node['name']
      config.vm.provider "virtualbox" do |v|
        config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"       
	      v.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
        v.name = node['name']
        v.customize ["modifyvm", :id, "--memory", node['mem']]
        v.customize ["modifyvm", :id, "--cpus", node['cpu']]

        v.customize ["modifyvm", :id, "--nictype1", "Am79C973"]
        v.customize ["modifyvm", :id, "--nictype2", "Am79C973"]
        v.customize ["modifyvm", :id, "--nictype3", "Am79C973"]
        v.customize ["modifyvm", :id, "--nictype4", "Am79C973"]
        v.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
        v.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
        v.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
        v.customize ["modifyvm", :id, "--nicpromisc4", "allow-all"]
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]

        if node['role'] == "client"
          v.gui = true
          v.customize ["modifyvm", :id, "--vram", "64"]
        end


      end

      config.vm.network "private_network",
      ip: node['mgmt_ip'],
      virtualbox__intnet: "LABS"


      #  config.vm.network "private_network",
      #  ip: opts[:node_hostonlyip], :netmask => "255.255.255.0",
      #  :name => 'vboxnet0',
      #  :adapter => 2


      config.vm.network "forwarded_port", guest: 8001, host: 8001, auto_correct: true

      config.vm.network "public_network",
      bridge: ["enp4s0","wlp3s0","enp3s0f1","wlp2s0","enp3s0"],
      auto_config: true

      #config.vm.provision "shell", inline: <<-SHELL
      #	echo "useDNS no" >> /etc/ssh/sshd_config
      #  update-ca-certificates
      #  systemctl reload ssh
      #SHELL


      config.vm.provision "shell", inline: <<-SHELL
        systemctl stop apt-daily.timer
        systemctl disable apt-daily.timer
        sed -i '/Update-Package-Lists/ s/1/0/' /etc/apt/apt.conf.d/10periodic
        while true;do fuser -vki /var/lib/apt/lists/lock || break ;done
        apt-get update -qq && apt-get install -qq ntpdate ntp && timedatectl set-timezone Europe/Madrid
      SHELL

      # Delete default router for host-only-adapter
      #  config.vm.provision "shell",
      #  run: "always",
      #  inline: "route del default gw 192.168.56.1"

      config.vm.provision :shell, :inline => update_hosts
      
      # Not really needed if we deploy without swap checking
      config.vm.provision :shell, :inline => disable_swap

      config.vm.provision "shell", inline: <<-SHELL
        sudo cp -R /src ~vagrant
        sudo chown -R vagrant:vagrant ~vagrant/src
      SHELL
 
        #config.vm.provision "shell", inline: "sudo sed -i 's/allowed_users=.*$/allowed_users=anybody/' /etc/X11/Xwrapper.config"
        #            DEBIAN_FRONTEND=noninteractive apt-get install -qq curl lightdm lubuntu-core lxde-common lubuntu-desktop xinit firefox unzip zip gpm mlocate console-common chromium-browser

      if node['role'] == "client"
        config.vm.provision "shell", inline: <<-SHELL
            echo "vagrant:vagrant"|sudo chpasswd
            DEBIAN_FRONTEND=noninteractive apt-get install -qq xserver-xorg-legacy \
            xfce4-session xfce4-terminal xfce4-xkb-plugin xterm curl xinit firefox unzip zip gpm mlocate console-common chromium-browser
            service gpm start
            update-rc.d gpm enable
            localectl set-x11-keymap es
            localectl set-keymap es
            setxkbmap -layout es
            echo -e "XKBLAYOUT=\"es\"\nXKBMODEL=\"pc105\"\nXKBVARIANT=\"\"\nXKBOPTIONS=\"lv3:ralt_switch,terminate:ctrl_alt_bksp\"" >/etc/default/keyboard
            echo '@setxkbmap -layout "es"'|tee -a /etc/xdg/xfce4/xinitrc
        SHELL

        config.vm.provision "shell", inline: "sudo sed -i 's/allowed_users=.*$/allowed_users=anybody/' /etc/X11/Xwrapper.config"
            #echo '@setxkbmap -option lv3:ralt_switch,terminate:ctrl_alt_bksp "es"' | sudo tee -a /etc/xdg/lxsession/LXDE/autostart
            #echo '@setxkbmap -layout "es"'|tee -a /etc/xdg/lxsession/LXDE/autostart
              next
      end

      ## INSTALLDOCKER --> on script because we can reprovision
      config.vm.provision "shell" do |s|
     		s.name       = "Install Docker Engine version "+engine_version
        s.inline     = $install_docker_engine
       	s.args       = engine_version
      end


      ## INSTALLKUBERNETES --> on script because we can reprovision
      config.vm.provision "shell" do |s|
        s.name       = "Install Kubernetes packages version "+kubernetes_version
        s.inline     = $install_kubernetes
        s.args       = kubernetes_version
      end

#       config.vm.provision "shell", inline: <<-SHELL
# #      curl -sSL https://github.com/kubernetes-incubator/cri-tools/releases/download/v1.0.0-beta.1/crictl-v1.0.0-beta.1-linux-amd64.tar.gz \
# #       -o crictl.tar.gz && tar -xvf crictl.tar.gz  && sudo mv crictl /usr/local/bin
#         curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
#         echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list 
#         apt-get update -qq
#         apt-get install -y --allow-unauthenticated kubelet=$1 kubeadm=$1 kubectl=$1 kubernetes-cni=$1
#       SHELL

      if node['role'] == "master"
        config.vm.network "forwarded_port", guest: 6443, host: 6443, auto_correct: true
        
        config.vm.provision "shell" do |s|
          s.name       = "Create Kubernetes Cluster"
          s.inline     = $create_kubernetes_cluster
          s.args       = master_ip
        end

	      # config.vm.provision "shell", inline: <<-SHELL
        # kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address $(hostname -i)
        # sleep 30
	      # mkdir -p ~vagrant/.kube
	      # cp -i /etc/kubernetes/admin.conf ~vagrant/.kube/config
	      # chown vagrant:vagrant ~vagrant/.kube/config
		    #   #kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
		    #   #sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml
        #   #kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml
        # SHELL
      
      else
        config.vm.provision "shell" do |s|
          s.name       = "Join Kubernetes Cluster"
          s.inline     = $join_kubernetes_cluster
          s.args       = master_ip
        end     
      end
      
    end
  end

end
