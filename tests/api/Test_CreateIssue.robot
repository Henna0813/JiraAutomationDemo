*** Settings ***
Library           Collections
Library           BuiltIn
Library           JSONLibrary
Library           RESTLibrary
Variables         ../../resources/variables/jira_variables.py
Resource          ../../resources/keywords/JiraAPIKeywords.robot

*** Keywords ***
Setup Secrets
    # Suppresses lower-level logs (like INFO or DEBUG) during secret initialization
    Set Log Level    WARN
    INITIALIZE SECRETS
    Set Log Level    INFO

Create Jira Headers Keyword
    [Arguments]    ${content_type}=application/json
    ${headers}=    Create Dictionary
    ...    Content-Type=${content_type}
    ...    Accept=application/json
    RETURN    ${headers}

Create Jira Epic Keyword
    [Arguments]    ${email}    ${token}
    ${request_id}=    Set Variable    create_epic_${TEST NAME}
    ${HEADERS}=       Create Jira Headers Keyword
    ${project}=       Create Dictionary    key=${JIRA_PROJECT_KEY}
    ${issuetype}=     Create Dictionary    name=Epic
    ${fields}=        Create Dictionary
    ...    project=${project}
    ...    summary=Automated Epic
    ...    description=Epic created via Robot Framework
    ...    issuetype=${issuetype}
    ${payload}=       Create Dictionary    fields=${fields}

    Make HTTP Request
    ...    ${request_id}
    ...    ${JIRA_BASE_URL}/rest/api/2/issue
    ...    method=POST
    ...    requestHeaders=${HEADERS}
    ...    requestBody=${payload}
    ...    expectedStatusCode=201
    ...    authType=Basic
    ...    username=${email}
    ...    password=${token}

    ${epic_key}=    Extract From Response Keyword    ${request_id}    $.key
    Log    Epic created: ${epic_key}
    RETURN    ${epic_key}

Extract From Response Keyword
    [Arguments]    ${request_id}    ${json_path}
    ${value}=    Execute RC    <<<rc, ${request_id}, body, ${json_path}>>>
    RETURN    ${value}

*** Test Cases ***
Create Epic Test
    ${epic_key}=    Create Jira Epic Keyword    ${JIRA_API_EMAIL}    ${JIRA_API_TOKEN}
    Log    Epic created successfully: ${epic_key}
