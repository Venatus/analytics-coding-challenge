#!/usr/bin/env python3
"""
Lightdash auto-setup script.
Runs once after all services start to create the default user, organization,
and project so the candidate can log in immediately.
"""
import http.cookiejar
import json
import os
import sys
import time
import urllib.error
import urllib.request

LIGHTDASH_URL = os.environ.get("LIGHTDASH_URL", "http://lightdash:8080")
ADMIN_EMAIL = os.environ.get("ADMIN_EMAIL", "admin@lightdash.com")
ADMIN_PASSWORD = os.environ.get("ADMIN_PASSWORD", "admin123!")
ADMIN_FIRST = os.environ.get("ADMIN_FIRST", "Admin")
ADMIN_LAST = os.environ.get("ADMIN_LAST", "User")
ORG_NAME = os.environ.get("ORG_NAME", "Venatus")
PROJECT_NAME = os.environ.get("PROJECT_NAME", "Ad Analytics")
TRINO_HOST = os.environ.get("TRINO_HOST", "trino")
TRINO_PORT = int(os.environ.get("TRINO_PORT", "8080"))

# Cookie jar to maintain session across requests
cj = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))


def log(msg):
    print(f"[lightdash-setup] {msg}", flush=True)


def api(method, path, data=None):
    """Make an API request and return parsed JSON."""
    url = f"{LIGHTDASH_URL}{path}"
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, method=method)
    req.add_header("Content-Type", "application/json")
    try:
        resp = opener.open(req, timeout=30)
        return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        body_text = e.read().decode()
        try:
            return json.loads(body_text)
        except json.JSONDecodeError:
            return {"status": "error", "error": {"message": body_text, "statusCode": e.code}}


def wait_for_lightdash(timeout=120):
    """Wait until Lightdash health endpoint responds."""
    log(f"Waiting for Lightdash at {LIGHTDASH_URL} ...")
    for i in range(timeout):
        try:
            req = urllib.request.Request(f"{LIGHTDASH_URL}/api/v1/livez")
            resp = urllib.request.urlopen(req, timeout=3)
            if resp.status == 200:
                log("Lightdash is ready.")
                return
        except Exception:
            pass
        time.sleep(1)
    log("ERROR: Lightdash did not become ready in time")
    sys.exit(1)


def check_existing_setup():
    """Return True if setup is already complete (skip)."""
    resp = api("POST", "/api/v1/login", {
        "email": ADMIN_EMAIL,
        "password": ADMIN_PASSWORD,
    })
    if resp.get("status") == "ok":
        results = resp.get("results", {})
        if results.get("isSetupComplete"):
            log("Setup already complete — skipping.")
            return True
        log("User exists but setup not complete — continuing...")
        return False
    # User doesn't exist — fresh install
    return False


def register_user():
    """Register the admin user."""
    resp = api("POST", "/api/v1/user", {
        "firstName": ADMIN_FIRST,
        "lastName": ADMIN_LAST,
        "email": ADMIN_EMAIL,
        "password": ADMIN_PASSWORD,
    })
    if resp.get("status") == "ok":
        log(f"User registered: {ADMIN_EMAIL}")
        return
    err = resp.get("error", {})
    if "AlreadyExistsError" in err.get("name", ""):
        log("User already exists — logging in...")
        login_resp = api("POST", "/api/v1/login", {
            "email": ADMIN_EMAIL,
            "password": ADMIN_PASSWORD,
        })
        if login_resp.get("status") != "ok":
            log(f"ERROR: Failed to login: {login_resp}")
            sys.exit(1)
        return
    log(f"ERROR: Failed to register user: {resp}")
    sys.exit(1)


def create_organization():
    """Create the organization if the user doesn't have one."""
    user_resp = api("GET", "/api/v1/user")
    org_uuid = (user_resp.get("results") or {}).get("organizationUuid")
    if org_uuid:
        log(f"Organization already exists: {org_uuid}")
        return

    resp = api("PUT", "/api/v1/org", {"name": ORG_NAME})
    if resp.get("status") != "ok":
        log(f"ERROR: Failed to create organization: {resp}")
        sys.exit(1)
    log(f"Organization created: {ORG_NAME}")


def create_project():
    """Create a project with the Trino warehouse connection."""
    resp = api("GET", "/api/v1/org/projects")
    projects = resp.get("results", [])
    if projects:
        log(f"Project already exists: {projects[0].get('name', '?')}")
        return

    payload = {
        "name": PROJECT_NAME,
        "type": "DEFAULT",
        "dbtVersion": "v1.9",
        "dbtConnection": {"type": "none"},
        "warehouseConnection": {
            "type": "trino",
            "host": TRINO_HOST,
            "port": TRINO_PORT,
            "user": "trino",
            "password": "",
            "dbname": "clickhouse",
            "schema": "raw",
            "http_scheme": "http",
        },
    }
    resp = api("POST", "/api/v1/org/projects", payload)
    if resp.get("status") != "ok":
        log(f"ERROR: Failed to create project: {resp}")
        sys.exit(1)
    project_uuid = resp["results"]["project"]["projectUuid"]
    log(f"Project created: {PROJECT_NAME} ({project_uuid})")


def complete_setup():
    """Mark the user setup as complete."""
    resp = api("PATCH", "/api/v1/user/me/complete", {
        "isTrackingAnonymized": True,
        "isMarketingOptedIn": False,
    })
    if resp.get("status") == "ok":
        log("Setup marked as complete.")
    else:
        log(f"WARNING: Could not mark setup complete: {resp}")


def main():
    wait_for_lightdash()
    if check_existing_setup():
        return
    register_user()
    create_organization()
    create_project()
    complete_setup()

    log("=" * 50)
    log("  Lightdash is ready!")
    log(f"  Email:    {ADMIN_EMAIL}")
    log(f"  Password: {ADMIN_PASSWORD}")
    log("=" * 50)


if __name__ == "__main__":
    main()
