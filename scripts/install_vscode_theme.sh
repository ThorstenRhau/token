#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source_dir="${repo_root}/contrib/vscode/"
extensions_dir="${TOKEN_VSCODE_EXTENSIONS_DIR:-${HOME}/.vscode/extensions}"
extension_id='thorstenrhau.token-vscode-themes'
extension_version='0.0.0'
extension_key="${extension_id}-${extension_version}"
install_dir="${extensions_dir}/${extension_key}"
obsolete_file="${extensions_dir}/.obsolete"
metadata_file="${extensions_dir}/extensions.json"

if [[ ! -f "${source_dir}/package.json" ]]; then
  printf 'Missing generated VS Code theme files. Run make contrib first.\n' >&2
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  printf 'rsync is required to install the VS Code theme.\n' >&2
  exit 1
fi

mkdir -p "${install_dir}"
rsync -a --delete "${source_dir}" "${install_dir}/"

if [[ -f "${obsolete_file}" ]]; then
  tmp_obsolete="${obsolete_file}.tmp"
  set +e
  python3 - "${obsolete_file}" "${tmp_obsolete}" "${extension_key}" <<'PY'
import json
import sys

obsolete_path, tmp_path, extension_key = sys.argv[1:]

with open(obsolete_path, "r", encoding="utf-8") as fh:
    obsolete = json.load(fh)

if obsolete.pop(extension_key, None) is not None:
    with open(tmp_path, "w", encoding="utf-8") as fh:
        json.dump(obsolete, fh, separators=(",", ":"))
    print(f"Cleared obsolete VS Code extension marker for {extension_key}")
else:
    sys.exit(2)
PY
  obsolete_status=$?
  set -e
  case ${obsolete_status} in
    0)
      mv "${tmp_obsolete}" "${obsolete_file}"
      ;;
    2)
      rm -f "${tmp_obsolete}"
      ;;
    *)
      rm -f "${tmp_obsolete}"
      printf 'Failed to update VS Code obsolete extension metadata.\n' >&2
      exit "${obsolete_status}"
      ;;
  esac
fi

python3 - "${metadata_file}" "${install_dir}" "${extension_id}" "${extension_version}" <<'PY'
import json
import os
import sys
import time

metadata_path, install_dir, extension_id, extension_version = sys.argv[1:]
publisher, name = extension_id.split(".", 1)
relative_location = os.path.basename(install_dir)

try:
    with open(metadata_path, "r", encoding="utf-8") as fh:
        extensions = json.load(fh)
except FileNotFoundError:
    extensions = []

extensions = [
    extension
    for extension in extensions
    if extension.get("identifier", {}).get("id", "").lower() != extension_id
]
extensions.append(
    {
        "identifier": {"id": extension_id, "uuid": None},
        "version": extension_version,
        "location": {
            "$mid": 1,
            "path": install_dir,
            "scheme": "file",
        },
        "relativeLocation": relative_location,
        "metadata": {
            "id": None,
            "publisherId": None,
            "publisherDisplayName": publisher,
            "targetPlatform": "undefined",
            "updated": False,
            "isPreReleaseVersion": False,
            "installedTimestamp": int(time.time() * 1000),
        },
    }
)

with open(metadata_path, "w", encoding="utf-8") as fh:
    json.dump(extensions, fh, indent=2)
    fh.write("\n")
PY

printf 'Installed Token VS Code themes to %s\n' "${install_dir}"
