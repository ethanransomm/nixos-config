#!/usr/bin/env python3
"""Enumerate .desktop launchers for the Overview's app search. Emits JSON."""
import glob
import json
import os
import re

DIRS = [
    "/run/current-system/sw/share/applications",
    "/etc/profiles/per-user/ethan/share/applications",
    os.path.expanduser("~/.nix-profile/share/applications"),
    os.path.expanduser("~/.local/share/applications"),
]

FIELD_RE = re.compile(r"^([A-Za-z]+)=(.*)$")


def parse_desktop_file(path):
    fields = {}
    in_entry = False
    with open(path, encoding="utf-8", errors="ignore") as fh:
        for line in fh:
            line = line.rstrip("\n")
            if line.startswith("["):
                in_entry = line.strip() == "[Desktop Entry]"
                continue
            if not in_entry:
                continue
            m = FIELD_RE.match(line)
            if not m:
                continue
            key, value = m.group(1), m.group(2)
            if key not in fields:
                fields[key] = value
    return fields


def main():
    apps = {}
    for d in DIRS:
        for path in glob.glob(os.path.join(d, "*.desktop")):
            fields = parse_desktop_file(path)
            name = fields.get("Name")
            exec_ = fields.get("Exec")
            if not name or not exec_:
                continue
            if fields.get("NoDisplay", "").lower() == "true":
                continue
            if fields.get("Hidden", "").lower() == "true":
                continue
            key = os.path.basename(path)
            if key in apps:
                continue
            clean_exec = re.sub(r"%[a-zA-Z]", "", exec_).strip()
            apps[key] = {
                "name": name,
                "exec": clean_exec,
                "icon": fields.get("Icon", ""),
                "terminal": fields.get("Terminal", "").lower() == "true",
            }
    result = sorted(apps.values(), key=lambda a: a["name"].lower())
    print(json.dumps(result))


if __name__ == "__main__":
    main()
