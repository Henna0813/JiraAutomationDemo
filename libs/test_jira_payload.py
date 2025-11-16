import os
import requests
from requests.auth import HTTPBasicAuth
import json

JIRA_BASE_URL = os.getenv("JIRA_BASE_URL")
JIRA_EMAIL = os.getenv("JIRA_API_EMAIL")
JIRA_TOKEN = os.getenv("JIRA_API_TOKEN")
PROJECT_KEY = os.getenv("JIRA_PROJECT_KEY")

url = f"{JIRA_BASE_URL}/rest/api/3/issue"
auth = HTTPBasicAuth(JIRA_EMAIL, JIRA_TOKEN)
headers = {"Content-Type": "application/json"}

payload = {
    "fields": {
        "project": {"key": PROJECT_KEY},
        "summary": "Test issue via Python ADF",
        "description": {
            "type": "doc",
            "version": 1,
            "content": [
                {
                    "type": "paragraph",
                    "content": [
                        {"type": "text", "text": "This is a test issue created via API."}
                    ]
                }
            ]
        },
        "issuetype": {"id": "10003"}  # Task
    }
}

response = requests.post(url, auth=auth, headers=headers, data=json.dumps(payload))
print(response.status_code)
print(response.json())
