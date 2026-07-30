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

if ! command -v python3 >/dev/null 2>&1; then
  printf 'python3 is required to install the VS Code theme.\n' >&2
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  printf 'rsync is required to install the VS Code theme.\n' >&2
  exit 1
fi

if [[ -L "${install_dir}" ]]; then
  printf 'Refusing to replace symlinked VS Code extension directory: %s\n' "${install_dir}" >&2
  exit 1
fi
if [[ -e "${install_dir}" && ! -d "${install_dir}" ]]; then
  printf 'VS Code extension path exists but is not a directory: %s\n' "${install_dir}" >&2
  exit 1
fi

python3 - "${obsolete_file}" "${metadata_file}" <<'PY'
import json
import sys

obsolete_path, metadata_path = sys.argv[1:]


def load_json(path, expected_type, description):
    try:
        with open(path, "r", encoding="utf-8") as fh:
            value = json.load(fh)
    except FileNotFoundError:
        return None
    except (OSError, json.JSONDecodeError) as exc:
        raise SystemExit(f"Invalid {description} at {path}: {exc}") from exc

    if not isinstance(value, expected_type):
        raise SystemExit(f"Invalid {description} at {path}: unexpected top-level value")
    return value


load_json(obsolete_path, dict, "VS Code obsolete extension metadata")
extensions = load_json(metadata_path, list, "VS Code extension metadata")
if extensions is not None:
    for index, extension in enumerate(extensions):
        if not isinstance(extension, dict):
            raise SystemExit(
                f"Invalid VS Code extension metadata at {metadata_path}: entry {index} is not an object"
            )
        identifier = extension.get("identifier", {})
        if not isinstance(identifier, dict):
            raise SystemExit(
                f"Invalid VS Code extension metadata at {metadata_path}: "
                f"entry {index} identifier is not an object"
            )
        if not isinstance(identifier.get("id", ""), str):
            raise SystemExit(
                f"Invalid VS Code extension metadata at {metadata_path}: "
                f"entry {index} identifier id is not a string"
            )
PY

mkdir -p "${extensions_dir}"
stage_dir="$(mktemp -d "${extensions_dir}/.${extension_key}.stage.XXXXXX")"
backup_dir=''
had_existing=false
published=false

cleanup() {
  local status=$?
  local preserve_backup=false
  trap - EXIT

  if ((status != 0)); then
    if [[ "${published}" == true && -d "${install_dir}" && ! -L "${install_dir}" ]]; then
      if ! rm -rf -- "${install_dir}"; then
        printf 'Failed to remove the incomplete VS Code theme installation at %s\n' "${install_dir}" >&2
      fi
    fi
    if [[ "${had_existing}" == true && -n "${backup_dir}" && -d "${backup_dir}/original" ]]; then
      if ! mv -- "${backup_dir}/original" "${install_dir}"; then
        printf 'Failed to restore the previous VS Code theme installation from %s\n' "${backup_dir}/original" >&2
        preserve_backup=true
      fi
    fi
  fi

  if [[ -n "${stage_dir}" && -d "${stage_dir}" ]]; then
    if ! rm -rf -- "${stage_dir}"; then
      printf 'Failed to remove temporary VS Code theme files at %s\n' "${stage_dir}" >&2
    fi
  fi
  if [[ "${preserve_backup}" == false && -n "${backup_dir}" && -d "${backup_dir}" ]]; then
    if ! rm -rf -- "${backup_dir}"; then
      printf 'Failed to remove temporary VS Code theme backup at %s\n' "${backup_dir}" >&2
    fi
  fi

  exit "${status}"
}
trap cleanup EXIT

rsync -a "${source_dir}" "${stage_dir}/"

if [[ -L "${install_dir}" ]]; then
  printf 'Refusing to replace symlinked VS Code extension directory: %s\n' "${install_dir}" >&2
  exit 1
fi
if [[ -e "${install_dir}" && ! -d "${install_dir}" ]]; then
  printf 'VS Code extension path exists but is not a directory: %s\n' "${install_dir}" >&2
  exit 1
fi
if [[ -d "${install_dir}" ]]; then
  had_existing=true
  backup_dir="$(mktemp -d "${extensions_dir}/.${extension_key}.backup.XXXXXX")"
  mv -- "${install_dir}" "${backup_dir}/original"
fi

mv -- "${stage_dir}" "${install_dir}"
stage_dir=''
published=true

python3 - "${obsolete_file}" "${metadata_file}" "${install_dir}" "${extension_id}" "${extension_version}" \
  "${extension_key}" <<'PY'
import json
import os
import stat
import sys
import tempfile
import time

obsolete_path, metadata_path, install_dir, extension_id, extension_version, extension_key = sys.argv[1:]
publisher, _ = extension_id.split(".", 1)
relative_location = os.path.basename(install_dir)


def load_json(path, expected_type, default):
    try:
        with open(path, "r", encoding="utf-8") as fh:
            value = json.load(fh)
    except FileNotFoundError:
        return default

    if not isinstance(value, expected_type):
        raise ValueError(f"unexpected top-level value in {path}")
    return value


def prepare_json(path, value, *, compact):
    directory = os.path.dirname(path)
    fd, tmp_path = tempfile.mkstemp(prefix=f".{os.path.basename(path)}.", suffix=".tmp", dir=directory)
    try:
        try:
            mode = stat.S_IMODE(os.stat(path).st_mode)
        except FileNotFoundError:
            mode = 0o644
        os.fchmod(fd, mode)
        with os.fdopen(fd, "w", encoding="utf-8") as fh:
            if compact:
                json.dump(value, fh, separators=(",", ":"))
            else:
                json.dump(value, fh, indent=2)
                fh.write("\n")
            fh.flush()
            os.fsync(fh.fileno())
        return tmp_path
    except BaseException:
        try:
            os.close(fd)
        except OSError:
            pass
        try:
            os.unlink(tmp_path)
        except OSError:
            pass
        raise


def replace_json_files(updates):
    records = [
        {
            "path": path,
            "tmp_path": tmp_path,
            "backup_path": None,
            "published": False,
        }
        for path, tmp_path in updates
    ]
    try:
        for record in records:
            if os.path.lexists(record["path"]):
                fd, backup_path = tempfile.mkstemp(
                    prefix=f".{os.path.basename(record['path'])}.",
                    suffix=".backup",
                    dir=os.path.dirname(record["path"]),
                )
                os.close(fd)
                try:
                    os.unlink(backup_path)
                    os.link(record["path"], backup_path, follow_symlinks=False)
                except BaseException:
                    try:
                        os.unlink(backup_path)
                    except FileNotFoundError:
                        pass
                    raise
                record["backup_path"] = backup_path

            os.replace(record["tmp_path"], record["path"])
            record["tmp_path"] = None
            record["published"] = True
    except BaseException as publish_error:
        rollback_errors = []
        for record in reversed(records):
            try:
                if record["published"]:
                    if os.path.lexists(record["path"]):
                        os.unlink(record["path"])
                    if record["backup_path"] is not None:
                        os.replace(record["backup_path"], record["path"])
                elif record["backup_path"] is not None:
                    os.unlink(record["backup_path"])
                if record["backup_path"] is not None:
                    record["backup_path"] = None
            except OSError as rollback_error:
                rollback_errors.append(str(rollback_error))

        if rollback_errors:
            backup_paths = [
                record["backup_path"] for record in records if record["backup_path"] is not None
            ]
            for record in records:
                record["backup_path"] = None
            raise RuntimeError(
                "failed to publish VS Code metadata and roll it back; "
                f"backups preserved at {', '.join(backup_paths)}: {'; '.join(rollback_errors)}"
            ) from publish_error
        raise
    finally:
        for record in records:
            for tmp_path in (record["tmp_path"], record["backup_path"]):
                if tmp_path is not None:
                    try:
                        os.unlink(tmp_path)
                    except OSError:
                        pass


obsolete = load_json(obsolete_path, dict, None)
extensions = load_json(metadata_path, list, [])

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

obsolete_tmp = None
metadata_tmp = None
cleared_obsolete = obsolete is not None and obsolete.pop(extension_key, None) is not None
try:
    if cleared_obsolete:
        obsolete_tmp = prepare_json(obsolete_path, obsolete, compact=True)
    metadata_tmp = prepare_json(metadata_path, extensions, compact=False)

    updates = [(metadata_path, metadata_tmp)]
    metadata_tmp = None
    if obsolete_tmp is not None:
        updates.append((obsolete_path, obsolete_tmp))
        obsolete_tmp = None
    try:
        replace_json_files(updates)
    except Exception as exc:
        raise SystemExit(f"Failed to atomically update VS Code extension metadata: {exc}") from exc
finally:
    for tmp_path in (obsolete_tmp, metadata_tmp):
        if tmp_path is not None:
            try:
                os.unlink(tmp_path)
            except OSError:
                pass

if cleared_obsolete:
    print(f"Cleared obsolete VS Code extension marker for {extension_key}")
PY

published=false
printf 'Installed Token VS Code themes to %s\n' "${install_dir}"
