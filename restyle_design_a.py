"""
Restyles the patient app to Design A ("Blush & Sage, refined").

Run from the her_health_app folder:

    python3 restyle_design_a.py            # DRY RUN: lists every change, writes nothing
    python3 restyle_design_a.py --apply    # makes the changes (refuses to run on main)

What it changes, in BOTH apps (lib/ and admin_portal/lib/):
  1. Old blush pink  #E89CB0 -> deeper rose  #B04F6C (white text on it is readable)
  2. Old sage        #959B7D -> darker sage  #6E7B5F (readable as text)
  3. The busy line-art background image -> the plain warm background #FAF6F3
  4. main.dart: Nunito Sans as the app font, warm background as the default
Admin portal only:
  5. Flutter's built-in pinks -> blush app bars, rose buttons; green Approve -> sage
  6. White screen backgrounds -> the warm background
  7. A full Design A theme in admin_portal/lib/main.dart

Run it twice and the second run finds nothing to change.
"""
import pathlib
import re
import subprocess
import sys

APPLY = "--apply" in sys.argv
LIB = pathlib.Path("lib")

ROSE_OLD = re.compile(r"0x[fF]{2}[eE]89[cC][bB]0")
SAGE_OLD = re.compile(r"0x[fF]{2}959[bB]7[dD]")
BACKGROUND_PATH = "assets/images/backgrounds/background.jpeg"
GROUND = "Container(color: const Color(0xFFFAF6F3), width: double.infinity, height: double.infinity)"


def replace_background_images(text):
    """Replaces each whole Image.asset('...background.jpeg', ...) call, matching
    its closing bracket, with a plain container in the new background colour."""
    count = 0
    pattern = re.compile(r"Image\.asset\(\s*['\"]" + re.escape(BACKGROUND_PATH) + r"['\"]")
    while True:
        match = pattern.search(text)
        if not match:
            return text, count
        start = match.start()
        depth = 0
        end = None
        for i in range(start + len("Image.asset"), len(text)):
            if text[i] == "(":
                depth += 1
            elif text[i] == ")":
                depth -= 1
                if depth == 0:
                    end = i + 1
                    break
        if end is None:
            print(f"  ! could not find the end of a background image call -- left alone")
            return text, count
        text = text[:start] + GROUND + text[end:]
        count += 1


def restyle_main(text):
    """Theme changes in main.dart. Each one is skipped (and reported) if its
    anchor isn't found exactly once, rather than guessed at."""
    notes = []
    if "google_fonts.dart" not in text:
        anchor = "import 'package:flutter/material.dart';"
        if text.count(anchor) == 1:
            text = text.replace(anchor, anchor + "\nimport 'package:google_fonts/google_fonts.dart';", 1)
            notes.append("adds the google_fonts import")
        else:
            notes.append("! skipped the google_fonts import: material.dart import not found once")
    if "nunitoSansTextTheme" not in text:
        anchor = re.compile(r"theme:\s*ThemeData\(")
        found = anchor.findall(text)
        if len(found) == 1:
            text = anchor.sub(lambda m: m.group(0) + "\n        textTheme: GoogleFonts.nunitoSansTextTheme(),", text, count=1)
            notes.append("sets Nunito Sans as the app font")
        else:
            notes.append("! skipped the font: 'theme: ThemeData(' not found once")
    old_ground = re.compile(r"scaffoldBackgroundColor:\s*Colors\.white")
    if len(old_ground.findall(text)) == 1:
        text = old_ground.sub("scaffoldBackgroundColor: const Color(0xFFFAF6F3)", text, count=1)
        notes.append("sets the warm background as the default")
    return text, notes


ADMIN_RULES = [
    # (pattern, replacement, label) -- Flutter's built-in colours used in the admin portal.
    (re.compile(r"Colors\.pink\.shade100"), "const Color(0xFFF6DCE2)", "blush"),
    (re.compile(r"Colors\.pink\.shade(?:200|300|400)"), "const Color(0xFFB04F6C)", "rose"),
    (re.compile(r"Colors\.pink(?![\w.])"), "const Color(0xFFB04F6C)", "rose"),
    (re.compile(r"backgroundColor:\s*Colors\.green(?![\w.])"), "backgroundColor: const Color(0xFF6E7B5F)", "sage"),
    (re.compile(r"backgroundColor:\s*Colors\.white(?![\w.])"), "backgroundColor: const Color(0xFFFAF6F3)", "ground"),
]

ADMIN_THEME = """theme: ThemeData({fonts}
        scaffoldBackgroundColor: const Color(0xFFFAF6F3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB04F6C),
          primary: const Color(0xFFB04F6C),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6DCE2),
          foregroundColor: Color(0xFF2F3A2A),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFB04F6C),
          foregroundColor: Colors.white,
        ),
      ),"""


def restyle_admin_main(text, has_fonts):
    notes = []
    fonts_line = "\n        textTheme: GoogleFonts.nunitoSansTextTheme()," if has_fonts else ""
    if has_fonts and "google_fonts.dart" not in text:
        anchor = "import 'package:flutter/material.dart';"
        if text.count(anchor) == 1:
            text = text.replace(anchor, anchor + "\nimport 'package:google_fonts/google_fonts.dart';", 1)
            notes.append("adds the google_fonts import")
    if "appBarTheme" in text and "0xFFF6DCE2" in text:
        # Our theme is already in place; add the font if it was skipped last time.
        if has_fonts and "nunitoSansTextTheme" not in text:
            text = re.sub(r"theme:\s*ThemeData\(", lambda m: m.group(0) + "\n        textTheme: GoogleFonts.nunitoSansTextTheme(),", text, count=1)
            notes.append("adds the font to the existing Design A theme")
        return text, notes
    if re.search(r"theme:\s*ThemeData\(", text):
        notes.append("! already has a theme -- left it alone, check it by hand")
        return text, notes
    # A theme with a function call inside can't sit in a const MaterialApp.
    text, made_non_const = re.subn(r"const\s+MaterialApp\(", "MaterialApp(", text, count=1)
    found = re.findall(r"MaterialApp\(", text)
    if len(found) != 1:
        notes.append("! skipped the theme: 'MaterialApp(' not found once")
        return text, notes
    text = re.sub(r"MaterialApp\(", lambda m: "MaterialApp(\n      " + ADMIN_THEME.format(fonts=fonts_line), text, count=1)
    notes.append("adds the Design A theme" + (" (font included)" if has_fonts else ""))
    return text, notes


def current_branch():
    try:
        return subprocess.run(["git", "rev-parse", "--abbrev-ref", "HEAD"],
                              capture_output=True, text=True, check=True).stdout.strip()
    except Exception:
        return None


if not LIB.is_dir():
    sys.exit("Run this from the her_health_app folder (the one that contains lib/).")

ADMIN_LIB = pathlib.Path("admin_portal/lib")
admin_pubspec = pathlib.Path("admin_portal/pubspec.yaml")
ADMIN_HAS_FONTS = admin_pubspec.is_file() and "google_fonts" in admin_pubspec.read_text()

if APPLY:
    branch = current_branch()
    if branch in (None, "main", "master"):
        sys.exit(f"Refusing to apply on branch '{branch}'. First run:  git checkout -b design-a")

print("APPLYING CHANGES\n" if APPLY else "DRY RUN -- nothing will be written. Add --apply to make these changes.\n")

totals = {"rose": 0, "sage": 0, "background": 0, "admin": 0, "files": 0}
leftovers = []
admin_images = set()

paths = sorted(LIB.rglob("*.dart"))
if ADMIN_LIB.is_dir():
    paths += sorted(ADMIN_LIB.rglob("*.dart"))

for path in paths:
    original = path.read_text()
    text = original
    is_admin = path.as_posix().startswith("admin_portal/")

    text, rose = ROSE_OLD.subn("0xFFB04F6C", text)
    text, sage = SAGE_OLD.subn("0xFF6E7B5F", text)
    text, background = replace_background_images(text)

    notes = []
    admin_changes = 0
    if path.as_posix() == "lib/main.dart":
        text, notes = restyle_main(text)
    if is_admin:
        for pattern, replacement, label in ADMIN_RULES:
            text, n = pattern.subn(replacement, text)
            if n:
                notes.append(f"{n} {label}")
                admin_changes += n
        if path.as_posix() == "admin_portal/lib/main.dart":
            text, main_notes = restyle_admin_main(text, ADMIN_HAS_FONTS)
            notes += main_notes
        admin_images.update(re.findall(r"Image\.asset\(\s*['\"]([^'\"]+)['\"]", text))

    if BACKGROUND_PATH in text:
        leftovers.append(path.as_posix())

    if text != original:
        totals["files"] += 1
        totals["rose"] += rose
        totals["sage"] += sage
        totals["background"] += background
        totals["admin"] += admin_changes
        parts = []
        if rose: parts.append(f"{rose} rose")
        if sage: parts.append(f"{sage} sage")
        if background: parts.append(f"{background} background")
        print(f"{path.as_posix()}: " + ", ".join(parts + notes))
        if APPLY:
            path.write_text(text)

print(f"\n{totals['files']} files | {totals['rose']} rose, {totals['sage']} sage, "
      f"{totals['background']} backgrounds replaced | {totals['admin']} admin colour changes")
if ADMIN_LIB.is_dir() and not ADMIN_HAS_FONTS:
    print("\nAdmin portal font NOT changed: it doesn't have the google_fonts package yet.")
    print("To add it:  cd admin_portal && flutter pub add google_fonts && cd ..   then run this again.")
if admin_images:
    print("\nImages the admin portal shows (for the logo swap):")
    for p in sorted(admin_images):
        print("  " + p)
if leftovers:
    print("\nStill mention the old background (check these by hand):")
    for p in leftovers:
        print("  " + p)
if not APPLY and totals["files"]:
    print("\nLooks right? Run:  python3 restyle_design_a.py --apply")
