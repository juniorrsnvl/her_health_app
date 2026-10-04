"""
Batch B: adds "download my data" and "delete my account" calls to the app.
Run once from the her_health_app folder:

    python3 batch_b_patch.py

Edits lib/services/auth_service.dart in place. Safe to re-run.
"""
import pathlib
import sys

PATH = pathlib.Path("lib/services/auth_service.dart")
ANCHOR = "  static Future<List<dynamic>> getArticles() async {"
ADDITION = """  // ===========================================================
  // Patients' data rights (POPIA)
  // ===========================================================

  /// Everything the app holds about the logged-in patient.
  static Future<Map<String, dynamic>> exportMyData() async {
    final data = await _authorizedGetRaw('/auth/me/export');
    return (data is Map<String, dynamic>) ? data : <String, dynamic>{};
  }

  /// Permanently deletes the account and all its data. Needs the password.
  static Future<void> deleteMyAccount(String password) async {
    await _authorizedPostRaw('/auth/me/delete', {'password': password});
  }

"""

if not PATH.is_file():
    sys.exit(f"{PATH} not found -- run this from the her_health_app folder.")
text = PATH.read_text()
if "exportMyData" in text:
    print("auth_service.dart: already done")
elif text.count(ANCHOR) != 1:
    sys.exit("NEEDS ATTENTION: couldn't find getArticles() in auth_service.dart -- not changed")
else:
    PATH.write_text(text.replace(ANCHOR, ADDITION + ANCHOR, 1))
    print("auth_service.dart: added exportMyData() and deleteMyAccount()")
print("ALL GOOD")
