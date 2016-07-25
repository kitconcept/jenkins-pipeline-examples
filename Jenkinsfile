#!groovy
stage 'Build'
node {
  checkout scm
  sh 'npm install'
  stash includes: 'node_modules/', name: 'node_modules'
}

stage 'Static Code Analysis'
node {
  unstash 'node_modules'
  sh "npm run lint"
  step([$class: 'CheckStylePublisher',
    pattern: '**/eslint.xml',
    unstableTotalAll: '0',
    usePreviousBuildAsReference: true])
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

