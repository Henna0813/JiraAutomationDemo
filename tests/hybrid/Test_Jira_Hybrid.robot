*** Settings ***
Library           Collections
Library           BuiltIn
Library           JSONLibrary
Library           RESTLibrary
Library           ../../libs/JiraUIKeywords.py
Resource          ../../resources/keywords/JiraAPIKeywords.robot
Variables         ../../resources/variables/jira_variables.py

*** Test Cases ***
Hybrid Jira Test
    # --- API: Create Epic ---
    ${epic_key}=    Create Jira Epic Keyword    ${JIRA_API_EMAIL}    ${JIRA_API_TOKEN}
    Log    Epic created via API: ${epic_key}

    # --- API: Create Issue ---
    ${issue_key}=   Create Jira Issue Keyword    ${JIRA_API_EMAIL}    ${JIRA_API_TOKEN}
    Log    Issue created via API: ${issue_key}

    # --- API: Update Issue ---
    Update Jira Issue Summary Keyword    ${issue_key}    Updated Task Issue    ${JIRA_API_EMAIL}    ${JIRA_API_TOKEN}
    Log    Issue summary updated via API

    # --- API: Transition Issue ---
    Transition Jira Issue Keyword    ${issue_key}    In Progress    ${JIRA_API_EMAIL}    ${JIRA_API_TOKEN}
    Log    Issue transitioned via API

    # --- API: Delete Issue ---
    ${delete_key}=  Create Jira Issue Keyword    ${JIRA_API_EMAIL}    ${JIRA_API_TOKEN}
    Delete Jira Issue Keyword    ${delete_key}    ${JIRA_API_EMAIL}    ${JIRA_API_TOKEN}
    Log    Issue deleted via API

    # --- UI Verification ---
    Open Browser And Login

    Verify_Issue_Exists_UI    ${epic_key}       Automated Epic
    Verify_Issue_Exists_UI    ${issue_key}      Updated Task Issue
    Verify_Issue_Status_UI    ${issue_key}      In Progress
    Verify_Issue_Deleted_UI   ${delete_key}

    Close_Browser
