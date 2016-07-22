*** Variables ***

${HOSTNAME}             127.0.0.1
${PORT}                 8080
${SERVER}               http://${HOSTNAME}:${PORT}/
${BROWSER}              chrome


*** Settings ***

Documentation   Jenkins Pipeline Job Acceptance Test
Library         Selenium2Library  timeout=10  implicit_wait=0
Suite Setup     Open Browser  ${SERVER}  ${BROWSER}
Suite Teardown  Close Browser


*** Test Cases ***

Scenario: Jenkins is up and running
  Go To  ${SERVER}
  Wait until page contains  Jenkins
  Page Should Contain  Jenkins
  Wait until page contains  log in
  Page Should Contain  log in

# Scenario: Create Pipeline Job
#   Go To  ${SERVER}
#   Wait until page contains  New Item
#   Click Link  New Item
#   Wait until page contains  Enter an item name
#   Input Text  name=Angular Pipeline Example
#   Select radio button  mode  org.jenkinsci.plugins.workflow.job.WorkflowJob
#   Click button  OK

*** Keywords ***
