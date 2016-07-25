#!groovy
stage 'Build'
node {
  checkout scm
  sh 'npm install'
  stash includes: 'node_modules/', name: 'node_modules'
}

stage 'Static Code Analysis'
node {
  sh "echo 'Run Static Code Analysis'"
}

stage 'Unit Tests'
node {
  sh "echo 'Run Tests'"
}

stage 'Acceptance Tests'
node {
  sh "echo 'Run Acceptance Tests'"
  exit 1
}

stage 'Nofification'
node {
  sh "echo 'Send Notifications'"
}

