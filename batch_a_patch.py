"""
Batch A: privacy consent at registration. Run once from the her_health_app folder:

    python3 batch_a_patch.py

Edits two files in place (so nothing else in them changes):
  - womens_health_backend/routers/auth.py : registration requires accepted_privacy,
    and stores when it was accepted and which notice version
  - lib/services/auth_service.dart        : register() sends accepted_privacy

Safe to re-run: anything already done is skipped.
"""
import pathlib
import sys

problems = []


def patch(path, name, steps):
    p = pathlib.Path(path)
    if not p.is_file():
        problems.append(f"{path} not found")
        return
    text = p.read_text()
    changed = False
    for done_marker, old, new, label in steps:
        if done_marker in text:
            print(f"{name}: {label} -- already done")
            continue
        if text.count(old) != 1:
            problems.append(f"{name}: couldn't find the place for '{label}' -- not changed")
            continue
        text = text.replace(old, new, 1)
        changed = True
        print(f"{name}: {label}")
    if changed:
        p.write_text(text)


patch("womens_health_backend/routers/auth.py", "auth.py", [
    ("PRIVACY_NOTICE_VERSION =",
     "def _dev_mode() -> bool:",
     "# Version of the privacy notice patients accept at registration. Change it\n"
     "# together with kPrivacyNoticeVersion in lib/screens/privacy_notice.dart.\n"
     "PRIVACY_NOTICE_VERSION = \"draft-2026-10\"\n\n\n"
     "def _dev_mode() -> bool:",
     "notice version constant"),
    ("accepted_privacy: bool",
     "    current_medications: Optional[List[str]] = None\n\n\nclass LoginRequest(BaseModel):",
     "    current_medications: Optional[List[str]] = None\n\n"
     "    # POPIA consent: registration is refused unless this is true.\n"
     "    accepted_privacy: bool = False\n\n\nclass LoginRequest(BaseModel):",
     "accepted_privacy field"),
    ("Please read and accept the privacy notice",
     "def register_user(user: RegisterRequest):\n",
     "def register_user(user: RegisterRequest):\n\n"
     "    if not user.accepted_privacy:\n"
     "        raise HTTPException(\n"
     "            status_code=400,\n"
     "            detail=\"Please read and accept the privacy notice to create an account.\"\n"
     "        )\n",
     "consent required to register"),
    ("privacy_accepted_at, privacy_version",
     "             phone_code, phone_code_expires_at, is_phone_verified)\n"
     "            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
     "             phone_code, phone_code_expires_at, is_phone_verified,\n"
     "             privacy_accepted_at, privacy_version)\n"
     "            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
     "consent columns in the insert"),
    ("                PRIVACY_NOTICE_VERSION,\n",
     "                phone_code,\n                expires_at,\n                False,\n            )\n        )\n",
     "                phone_code,\n                expires_at,\n                False,\n"
     "                datetime.utcnow(),\n                PRIVACY_NOTICE_VERSION,\n            )\n        )\n",
     "consent values in the insert"),
])

patch("lib/services/auth_service.dart", "auth_service.dart", [
    ("bool acceptedPrivacy",
     "    List<String>? currentMedications,\n  }) async {\n    final body = <String, dynamic>{\n"
     "      'email': email,\n      'phone': phone,\n      'password': password,\n    };",
     "    List<String>? currentMedications,\n    bool acceptedPrivacy = false,\n  }) async {\n"
     "    final body = <String, dynamic>{\n      'email': email,\n      'phone': phone,\n"
     "      'password': password,\n      'accepted_privacy': acceptedPrivacy,\n    };",
     "register() sends accepted_privacy"),
])

print()
if problems:
    print("NEEDS ATTENTION:")
    for p in problems:
        print("  - " + p)
    sys.exit(1)
print("ALL GOOD")
