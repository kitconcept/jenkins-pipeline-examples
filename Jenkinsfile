#!groovy
stage('Build') {
  node {
    checkout scm
  }
}

stage('Static Code Analysis') {
  node {
    sh "echo 'Run Static Code Analysis'"
  }
}

stage('Unit Tests') {
  node {
    sh "echo 'Run Tests'"
  }
}

stage('Acceptance Tests') {
  node {
    sh "echo 'Run Acceptance Tests'"
  }
}

stage('Nofification') {
  node {
    sh "echo 'Send Notifications'"
  }
}
