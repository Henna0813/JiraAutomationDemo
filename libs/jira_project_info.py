import os
import requests
from requests.auth import HTTPBasicAuth

JIRA_BASE_URL = os.getenv("JIRA_BASE_URL")
JIRA_EMAIL = os.getenv("JIRA_API_EMAIL")
JIRA_TOKEN = os.getenv("JIRA_API_TOKEN")
PROJECT_KEY = os.getenv("JIRA_PROJECT_KEY")


def get_project_info():
    url = f"{JIRA_BASE_URL}/rest/api/3/project/{PROJECT_KEY}"
    auth = HTTPBasicAuth(JIRA_EMAIL, JIRA_TOKEN)
    headers = {"Accept": "application/json"}

    response = requests.get(url, headers=headers, auth=auth)
    response.raise_for_status()
    data = response.json()
    print("Project Info:")
    print(f"  ID: {data['id']}")
    print(f"  Key: {data['key']}")
    print(f"  Name: {data['name']}")
    return data['id']


def get_issue_types(project_id):
    url = f"{JIRA_BASE_URL}/rest/api/3/issuetype/project?projectId={project_id}"
    auth = HTTPBasicAuth(JIRA_EMAIL, JIRA_TOKEN)
    headers = {"Accept": "application/json"}

    response = requests.get(url, headers=headers, auth=auth)
    response.raise_for_status()
    data = response.json()
    print("\nValid Issue Types for this project:")
    for issue_type in data:
        print(f"  Name: {issue_type['name']}, ID: {issue_type['id']}")


if __name__ == "__main__":
    pid = get_project_info()
    get_issue_types(pid)
