#!groovy
pipeline {
  agent  none
  environment {
    GIT_COMMITTER_NAME = "jenkins"
    GIT_COMMITTER_EMAIL = "jenkins@jenkins.io"
  }
  stages {
   stage("Build") {
      steps {
        node('') {
          checkout scm
        }
      }
    }
    stage("Static Code Analysis"){
      steps {
        node('') {
          sh "echo 'Run Static Code Analysis'"
        }
      }
    }
  }
  post {
    always {
      deleteDir()
    }
    success {
      mail to:"me@example.com", subject:"SUCCESS: ${currentBuild.fullDisplayName}", body: "Yay, we passed."
    }
    failure {
      mail to:"me@example.com", subject:"FAILURE: ${currentBuild.fullDisplayName}", body: "Boo, we failed."
    }
  }
}
