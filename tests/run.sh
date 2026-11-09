#!/bin/sh
# Tests of the whatsapp plugin: no network and no real account (the external commands are stubs). Usage: tests/run.sh
PLUGIN=whatsapp
. "$(dirname "$0")/common.sh"

common_checks
# the unread counter of the daemon reaches the file read by the bar
stub socat 'printf "3\n4\n"'
( set -m; in_env timeout 2 "$ROOT/bin/wa-count" > /dev/null 2>&1 ) 2> /dev/null
check "wa-count writes the last unread count" '[ "$(cat "$HOME_T/.local/state/alerts/whatsapp.count" 2> /dev/null)" = 4 ]'
check "wa-daemon starts the counter from its own folder" 'grep -q "dirname \"\$(readlink -f \"\$0\")\")/wa-count" "$ROOT/bin/wa-daemon"'
check "wa-daemon waits for the pairing" 'grep -q "whatsapp-unread/paired" "$ROOT/bin/wa-daemon"'
check "install-daemon pins a commit" 'grep -Eq "^COMMIT=\"[0-9a-f]{40}\"" "$ROOT/bin/install-daemon"'
check "install.sh asks for the pairing only when it is missing" 'grep -q "wa-pair" "$ROOT/install.sh" && grep -q "paired" "$ROOT/install.sh"'
check "manifest autostarts the daemons" 'grep -q "^autostart = .*wa-daemon" "$ROOT/module.toml"'

check "extras: the fallback app menu is valid JSON" 'for f in "$ROOT"/extras/config/filigrane/appmenu/*.json; do jq -e .menus "$f" > /dev/null || exit 1; done'
check "extras: no personal data" '! grep -rEiq "@[a-z0-9-]+[.][a-z]|/home/[a-z]" "$ROOT/extras"'

exit "$fail"
