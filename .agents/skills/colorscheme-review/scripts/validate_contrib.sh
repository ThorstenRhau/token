#!/usr/bin/env bash
# Validate every tracked contrib/** file with a native parser, its declared
# schema, or the application that consumes it. Commands run without the
# caller's environment or configuration and write only to a temporary
# directory.
#
# Usage: validate_contrib.sh
# Prints each failure, then a summary of passed and skipped checks. A skipped
# check is unverified, not a defect. Exits 1 when any check fails.

set -euo pipefail

# GtkSourceView style schemes do not declare their schema. JSON and YAML files
# declare theirs, so those URLs come from the files themselves.
readonly gtk_schema_url=https://gitlab.gnome.org/GNOME/gtksourceview/-/raw/master/data/styles/styles.rng

skill_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
repo=$(git -C "$skill_dir" rev-parse --show-toplevel)
readonly fixtures=$repo/tests/fixtures
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/home" "$work/schemas" "$work/bat/themes"

# The Ghostty CLI is on PATH on Linux; macOS keeps it inside the app bundle.
ghostty=$(command -v ghostty || echo /Applications/Ghostty.app/Contents/MacOS/ghostty)

declare -A passed=() skipped=() skip_example=() schema_files=() bat_rejected=()
failures=0
schema_path=

# Only PATH and a private HOME pass through, so BAT_THEME, DELTA_FEATURES,
# GIT_CONFIG_*, FZF_DEFAULT_OPTS, and the caller's application configuration
# cannot change a result.
clean() {
  env -i PATH="$PATH" HOME="$work/home" TERM=xterm-256color COLORTERM=truecolor \
    XDG_CONFIG_HOME="$work/home/.config" XDG_CACHE_HOME="$work/home/.cache" "$@"
}

pass() { # <label>
  passed[$1]=$((${passed[$1]:-0} + 1))
}

fail() { # <file> <label> <detail>
  failures=$((failures + 1))
  printf 'FAIL  %s  %s: %s\n' "$1" "$2" "$3"
}

skip() { # <file> <reason>
  skipped[$2]=$((${skipped[$2]:-0} + 1))
  [[ -n ${skip_example[$2]:-} ]] || skip_example[$2]=$1
}

# Records a skip unless the tool is installed.
need() { # <file> <tool>
  command -v "$2" >/dev/null && return 0
  skip "$1" "$2 not installed"
  return 1
}

# Passes when the command exits 0 without writing to stderr.
check() { # <file> <label> <command...>
  local file=$1 label=$2 out status=0 detail
  shift 2
  out=$("$@" 2>"$work/stderr") || status=$?
  detail=$(<"$work/stderr")
  if ((status == 0)) && [[ -z $detail ]]; then
    pass "$label"
    return
  fi
  detail=${detail:-${out:-exit $status}}
  detail=${detail//$'\n'/ | }
  fail "$file" "$label" "${detail:0:300}"
}

# Downloads each schema once and sets schema_path. A schema that no longer
# exists fails the files that declare it; any other problem, such as a network
# error, rate limit, or HTML page, only skips them.
fetch_schema() { # <label> <url> <file...>
  local label=$1 url=$2 code file
  shift 2
  schema_path=$work/schemas/$(printf '%s' "$url" | shasum | cut -c1-16)
  [[ -e $schema_path.code ]] ||
    curl -sSL --max-time 30 -o "$schema_path" -w '%{http_code}' "$url" \
      >"$schema_path.code" 2>/dev/null || true
  code=$(<"$schema_path.code")
  case $code in
    200)
      # A redirect can end at a sign-in or error page instead of the schema.
      ! grep -qi '<html' "$schema_path" && return 0
      for file in "$@"; do skip "$file" "schema URL returned an HTML page: $url"; done
      ;;
    404 | 410) for file in "$@"; do fail "$file" "$label" "HTTP $code for $url"; done ;;
    *) for file in "$@"; do skip "$file" "schema unavailable (HTTP $code): $url"; done ;;
  esac
  return 1
}

# Validates every file that declares one JSON Schema with a single uv run.
json_schemas() {
  local url files file line out status
  local -A invalid
  for url in "${!schema_files[@]}"; do
    mapfile -t files <<<"${schema_files[$url]%$'\n'}"
    if ! command -v uv >/dev/null; then
      for file in "${files[@]}"; do skip "$file" 'uv not installed'; done
      continue
    fi
    fetch_schema 'declared JSON Schema' "$url" "${files[@]}" || continue
    status=0
    out=$(uv run --no-project --quiet --with jsonschema --with pyyaml \
      python3 -I "$skill_dir/scripts/check_schema.py" "$schema_path" "${files[@]}" 2>&1) || status=$?
    # uv could not install its packages, or the schema is unusable: neither
    # says anything about the files.
    if ((status != 0)); then
      out=${out//$'\n'/ | }
      for file in "${files[@]}"; do skip "$file" "JSON Schema check unavailable: ${out:0:200}"; done
      continue
    fi
    invalid=()
    while IFS=$'\t' read -r file line; do
      [[ -n $file ]] && invalid[$file]=$line
    done <<<"$out"
    for file in "${files[@]}"; do
      if [[ -n ${invalid[$file]:-} ]]; then
        fail "$file" 'declared JSON Schema' "${invalid[$file]:0:300}"
      else
        pass 'declared JSON Schema'
      fi
    done
  done
}

declare_schema() { # <file> <url>
  [[ $2 == http* ]] || return 0
  schema_files[$2]+=$1$'\n'
}

relaxng() { # <schema> <file>
  xmllint --noout --nonet --relaxng "$1" "$2" 2>&1 >/dev/null | grep -v ' validates$' >&2
  return "${PIPESTATUS[0]}"
}

jsonc() { # <file>
  grep -v '^[[:space:]]*//' "$1" | jq empty
}

chatgpt() { # <file>
  [[ $(head -c 15 "$1") == codex-theme-v1: ]] || {
    echo 'missing codex-theme-v1: prefix' >&2
    return 1
  }
  sed 's/^codex-theme-v1://' "$1" | jq empty
}

toml() { # <file>
  python3 -I -c 'import sys, tomllib; tomllib.load(open(sys.argv[1], "rb"))' "$1"
}

emacs_theme() { # <theme-dir> <theme-name>
  clean emacs -Q --batch --eval \
    '(progn (add-to-list (quote custom-theme-load-path) (car command-line-args-left))
            (load-theme (intern (cadr command-line-args-left)) t))' "$1" "$2"
}

starship_palette() { # <file>
  local palettes
  mapfile -t palettes < <(sed -n 's/^\[palettes\.\(.*\)\]$/\1/p' "$1")
  ((${#palettes[@]} == 1)) || {
    echo "expected one [palettes.*] table, found ${#palettes[@]}" >&2
    return 1
  }
  { printf 'palette = "%s"\n' "${palettes[0]}" && cat "$1"; } >"$work/starship.toml"
  clean env STARSHIP_CONFIG="$work/starship.toml" STARSHIP_CACHE="$work/starship" \
    starship prompt >/dev/null
}

fzf_options() { # <file>
  # shellcheck disable=SC2016 # zsh expands $1.
  clean zsh -fc 'source "$1" && print x | fzf --filter=x' _ "$1" >/dev/null
}

bat_render() { # <theme>
  clean bat --theme="$1" --color=always --paging=never "$fixtures/showcase.lua" >/dev/null
}

# delta silently ignores an unknown feature or syntax theme, so a clean render
# alone proves nothing; the resolved syntax theme must also match.
delta_feature() { # <file> <feature> <syntax-theme>
  local delta=(clean delta --config "$1" --features "$2") actual
  "${delta[@]}" --paging=never <"$fixtures/showcase.diff" >/dev/null || return
  actual=$("${delta[@]}" --show-config | awk '$1 == "syntax-theme" { print $3 }')
  [[ $actual == "$3" ]] || {
    echo "resolved syntax-theme '$actual', expected '$3'" >&2
    return 1
  }
}

validate() { # <file>
  local file=$1 key value
  if [[ ! -f $file ]]; then
    fail "$file" 'tracked file' 'missing from the working tree'
    return
  fi
  case $file in
    *.tmTheme | *.itermcolors | *.terminal | *.xccolortheme)
      if need "$file" plutil; then check "$file" 'plutil -lint' plutil -lint -s "$file"; fi
      if [[ $file == *.tmTheme ]] && need "$file" bat; then
        if [[ -n ${bat_error:-} ]]; then
          fail "$file" 'bat render' "$bat_error"
        elif [[ -n ${bat_rejected[$(basename "$file" .tmTheme)]:-} ]]; then
          skip "$file" 'bat render: theme failed plutil -lint'
        else
          check "$file" 'bat render' bat_render "$(basename "$file" .tmTheme)"
        fi
      fi
      ;;
    contrib/gtksourceview/*.xml)
      if need "$file" xmllint; then
        check "$file" 'xmllint' xmllint --noout --nonet "$file"
        if fetch_schema 'GtkSourceView Relax NG schema' "$gtk_schema_url" "$file"; then
          check "$file" 'GtkSourceView Relax NG schema' relaxng "$schema_path" "$file"
        fi
      fi
      ;;
    *.sublime-color-scheme)
      if need "$file" jq; then check "$file" 'jq (JSONC)' jsonc "$file"; fi
      ;;
    contrib/chatgpt/*.txt)
      if need "$file" jq; then check "$file" 'jq (codex-theme-v1)' chatgpt "$file"; fi
      ;;
    *.json)
      if need "$file" jq; then
        check "$file" 'jq' jq empty "$file"
        declare_schema "$file" "$(jq -r '."$schema" // empty' "$file" 2>/dev/null || true)"
      fi
      ;;
    *.yml | *.yaml)
      if need "$file" ruby; then
        check "$file" 'YAML (ruby)' ruby -ryaml -e 'YAML.load_file(ARGV[0])' "$file"
      fi
      # shellcheck disable=SC2016 # $schema is literal text.
      declare_schema "$file" "$(sed -n 's/^# yaml-language-server: \$schema=//p' "$file")"
      ;;
    *.toml)
      if [[ $python_toml == yes ]]; then
        check "$file" 'TOML (tomllib)' toml "$file"
      else
        skip "$file" 'python3 3.11 or newer (tomllib) not installed'
      fi
      case $file in
        contrib/herdr/*)
          if need "$file" herdr; then
            check "$file" 'herdr config check' clean env HERDR_CONFIG_PATH="$file" herdr config check
          fi
          ;;
        contrib/starship/*)
          if need "$file" starship; then check "$file" 'starship prompt' starship_palette "$file"; fi
          ;;
      esac
      ;;
    contrib/ghostty/*)
      if [[ -x $ghostty ]]; then
        check "$file" 'ghostty +validate-config' clean "$ghostty" +validate-config --config-file="$file"
      else
        skip "$file" 'Ghostty not installed'
      fi
      ;;
    *.zsh)
      if need "$file" zsh; then check "$file" 'zsh -n' zsh -n "$file"; fi
      if [[ $file == contrib/fzf/* ]] && need "$file" fzf; then
        check "$file" 'fzf options' fzf_options "$file"
      fi
      ;;
    *.js)
      if need "$file" node; then check "$file" 'node --check' node --check "$file"; fi
      ;;
    *-theme.el)
      if need "$file" emacs; then
        check "$file" 'emacs load-theme' emacs_theme "$(dirname "$file")" "$(basename "$file" -theme.el)"
      fi
      ;;
    contrib/delta/*.gitconfig)
      check "$file" 'git config' clean git config --file "$file" --list
      if need "$file" delta && need "$file" bat; then
        while read -r key value; do
          key=${key#delta.}
          # A rejected bat theme already failed on its own file.
          if [[ -n $bat_error || -n ${bat_rejected[$value]:-} ]]; then
            skip "$file" 'delta feature: its bat theme failed validation'
          else
            check "$file" 'delta feature' delta_feature "$file" "${key%.syntax-theme}" "$value"
          fi
        done < <(clean git config --file "$file" --get-regexp '^delta\..*\.syntax-theme$')
      fi
      ;;
    *.ripgreprc)
      if need "$file" rg; then
        check "$file" 'ripgrep config' \
          clean env RIPGREP_CONFIG_PATH="$file" rg --color=always local "$fixtures/showcase.lua"
      fi
      ;;
    *.md) skip "$file" 'documentation' ;;
    *) skip "$file" "no validator for .${file##*.} files" ;;
  esac
}

cd "$repo"
mapfile -d '' -t files < <(git ls-files -z contrib)

python_toml=no
if command -v python3 >/dev/null && python3 -I -c 'import tomllib' 2>/dev/null; then
  python_toml=yes
fi

# bat and delta read themes from bat's cache, so build it once from the
# tracked tmTheme files. One unparsable theme can keep valid ones out of the
# cache, so missing themes and those plutil rejects stay out and fail on
# their own.
bat_error=
if command -v bat >/dev/null; then
  for file in "${files[@]}"; do
    [[ $file == *.tmTheme ]] || continue
    if [[ ! -f $file ]] || { command -v plutil >/dev/null && ! plutil -lint -s "$file" >/dev/null 2>&1; }; then
      bat_rejected[$(basename "$file" .tmTheme)]=1
      continue
    fi
    cp "$file" "$work/bat/themes/"
  done
  if ! bat_error=$(clean bat cache --build --source "$work/bat" 2>&1 >/dev/null); then
    bat_error=${bat_error:-bat cache --build failed}
  else
    bat_error=
  fi
fi

for file in "${files[@]}"; do
  validate "$file"
done
json_schemas

total_passed=0
total_skipped=0
mapfile -t labels < <(printf '%s\n' "${!passed[@]}" | sort)
for label in "${labels[@]}"; do
  [[ -n $label ]] || continue
  printf 'PASS  %s: %d\n' "$label" "${passed[$label]}"
  total_passed=$((total_passed + passed[$label]))
done
mapfile -t reasons < <(printf '%s\n' "${!skipped[@]}" | sort)
for reason in "${reasons[@]}"; do
  [[ -n $reason ]] || continue
  printf 'SKIP  %s: %d, e.g. %s\n' "$reason" "${skipped[$reason]}" "${skip_example[$reason]}"
  total_skipped=$((total_skipped + skipped[$reason]))
done
printf '%d files: %d checks passed, %d failed, %d skipped\n' \
  "${#files[@]}" "$total_passed" "$failures" "$total_skipped"
((failures == 0))
