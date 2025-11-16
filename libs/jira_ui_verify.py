from playwright.sync_api import sync_playwright
import os
from dotenv import load_dotenv

load_dotenv()

JIRA_URL = os.getenv("JIRA_BASE_URL")
JIRA_EMAIL = os.getenv("JIRA_API_EMAIL")
JIRA_PASSWORD = os.getenv("JIRA_PASSWORD")

class JiraUI:
    def __init__(self):
        self.playwright = sync_playwright().start()
        self.browser = self.playwright.chromium.launch(headless=False)
        self.page = self.browser.new_page()

    def login(self):
        self.page.goto(f"{JIRA_URL}/login")
        self.page.fill("input#username", JIRA_EMAIL)
        self.page.click("button#login-submit")
        self.page.fill("input#password", JIRA_PASSWORD)
        self.page.click("button#login-submit")
        self.page.wait_for_url(f"{JIRA_URL}/jira/software/projects")

    def verify_issue_exists(self, issue_key, expected_summary):
        self.page.goto(f"{JIRA_URL}/browse/{issue_key}")
        summary = self.page.inner_text("h1[data-test-id='issue.views.issue-base.foundation.summary.heading']")
        assert summary == expected_summary, f"[UI] Expected '{expected_summary}', got '{summary}'"
        print(f"[UI] Verified issue {issue_key} exists with summary: {summary}")

    def verify_issue_deleted(self, issue_key):
        self.page.goto(f"{JIRA_URL}/browse/{issue_key}")
        assert "Issue does not exist" in self.page.content(), f"[UI] Issue {issue_key} still exists!"
        print(f"[UI] Verified issue {issue_key} is deleted")

    def verify_status(self, issue_key, expected_status):
        self.page.goto(f"{JIRA_URL}/browse/{issue_key}")
        status = self.page.inner_text("span[data-test-id='issue.views.field.status']")
        assert status == expected_status, f"[UI] Expected status '{expected_status}', got '{status}'"
        print(f"[UI] Verified issue {issue_key} is in status: {status}")

    def close(self):
        self.browser.close()
        self.playwright.stop()
