Jenkins Pipeline Examples (by kitconcept)
==============================================================================

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

todo...

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
    )
  }
  sh "echo VERSION"
  sh "echo ${VERSION}"

Global Variables
----------------

Current Build::

  currentBuild.result
  currentBuild.displayName
  currentBuild.description

Environment::

  env.path
