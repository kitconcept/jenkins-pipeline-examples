#!groovy
pipeline {
  stages {
   stage("Build") {
      steps {
        checkout scm
      }
    }
    stage("Static Code Analysis"){
      steps {
        sh "echo 'Run Static Code Analysis'"
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
