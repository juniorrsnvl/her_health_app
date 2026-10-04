"""
Makes Her Health deployable. Run once from the her_health_app folder:

    python3 prepare_deploy.py

1. Both apps read the backend address from a build setting (API_URL).
   Without one they still use http://127.0.0.1:8000, so local runs are unchanged.
2. The backend's CORS also allows any addresses listed in ALLOWED_ORIGINS.
3. Pins Python 3.12 for the hosting service.
4. Checks requirements.txt and that .env stays out of Git (changes nothing).

Safe to re-run: anything already done is skipped.
"""
import pathlib
import re
import subprocess

OLD_URL = "static const String baseUrl = 'http://127.0.0.1:8000';"
NEW_URL = ("static const String baseUrl = String.fromEnvironment(\n"
           "    'API_URL',\n"
           "    defaultValue: 'http://127.0.0.1:8000',\n"
           "  );")

problems = []

# ---------- 1. configurable backend address in both apps ----------
for path in ["lib/services/auth_service.dart", "admin_portal/lib/services/api_service.dart"]:
    p = pathlib.Path(path)
    if not p.is_file():
        problems.append(f"{path} not found")
        continue
    text = p.read_text()
    if "String.fromEnvironment(" in text and "'API_URL'" in text:
        print(f"{path}: already configurable")
    elif text.count(OLD_URL) == 1:
        p.write_text(text.replace(OLD_URL, NEW_URL, 1))
        print(f"{path}: backend address is now configurable (API_URL)")
    else:
        problems.append(f"{path}: couldn't find the baseUrl line -- not changed")

# ---------- 2. CORS from ALLOWED_ORIGINS ----------
main = pathlib.Path("womens_health_backend/main.py")
text = main.read_text()
if "ALLOWED_ORIGINS" in text:
    print("main.py: CORS already reads ALLOWED_ORIGINS")
else:
    lines = text.split("\n")
    idx = [i for i, l in enumerate(lines) if "allow_origin_regex=" in l]
    if len(idx) != 1:
        problems.append("main.py: couldn't find allow_origin_regex once -- CORS not changed")
    else:
        i = idx[0]
        indent = lines[i][: len(lines[i]) - len(lines[i].lstrip())]
        lines.insert(i, indent + 'allow_origins=[o.strip() for o in os.getenv("ALLOWED_ORIGINS", "").split(",") if o.strip()],')
        text = "\n".join(lines)
        if not re.search(r"^import os\b", text, re.M):
            text = "import os\n" + text
        main.write_text(text)
        print("main.py: CORS also allows the addresses in ALLOWED_ORIGINS")

# ---------- 3. pin Python ----------
pv = pathlib.Path("womens_health_backend/.python-version")
if pv.exists():
    print(f".python-version: already set to {pv.read_text().strip()}")
else:
    pv.write_text("3.12\n")
    print(".python-version: Python 3.12 pinned for hosting")

# ---------- 4. checks only ----------
req = pathlib.Path("womens_health_backend/requirements.txt")
if not req.is_file():
    problems.append("requirements.txt is missing -- run: pip freeze > requirements.txt (venv active)")
else:
    names = {re.split(r"[=<>~ \[]", l.strip(), 1)[0].lower() for l in req.read_text().splitlines()
             if l.strip() and not l.startswith("#")}
    for needed in ["fastapi", "uvicorn", "python-dotenv", "bcrypt", "pyjwt"]:
        if needed not in names:
            problems.append(f"requirements.txt has no {needed}")
    if "psycopg2-binary" not in names:
        if "psycopg2" in names:
            problems.append("requirements.txt has psycopg2, not psycopg2-binary -- the binary one installs more reliably on hosts")
        else:
            problems.append("requirements.txt has no psycopg2-binary")
    print("requirements.txt: checked")

try:
    tracked = subprocess.run(["git", "ls-files", "womens_health_backend/.env"],
                             capture_output=True, text=True).stdout.strip()
    if tracked:
        problems.append(".env IS TRACKED BY GIT -- stop and tell Claude before pushing")
    else:
        print(".env: not in Git (good)")
except Exception:
    problems.append("couldn't run git to check .env")

print()
if problems:
    print("NEEDS ATTENTION:")
    for p in problems:
        print("  - " + p)
else:
    print("ALL GOOD -- ready to deploy")
