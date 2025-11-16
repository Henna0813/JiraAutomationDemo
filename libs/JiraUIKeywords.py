# libs/JiraUIKeywords.py
import sys
import os
from playwright.sync_api import sync_playwright, TimeoutError as PlaywrightTimeout

# Fix imports path
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if PROJECT_ROOT not in sys.path:
    sys.path.append(PROJECT_ROOT)

from resources.variables.jira_variables import JIRA_BASE_URL, JIRA_API_EMAIL, JIRA_PASSWORD, PLAYWRIGHT_HEADLESS

browser = None
page = None
playwright_instance = None


# ------------------ KEYWORDS ------------------

def Open_Browser_And_Login():
    """Open Jira and login via Atlassian SSO with redirect handling."""
    global browser, page, playwright_instance
    playwright_instance = sync_playwright().start()
    browser = playwright_instance.chromium.launch(headless=PLAYWRIGHT_HEADLESS)
    page = browser.new_page()

    page.goto(f"{JIRA_BASE_URL}/login")

    # Email input
    page.wait_for_selector("input[type='email']", timeout=60000)
    page.fill("input[type='email']", JIRA_API_EMAIL)
    page.click("button#login-submit")

    # Password input
    page.wait_for_selector("input[type='password']", timeout=60000)
    page.fill("input[type='password']", JIRA_PASSWORD)
    page.click("button#login-submit")

    # Wait until Jira site is loaded after SSO redirects
    page.wait_for_url(f"{JIRA_BASE_URL}/*", timeout=90000)
    print("Login successful!")


def Close_Browser():
    global browser, page, playwright_instance
    if browser:
        browser.close()
    if playwright_instance:
        playwright_instance.stop()
    browser = None
    page = None
    playwright_instance = None
    print("Browser closed.")


def Verify_Issue_Exists_UI(issue_key, summary_text):
    """Verify Jira issue exists with correct summary."""
    global page
    page.goto(f"{JIRA_BASE_URL}/browse/{issue_key}")
    try:
        page.wait_for_selector("h1[data-test-id='issue.views.issue-base.foundation.summary.heading']", timeout=30000)
        summary = page.inner_text("h1[data-test-id='issue.views.issue-base.foundation.summary.heading']").strip()
        assert summary == summary_text, f"Expected summary '{summary_text}', got '{summary}'"
        print(f"Issue {issue_key} exists with summary '{summary_text}'.")
    except PlaywrightTimeout:
        raise AssertionError(f"Issue {issue_key} not found in Jira UI.")


def Verify_Issue_Status_UI(issue_key, expected_status):
    """Verify Jira issue has the expected status."""
    global page
    page.goto(f"{JIRA_BASE_URL}/browse/{issue_key}")
    page.wait_for_selector("span[data-test-id='issue.views.field.status']", timeout=30000)
    status = page.inner_text("span[data-test-id='issue.views.field.status']").strip()
    assert status == expected_status, f"Expected status '{expected_status}', got '{status}'"
    print(f"Issue {issue_key} status verified as '{expected_status}'.")


def Verify_Issue_Deleted_UI(issue_key):
    """Verify Jira issue is deleted (not found)."""
    global page
    page.goto(f"{JIRA_BASE_URL}/browse/{issue_key}")
    try:
        page.wait_for_selector("h1[data-test-id='issue.views.issue-base.foundation.summary.heading']", timeout=10000)
        raise AssertionError(f"Issue {issue_key} still exists in UI.")
    except PlaywrightTimeout:
        print(f"Issue {issue_key} successfully deleted.")
