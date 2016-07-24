# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/trusty64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 8080, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  config.vm.synced_folder ".", "/home/vagrant/jenkins-pipeline-examples"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 1
  end

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # https://github.com/Varying-Vagrant-Vagrants/VVV/issues/517
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
    sh -c 'echo deb http://pkg.jenkins-ci.org/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    apt-get update
    apt-get install -y jenkins
    apt-get install -y git
    apt-get install -y python-pip
    pip install robotframework robotframework-selenium2library
    sudo -u jenkins sed -i "s@<useSecurity>true<\/useSecurity>@<useSecurity>false<\/useSecurity>@g" /var/lib/jenkins/config.xml
    # enable JNLP port, see https://github.com/aespinosa/docker-jenkins/issues/24
    sudo -u jenkins sed -i "s@<slaveAgentPort>.*@<slaveAgentPort>49153</slaveAgentPort>@g" /var/lib/jenkins/config.xml
    sudo -u jenkins cp /var/lib/jenkins/jenkins.install.UpgradeWizard.state /var/lib/jenkins/jenkins.install.InstallUtil.lastExecVersion
    service jenkins restart
    sleep 10
    while [[ $(curl -s -w "%{http_code}" http://localhost:8080 -o /dev/null) != "200" ]]; do  sleep 5; done;
    wget -q http://localhost:8080/jnlpJars/jenkins-cli.jar -O jenkins-cli.jar
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin git
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin workflow-aggregator
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin git
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin workflow-aggregator
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin workflow-api
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin workflow-basic-steps
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin workflow-cps
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin workflow-cps-global-lib
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin workflow-durable-task-step
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin workflow-job
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin workflow-scm-step
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin workflow-step-api
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin workflow-support
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin pipeline-stage-view
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin jquery-detached # pipeline-stage-view dep
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin momentjs # pipeline-stage-view dep
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin handlebars # pipeline-stage-view dep
    java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin pipeline-rest-api # pipeline-stage-view dep
    service jenkins restart
    sleep 10
    while [[ $(curl -s -w "%{http_code}" http://localhost:8080 -o /dev/null) != "200" ]]; do  sleep 5; done;
    (cd jenkins-pipeline-examples && java -jar jenkins-cli.jar -s http://localhost:8080 create-job pipeline < freestyle.xml)
  SHELL

end
