# shellcheck shell=sh
# Shared by run.sh: isolated HOME, stubs of the external commands, and the checks every plugin must pass.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
HOME_T="$T/home"; STUB="$T/stub"; LOG="$T/log"
mkdir -p "$HOME_T/.local/bin" "$STUB"; : > "$LOG"
fail=0
check() { if eval "$2"; then echo "ok - $PLUGIN: $1"; else echo "not ok - $PLUGIN: $1"; fail=1; fi; }
# stub NAME BODY: a fake command first in the PATH (no network, no real account)
stub() { printf '#!/bin/sh\n%s\n' "$2" > "$STUB/$1"; chmod +x "$STUB/$1"; }
# in_env CMD...: run in the isolated environment
in_env() { env HOME="$HOME_T" PATH="$STUB:$PATH" XDG_RUNTIME_DIR="$T/run" FILI_BAR_OPTIONS="$T/options.toml" LOG="$LOG" "$@"; }
mkdir -p "$T/run"
stub notify-send 'echo "notify-send $*" >> "$LOG"'
printf '#!/bin/sh\necho "bar-alert $*" >> "$LOG"\n' > "$HOME_T/.local/bin/bar-alert"; chmod +x "$HOME_T/.local/bin/bar-alert"

common_checks() {
    check "manifest has a title and api = 1" 'grep -q "^title = " "$ROOT/module.toml" && grep -q "^api = 1" "$ROOT/module.toml"'
    check "config.example.toml exists" '[ -f "$ROOT/config.example.toml" ]'
    check ".gitignore keeps personal files out" 'grep -q "^config.toml" "$ROOT/.gitignore" && grep -q "^\*.url" "$ROOT/.gitignore" && grep -q "^\*.conf" "$ROOT/.gitignore"'
    bad=""
    for f in "$ROOT"/bin/* "$ROOT"/install.sh; do
        [ -f "$f" ] || continue
        if head -1 "$f" | grep -q bash; then bash -n "$f" 2> /dev/null || bad="$bad $f"; else sh -n "$f" 2> /dev/null || bad="$bad $f"; fi
    done
    check "every script parses${bad:+ (failing:$bad)}" '[ -z "$bad" ]'
    bad=""
    for f in "$ROOT"/bin/*; do
        case "$f" in */opt.sh) continue ;; esac
        [ -x "$f" ] || bad="$bad $f"
    done
    check "scripts are executable${bad:+ (not:$bad)}" '[ -z "$bad" ] && [ -x "$ROOT/install.sh" ]'
    # no personal data in the files of the repository: e-mail, home path, a non-loopback IPv4, a login
    files="$(cd "$ROOT" && { git ls-files 2> /dev/null || find . -type f -not -path "./.git/*" -not -path "./tests/*"; } | grep -v "^tests/")"
    leak="$(cd "$ROOT" && grep -nIE "[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[a-z]{2,}|/home/[a-z]|thomas|thooams|\b([1-9][0-9]?|1[0-9]{2}|2[0-4][0-9])\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b" $files 2> /dev/null | grep -v "127\.0\.0\.1" | head -3)"
    check "no personal data in the repository${leak:+ ($leak)}" '[ -z "$leak" ]'
    # install.sh: creates the options file once, asks nothing without a terminal, leaves the plugin folder alone, can run twice
    rm -f "$T/options.toml"
    before="$(cd "$ROOT" && git status --porcelain 2> /dev/null)"
    out1="$(in_env sh "$ROOT/install.sh" < /dev/null 2>&1)"; rc1=$?
    out2="$(in_env sh "$ROOT/install.sh" < /dev/null 2>&1)"; rc2=$?
    check "install.sh succeeds twice without a terminal" '[ "$rc1" = 0 ] && [ "$rc2" = 0 ]'
    check "install.sh creates the options file from the example, once" '[ -f "$T/options.toml" ] && echo "$out1" | grep -q "^options: " && ! echo "$out2" | grep -q "^options: "'
    check "install.sh leaves the plugin folder untouched" '[ "$(cd "$ROOT" && git status --porcelain 2> /dev/null)" = "$before" ]'
}
