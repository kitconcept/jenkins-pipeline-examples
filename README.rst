Jenkins Pipeline Examples (by kitconcept)
==============================================================================

Options
-------

Disable concurrent builds::

  pipeline {

    agent any

    options {
      disableConcurrentBuilds()
    }
    ...
  }

Set global timeout::

  options {
    timeout(time: 30, unit: 'MINUTES')
  }

Discard old builds and artifacts::

  options {
    buildDiscarder(logRotator(numToKeepStr: '30', artifactNumToKeepStr: '30'))
  }

Parameters
----------

Jenkins allows to ask the user for job paremeters before the job execution.
Possible parameters are boolean, choice, file, text, password, run, or string::

  pipeline {
      agent any

      parameters {
          booleanParam(defaultValue: true, description: '', name: 'booleanExample')
          string(defaultValue: "TEST", description: 'What environment?', name: 'stringExample')
          text(defaultValue: "This is a multiline\n text", description: "Multiline Text", name: "textExample")
          choice(choices: 'US-EAST-1\nUS-WEST-2', description: 'What AWS region?', name: 'choiceExample')
          password(defaultValue: "Password", description: "Password Parameter", name: "passwordExample")
      }

      stages {
          stage("my stage") {
              steps {
                  echo "booleanExample: ${params.booleanExample}"
                  echo "stringExample: ${params.stringExample}"
                  echo "textExample: ${params.textExample}"
                  echo "choiceExample: ${params.choiceExample}"
                  echo "passwordExample: ${params.passwordExample}"
              }
          }
      }
  }

Triggers / Scheduling
---------------------

Trigger build regularly with cron::

  pipeline {
      agent any
      triggers {
          cron('H */4 * * 1-5')
      }
      stages {
          stage('Example') {
              steps {
                  echo 'Hello World'
              }
          }
      }
  }

Triggers Pipeline Syntax docs: `https://jenkins.io/doc/book/pipeline/syntax/#triggers`_.

Paremeterized Trigger / Cron::

  pipeline {
      agent any
      parameters {
        string(name: 'PLANET', defaultValue: 'Earth', description: 'Which planet are we on?')
        string(name: 'GREETING', defaultValue: 'Hello', description: 'How shall we greet?')
      }
      triggers {
          cron('* * * * *')
          parameterizedCron('''
  # leave spaces where you want them around the parameters. They'll be trimmed.
  # we let the build run with the default name
  */2 * * * * %GREETING=Hola;PLANET=Pluto
  */3 * * * * %PLANET=Mars
          ''')
      }
      stages {
          stage('Example') {
              steps {
                  echo "${GREETING} ${PLANET}"
                  script { currentBuild.description = "${GREETING} ${PLANET}" }
              }
          }
      }
  }

Git Checkout
------------

Git Checkout::

  checkout scm

The Jenkinsfile job configuration already contains the repository URL. Therefore a checkout is as simple as that. See `this <http://stackoverflow.com/questions/38198878/jenkins-pipeline-build-github-pull-request#answer-38212467>`_ for details.


Clean Workspace
---------------

Clean workspace::

  deleteDir()

See `Jenkins workflow basic steps docs <https://jenkins.io/doc/pipeline/steps/workflow-basic-steps/#code-deletedir-code-recursively-delete-the-current-directory-from-the-workspace>`_ for more details.


Pipeline / Distributed Build
----------------------------

Jenkins allows to create pipeline steps that are automatically distributed across the available nodes.

Create pipeline steps::

  stage('Build') {
    node {
      ...
    }
  }

  stage('Test') {
    node {
      ...
    }
  }

Stash/Unstash
^^^^^^^^^^^^^

Use stash/unstash to share data between pipelines::

  stage('Build') {
    node {
      checkout scm
      sh "npm install"
      stash includes: 'node_modules/', name: 'node_modules'
    }
  }

  stage('Test') {
    node {
      unstash 'node_modules'
      sh "npm run test"
    }
  }

The 'Build' pipeline step checks out the repository and runs 'npm install'. The build artifacts in 'node_modules' are stashed for later pipeline steps to be used.

The 'Test' pipeline steps unstashes the 'node_modules' stash (lookup by name) and allows to use it (e.g. to run tests on the installed modules).

Note that files are discarded at the end of the build. If you want to keep the artifacts use 'stash/unstash'.

Artifacts
^^^^^^^^^

Archive artifacts at the end of the job::

    post {
        always {
            archiveArtifacts artifacts: 'build/libs/**/*.jar', fingerprint: true, allowEmptyArchive: true
        }
   }

"allowEmptyArchive: true" makes the build not fail when no artifacts are found. "fingerprint: true" allows to track artifacts over nodes.

Clean Workspace
^^^^^^^^^^^^^^^

In order to start with a clean build it is essential to clear the workspace before a checkout or an unstash::

  stage('Build') {
    node {
      deleteDir()
      checkout scm
      sh "npm install"
      stash includes: 'node_modules/', name: 'node_modules'
    }
  }

  stage('Test') {
    node {
      deleteDir()
      unstash 'node_modules'
      sh "npm run test"
    }
  }

When dealing with build artifacts with lots of file (e.g. node_modules or buildout) stashing/unstashing can take quite a while.


Declarative Pipeline
--------------------

Cloudbees announced a new declarative pipeline syntax in December 2016:

https://jenkins.io/blog/2016/12/19/declarative-pipeline-beta/?utm_source=feedburner&utm_medium=twitter&utm_campaign=Feed%3A+ContinuousBlog+%28Jenkins%29

https://github.com/jenkinsci/pipeline-model-definition-plugin/wiki/getting%20started

https://github.com/jenkinsci/pipeline-model-definition-plugin/blob/master/SYNTAX.md

This allows to write a cleaner pipeline::

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

Declarative Pipeline Post Actions (global)::

  #!groovy
  pipeline {
    stages {
      ...
    }
    post {
      // always means, well, always run.
      always {
        echo "Hi there"
      }
      // changed means when the build status is different than the previous build's status.
      changed {
        echo "I'm different"
      }
      // success, failure, unstable all run if the current build status is successful, failed, or unstable, respectively
      success {
        echo "I succeeded"
        archive "**/*"
      }
    }
  }

Declarative Pipeline Post Actions (stage)::

  #!groovy
  pipeline {
    stages {
      stage("first stage") {
        when { ... }
        post {
          // always means, well, always run.
          always {
            echo "Hi there"
          }
          // changed means when the build status is different than the previous build's status.
          changed {
            echo "I'm different"
          }
          // success, failure, unstable all run if the current build status is successful, failed, or unstable, respectively
          success {
            echo "I succeeded"
            archive "**/*"
          }
        }
      }
    }
  }

Post action docs: https://github.com/jenkinsci/pipeline-model-definition-plugin/wiki/Syntax-Reference

Declarative Pipeline Parallel Build Steps::

  // --- STATIC CODE ANALYSIS ---
  stage('Static Code Analysis') {
    parallel {
      stage('Backend') {
        agent {
          label "node"
        }
        steps {
          sh "ls -al"
          }
        }
      }
      stage('Frontend') {
        agent {
          label "node"
        }
        steps {
            sh "ls -al"
          }
        }
      }
    }
  }


Test Results
------------

Include jUnit-based test results::

  sh "bin/test"
  step([
    $class: 'JUnitResultArchiver',
    testResults: 'parts/test/testreports/*.xml'
  ])


Email Notifications
-------------------

Send email notifications::

  emailext (
    to: 'info@kitconcept.com',
    subject: "${env.JOB_NAME} #${env.BUILD_NUMBER} [${currentBuild.result}]",
    body: "Build URL: ${env.BUILD_URL}.\n\n",
    attachLog: true,
  )

Requires `Email-ext Plugin <https://wiki.jenkins-ci.org/display/JENKINS/Email-ext+plugin>`_.

Slack Notifications
-------------------

Add Slack notification::

  slackSend channel: '#general', color: 'good', message: '[${currentBuild.result}] #${env.BUILD_NUMBER} ${env.BUILD_URL}', teamDomain: 'kitconcept', token: '<ADD-TOKEN-HERE>'

Tutorial how to set up Jenkins and Slack: https://medium.com/appgambit/integrating-jenkins-with-slack-notifications-4f14d1ce9c7a

Robot Framework
---------------

Publish Robot Framework test results::

  sh "pybot tests/acceptance"
  step([$class: 'RobotPublisher',
    disableArchiveOutput: false,
    logFileName: 'log.html',
    otherFiles: '',
    outputFileName: 'output.xml',
    outputPath: '.',
    passThreshold: 100,
    reportFileName: 'report.html',
    unstableThreshold: 0]);

Requires `Robot Framework Plugin <https://wiki.jenkins-ci.org/display/JENKINS/Robot+Framework+Plugin>`_.

Running Robot Framework test with Selenium requires wrapping the test execution into an Xvfb wrapper::

  wrap([$class: 'Xvfb']) {
    sh ".env/bin/pybot tests/acceptance"
    step([$class: 'RobotPublisher',
      disableArchiveOutput: false,
      logFileName: 'log.html',
      otherFiles: '',
      outputFileName: 'output.xml',
      outputPath: '.',
      passThreshold: 100,
      reportFileName: 'report.html',
      unstableThreshold: 0]);
  }

Robot for Plone::

  bin/test --all --xml
  step([
    $class: 'RobotPublisher',
    disableArchiveOutput: false,
    logFileName: 'robot_log.html',
    onlyCritical: true,
    otherFiles: '**/*.png',
    outputFileName: 'robot_output.xml',
    outputPath: 'parts/test',
    passThreshold: 100,
    reportFileName: 'robot_report.html',
    unstableThreshold: 0
  ]);

Port Allocation
---------------

In order to scale Jenkins, your builds need to be able to run in parallel. You can use containers to isolate the builds or allocate ports for each job/test run::

  sh ".env/bin/pybot --variable PORT=\$(python -c \"import socket; s = socket.socket(socket.AF_INET, socket.SOCK_STREAM); s.bind(('', 0)); print(s.getsockname()[1])\") tests/acceptance"

The `Port Allocator Plugin <https://wiki.jenkins-ci.org/display/JENKINS/Port+Allocator+Plugin>`_ is currently not compatible with pipeline jobs. Therefore we use a simple Python script to do the trick (make sure you have a Python interpreter on your machine).


Static Code Analysis
--------------------

Pep8/Flake8:

  timeout(time: 5, unit: 'MINUTES') {
    sh 'bin/code-analysis'
    step([$class: 'WarningsPublisher',
      parserConfigurations: [[
        parserName: 'Pep8',
        pattern: 'parts/code-analysis/flake8.log'
      ]],
      unstableTotalAll: '0',
      usePreviousBuildAsReference: true
    ])
  }

We use the 'Pep8' parser and the pattern is the path to the log file created by either pep8 or flake8. 'unstableTotalAll' = 0 makes sure the build is marked unstable if there is a single violation. If you want the build to fail on violations, use "failedTotalAll: '0'". It is not recommended to use any other threshold than '0' for those settings.

TSLint::

  timeout(time: 5, unit: 'MINUTES') {
    sh 'npm run lint:ci'
    step([$class: 'WarningsPublisher',
      parserConfigurations: [[
        parserName: 'JSLint',
        pattern: 'pmd.xml'
      ]],
      unstableTotalAll: '0',
      usePreviousBuildAsReference: true
    ])
  }

Requires `Warnings Plugin <https://wiki.jenkins-ci.org/display/JENKINS/Warnings+Plugin>`_.

There is no documentation whatsoever available of how to use this plugin with Jenkins pipelines. See this `github commit <https://github.com/jenkinsci/warnings-plugin/commit/ee546a8f9de5dab58925e883c413d34659519696>`_. for details.


Linting
-------

Publish ESLint report::

  sh "npm run lint"
  step([$class: 'CheckStylePublisher',
    pattern: '**/eslint.xml',
    unstableTotalAll: '0',
    usePreviousBuildAsReference: true])

Requires `Checkstyle Plugin <https://wiki.jenkins-ci.org/display/JENKINS/Checkstyle+Plugin>`_.

I used the `Violations Plugin <https://wiki.jenkins-ci.org/display/JENKINS/Violations>` before but this plugin is not compatible with pipeline jobs and it seems it became unmaintained.


HTML Reports
------------

Publish HTML::

    publishHTML (target: [
      allowMissing: false,
      alwaysLinkToLastBuild: false,
      keepAll: true,
      reportDir: 'docs/_build',
      reportFiles: 'index.html',
      reportName: "Developer Documentation"
    ])

Requires `HTML Publisher Plugin <https://wiki.jenkins-ci.org/display/JENKINS/HTML+Publisher+Plugin>`_.

For some reports, such as lighthouse you need to relax the content security policy in your /etc/default/jenkins file:

```
JAVA_ARGS="-Dhudson.model.DirectoryBrowserSupport.CSP=\"sandbox allow-scripts; default-src *; style-src * http://* 'unsafe-inline' 'unsafe-eval'; script-src 'self' http://* 'unsafe-inline' 'unsafe-eval'; img-src 'self' data:\""
```

Code Coverage
-------------

The Cobertura plugin is not there yet:

https://github.com/jenkinsci/cobertura-plugin/issues/50

You can use the HTML publisher plugin instead though.


Timeouts
--------

Tests or build steps are sometimes stuck because of issues beyond our control. Therefore it makes sense to kill a build if it is stuck. For traditional Jenkins jobs there is the `Build-timeout Plugin <https://wiki.jenkins-ci.org/display/JENKINS/Build-timeout+Plugin>`_. Though, pipelines give us a far more fine-grained control::

  timeout(time: 5, unit: 'MINUTES') {
    ...
  }


Lock Resources
--------------

Lock a resource that requires exclusive access::

  lock('my-resource-name') {
    echo 'Do something here that requires unique access to the resource'
    // any other build will wait until the one locking the resource leaves this block
  }

Requires `Lockable Resources Plugin <https://wiki.jenkins-ci.org/display/JENKINS/Lockable+Resources+Plugin>`_.

Lock multiple stages in a declarative pipeline::

  stage('Parent') {
    options {
      lock('myLock')
    }
    stages {
      stage('first child') {
        ...
      }
      stage('second child') {
        ...
      }
    }
  }

NOT THERE YET! https://issues.jenkins-ci.org/browse/JENKINS-43336

Icons/Badges
------------

The  `Groovy Postbuild Plugin <https://wiki.jenkins-ci.org/display/JENKINS/Groovy+Postbuild+Plugin>`_ allows to annotate builds with icons or badges. E.g. add a version badge to the build::

  version=readFile('uxf/dist/uxf/version.txt')
  manager.addShortText("${version}")

Add warnings badge to the build::

  manager.addWarningBadge("Deployment to portal.vnc.biz failed!")

Add warning message to the detailed build view::

  manager.createSummary("warning.gif").appendText("<h1>Deployment to portal.vnc.biz failed!</h1>", false, false, false, "red")

Groovy Variables
----------------

Load file content into Groovy variable::

  version=readFile('src/client/version.txt')

Use Groovy variable::

  currentBuild.description = 'VNCuxf Mail (${version})'

Declarative Pipeline::

  script {
    VERSION = sh(
      script: 'cat package.json | python -c "import sys, json; print json.load(sys.stdin)[\'version\']"',
      returnStdout: true
  ).trim()

  sh "echo VERSION"
  sh "echo ${VERSION}"

Declarative Pipeline (ignore exit code)::

  script {
    psiExitCode = sh(
      script: 'yarn run psi',
      returnStdout: true,
      returnStatus: true
    )
  }


Global Variables
----------------

Current Build::

  currentBuild.result
  currentBuild.displayName
  currentBuild.description

Environment::

  env.path
