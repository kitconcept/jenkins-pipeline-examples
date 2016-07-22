Jenkins Pipeline Examples (by kitconcept)
==============================================================================

Git Checkout
------------

Git Checkout:

  checkout scm

The Jenkinsfile job configuration already contains the repository URL. Therefore a checkout is as simple as that. See `this<http://stackoverflow.com/questions/38198878/jenkins-pipeline-build-github-pull-request#answer-38212467>` for details.


Pipeline / Distributed Build
----------------------------

Jenkins allows to create pipeline steps that are automatically distributed across the available nodes.

Create pipeline steps::

stage 'Build'
node {
  ...
}

stage 'Test'
node {
  ...
}

Share data between pipelines::

stage 'Build'
node {
  checkout scm
  sh "npm install"
  stash includes: 'node_modules/', name: 'node_modules'
}

stage 'Test'
node {
  unstash 'node_modules'
  sh "npm run test"
}

The 'Build' pipeline step checks out the repository and runs 'npm install'. The build artifacts in 'node_modules' are stashed for later pipeline steps to be used.

The 'Test' pipeline steps unstashes the 'node_modules' stash (lookup by name) and allows to use it (e.g. to run tests on the installed modules).

Note that there is also 'archive/unarchive'. Though, I would recommend using 'stash/unstash' because it is more lightweight.


Test Results
------------

Include jUnit-based test results::

  sh "bin/test"
  step([$class: 'JUnitResultArchiver', testResults: 'parts/test/testreports/*.xml'])


Email Notifications
-------------------

Send email notifications::

  emailext (
    to: 'info@kitconcept.com',
    subject: "${env.JOB_NAME} #${env.BUILD_NUMBER} [${currentBuild.result}]",
    body: "Build URL: ${env.BUILD_URL}.\n\n",
    attachLog: true,
  )

Requires `Email-ext Plugin<https://wiki.jenkins-ci.org/display/JENKINS/Email-ext+plugin>`.


Robot Framework
---------------

Publish Robot Framework test results::

  step([$class: 'RobotPublisher',
    disableArchiveOutput: false,
    logFileName: 'log.html',
    otherFiles: '',
    outputFileName: 'output.xml',
    outputPath: '.',
    passThreshold: 100,
    reportFileName: 'report.html',
    unstableThreshold: 0]);

Requires `Robot Framework Plugin<https://wiki.jenkins-ci.org/display/JENKINS/Robot+Framework+Plugin>`.

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

Port Allocation
---------------

In order to scale Jenkins, your builds need to be able to run in parallel. You can use containers to isolate the builds or allocate ports for each job/test run::

  sh ".env/bin/pybot --variable PORT=\$(python -c \"import socket; s = socket.socket(socket.AF_INET, socket.SOCK_STREAM); s.bind(('', 0)); print(s.getsockname()[1])\") tests/acceptance"

The `Port Allocator Plugin<https://wiki.jenkins-ci.org/display/JENKINS/Port+Allocator+Plugin>` is currently not compatible with pipeline jobs. Therefore we use a simple Python script to do the trick (make sure you have a Python interpreter on your machine).


Linting
-------

Publish ESLint report::

  sh "npm run lint"
  step([$class: 'CheckStylePublisher', pattern: '**/eslint.xml', unstableTotalAll: '0', usePreviousBuildAsReference: true])

Requires `Checkstyle Plugin<https://wiki.jenkins-ci.org/display/JENKINS/Checkstyle+Plugin>`.

I used the `Violations Plugin<https://wiki.jenkins-ci.org/display/JENKINS/Violations>` before but this plugin is not compatible with pipeline jobs and it seems it became unmaintained.


HTML Reports
------------

Publish HTML::

    publishHTML (target: [
      allowMissing: false,
      alwaysLinkToLastBuild: false,
      keepAll: true,
      reportDir: 'docs/_build',
      reportFiles: 'index.html',
      reportName: "VNCuxf Mail Documentation"
    ])

Requires `HTML Publisher Plugin<https://wiki.jenkins-ci.org/display/JENKINS/HTML+Publisher+Plugin>`.


Timeouts
--------

Tests or build steps are sometimes stuck because of issues beyond our control. Therefore it makes sense to kill a build if it is stuck. For traditional Jenkins jobs there is the `Build-timeout Plugin<https://wiki.jenkins-ci.org/display/JENKINS/Build-timeout+Plugin>`. Though, pipelines give us a far more fine-grained control::

  timeout(time: 5, unit: 'MINUTES') {
    ...
  }
