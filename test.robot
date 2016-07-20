*** Variables ***

${HOSTNAME}             127.0.0.1
${PORT}                 8080
${SERVER}               http://${HOSTNAME}:${PORT}/
${BROWSER}              chrome


*** Settings ***

Documentation   Jenkins Pipeline Job Acceptance Test
Library         Selenium2Library  timeout=10  implicit_wait=0


*** Test Cases ***

Scenario: Jenkins is up and running
  Go To  ${SERVER}
  Wait until page contains  Jenkins
  Page Should Contain  Jenkins


*** Keywords ***
