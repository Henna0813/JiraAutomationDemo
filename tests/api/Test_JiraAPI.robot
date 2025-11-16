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
    [Arguments]    ${email}    ${token}    ${summary}=Automated Epic
    ${request_id}=    Set Variable    create_epic_${TEST NAME}
    ${HEADERS}=       Create Jira Headers Keyword
    ${project}=       Create Dictionary    key=${JIRA_PROJECT_KEY}
    ${issuetype}=     Create Dictionary    name=Epic
    ${fields}=        Create Dictionary
    ...    project=${project}
    ...    summary=${summary}
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

Create Jira Issue Keyword
    [Arguments]    ${email}    ${token}    ${summary}=Automated Task Issue
    ${request_id}=    Set Variable    create_issue_${TEST NAME}
    ${HEADERS}=       Create Jira Headers Keyword
    ${project}=       Create Dictionary    key=${JIRA_PROJECT_KEY}
    ${issuetype}=     Create Dictionary    name=Task
    ${fields}=        Create Dictionary
    ...    project=${project}
    ...    summary=${summary}
    ...    description=Created via Robot Framework
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

    ${issue_key}=    Extract From Response Keyword    ${request_id}    $.key
    Log    Issue created: ${issue_key}
    RETURN    ${issue_key}

Update Jira Issue Summary Keyword
    [Arguments]    ${issue_key}    ${new_summary}    ${email}    ${token}
    ${request_id}=    Set Variable    update_issue_${issue_key}
    ${HEADERS}=       Create Jira Headers Keyword
    ${fields}=        Create Dictionary    summary=${new_summary}
    ${payload}=       Create Dictionary    fields=${fields}

    Make HTTP Request
    ...    ${request_id}
    ...    ${JIRA_BASE_URL}/rest/api/2/issue/${issue_key}
    ...    method=PUT
    ...    requestHeaders=${HEADERS}
    ...    requestBody=${payload}
    ...    expectedStatusCode=204
    ...    authType=Basic
    ...    username=${email}
    ...    password=${token}

    Log    Issue ${issue_key} updated to summary: ${new_summary}

Delete Jira Issue Keyword
    [Arguments]    ${issue_key}    ${email}    ${token}
    ${request_id}=    Set Variable    delete_issue_${issue_key}
    ${HEADERS}=       Create Jira Headers Keyword

    Make HTTP Request
    ...    ${request_id}
    ...    ${JIRA_BASE_URL}/rest/api/2/issue/${issue_key}
    ...    method=DELETE
    ...    requestHeaders=${HEADERS}
    ...    expectedStatusCode=204
    ...    authType=Basic
    ...    username=${email}
    ...    password=${token}

    Log    Issue ${issue_key} deleted successfully

Transition Jira Issue Keyword
    [Arguments]    ${issue_key}    ${transition_name}    ${email}    ${token}
    ${request_id}=    Set Variable    get_transitions_${issue_key}
    ${HEADERS}=       Create Jira Headers Keyword

    # Get available transitions
    Make HTTP Request
    ...    ${request_id}
    ...    ${JIRA_BASE_URL}/rest/api/2/issue/${issue_key}/transitions
    ...    method=GET
    ...    requestHeaders=${HEADERS}
    ...    expectedStatusCode=200
    ...    authType=Basic
    ...    username=${email}
    ...    password=${token}

    ${transition_id}=    Extract From Response Keyword    ${request_id}    $.transitions[?(@.name=="${transition_name}")].id

    # Apply transition
    ${payload}=    Evaluate    {"transition": {"id": ${transition_id}}}    modules=json
    ${apply_req}=    Set Variable    apply_transition_${issue_key}
    Make HTTP Request
    ...    ${apply_req}
    ...    ${JIRA_BASE_URL}/rest/api/2/issue/${issue_key}/transitions
    ...    method=POST
    ...    requestHeaders=${HEADERS}
    ...    requestBody=${payload}
    ...    expectedStatusCode=204
    ...    authType=Basic
    ...    username=${email}
    ...    password=${token}

    Log    Issue ${issue_key} transitioned to ${transition_name}

Extract From Response Keyword
    [Arguments]    ${request_id}    ${json_path}
    ${value}=    Execute RC    <<<rc, ${request_id}, body, ${json_path}>>>
    RETURN    ${value}

*** Test Cases ***
Create Epic Test
    ${epic_key}=    Create Jira Epic Keyword    ${JIRA_API_EMAIL}    ${JIRA_API_TOKEN}
    Log    Epic created successfully: ${epic_key}

Create Issue Test
    ${issue_key}=    Create Jira Issue Keyword    ${JIRA_API_EMAIL}    ${JIRA_API_TOKEN}    Automated Task Issue
    Log    Issue created successfully: ${issue_key}

Update Issue Test
    ${issue_key}=    Create Jira Issue Keyword    ${JIRA_API_EMAIL}    ${JIRA_API_TOKEN}    Original Summary
    Update Jira Issue Summary Keyword    ${issue_key}    Updated Summary    ${JIRA_API_EMAIL}    ${JIRA_API_TOKEN}

Delete Issue Test
    ${issue_key}=    Create Jira Issue Keyword    ${JIRA_API_EMAIL}    ${JIRA_API_TOKEN}    Issue To Delete
    Delete Jira Issue Keyword    ${issue_key}    ${JIRA_API_EMAIL}    ${JIRA_API_TOKEN}

Transition Issue Test
    ${issue_key}=    Create Jira Issue Keyword    ${JIRA_API_EMAIL}    ${JIRA_API_TOKEN}    Transition Test Issue
    Transition Jira Issue Keyword    ${issue_key}    In Progress    ${JIRA_API_EMAIL}    ${JIRA_API_TOKEN}
