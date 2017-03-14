# testing
sudo apt-get install -y python-pip
pip install robotframework
pip install robotframework-selenium2library
# mailserver
sudo debconf-set-selections <<< "postfix postfix/mailname string your.hostname.com"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt-get install -y postfix
# jenkins
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install -y jenkins
sudo apt-get install -y git
sudo service jenkins restart
sleep 10
while [[ ! -f /var/lib/jenkins/config.xml ]]; do sleep 2; done;
sudo -u jenkins sed -i "s@<useSecurity>true<\/useSecurity>@<useSecurity>false<\/useSecurity>@g" /var/lib/jenkins/config.xml
# enable JNLP port, see https://github.com/aespinosa/docker-jenkins/issues/24
sudo -u jenkins sed -i "s@<slaveAgentPort>.*@<slaveAgentPort>49153</slaveAgentPort>@g" /var/lib/jenkins/config.xml
sudo -u jenkins cp /var/lib/jenkins/jenkins.install.UpgradeWizard.state /var/lib/jenkins/jenkins.install.InstallUtil.lastExecVersion
sudo service jenkins restart
sleep 10
while [[ $(curl -s -w "%{http_code}" http://localhost:8080 -o /dev/null) != "200" ]]; do  sleep 5; done;
sudo wget http://localhost:8080/jnlpJars/jenkins-cli.jar
java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin git
java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin checkstyle
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
java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin pipeline-model-definition
sudo service jenkins restart
sleep 10
while [[ $(curl -s -w "%{http_code}" http://localhost:8080 -o /dev/null) != "200" ]]; do  sleep 5; done;
java -jar jenkins-cli.jar -s http://localhost:8080 create-job pipeline < /home/vagrant/jenkins-pipeline-examples/pipeline.xml
