#!/bin/bash
# Prints the ISO version stamp (YYYYMMDD) of the newest artix-base-dinit ISO
# published at iso.artixlinux.org. Prints nothing and exits 0 if the page
# cannot be fetched — callers treat that as "no new release".
set -euo pipefail

url="https://iso.artixlinux.org/isos.php"

html="$(curl -fsSL --max-time 60 "$url")" || exit 0

stamp="$(printf '%s' "$html" \
	| grep -oE 'artix-base-dinit-[0-9]{8}-x86_64\.iso' \
	| grep -oE '[0-9]{8}' \
	| sort -u \
	| sort -r \
	| head -1)"

[[ -n "$stamp" ]] && printf '%s\n' "$stamp"