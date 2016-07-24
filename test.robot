*** Variables ***

${HOSTNAME}             127.0.0.1
${PORT}                 8080
${SERVER}               http://${HOSTNAME}:${PORT}/
${BROWSER}              chrome


*** Settings ***

Documentation   Jenkins Pipeline Job Acceptance Test
Library         Selenium2Library  timeout=30  implicit_wait=0
Test Setup      Test Setup
Test Teardown   Close Browser


*** Test Cases ***

Scenario: Jenkins is up and running
  Go to  ${SERVER}
  Wait until page contains  Jenkins
  Page Should Contain  Jenkins
  Wait until page contains element  css=#header
  Page should not contain  log in
  Wait until page contains element  css=#tasks
  Page should contain element  xpath=//a[@href='/manage']

# Scenario: Install Jenkins Plugins
#   Go to  ${SERVER}/pluginManager/available
#   Wait until page contains element  xpath=//input[@name='plugin.github.default']
#   Wait until element is visible  xpath=//input[@name='plugin.github.default']
#  Select checkbox  plugin.github.default
#  Select checkbox  plugin.workflow-aggregator.default
#  Click button  css=#yui-gen1-button
#  Wait until page contains element  css=#scheduleRestart
#  Select checkbox  css=#scheduleRestartCheckbox

Scenario: Create Pipeline Job
  Go To  ${SERVER}/view/All/newJob
  Wait until page contains element  css=#name
  Input Text  css=#name  Pipeline
  Click Element  css=.org_jenkinsci_plugins_workflow_job_WorkflowJob
  Click button  OK


*** Keywords ***

Test Setup
  Open Browser  ${SERVER}  ${BROWSER}
  Set Window Size  1024  768

