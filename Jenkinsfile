#!groovy
pipeline {
  stages {
    stage('Build') {
      node {
        checkout scm
      }
    }

    stage('Static Code Analysis') {
      node() {
        sh "echo 'Run Static Code Analysis'"
      }
    }

    stage('Unit Tests') {
      node() {
        sh "echo 'Run Tests'"
      }
    }

    stage('Acceptance Tests') {
      node() {
        sh "echo 'Run Acceptance Tests'"
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
