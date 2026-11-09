#!/bin/sh
# First-run setup, run by `fili-bar install` / `fili-bar setup` / `fili-bar sync`. Idempotent; asks questions only on a terminal.
# Secrets never go in this folder: they go to the keyring or to a file under ~/.config.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
opts="${FILI_BAR_OPTIONS:-$HOME/.config/filigrane/bar/whatsapp.toml}"
tty=0; [ -t 0 ] && tty=1
# Options file: copy the example once, never overwrite
if [ ! -e "$opts" ] && [ -f "$here/config.example.toml" ]; then
    mkdir -p "$(dirname "$opts")" && cp "$here/config.example.toml" "$opts" && echo "options: $opts (edit it to change the defaults)"
fi
# 1. the daemon (Go, pinned commit)
command -v whatsapp-unreadd >/dev/null 2>&1 || "$here/bin/install-daemon" || exit 1
# 2. the pairing (once)
if [ ! -e "$HOME/.config/whatsapp-unread/paired" ]; then
    if [ "$tty" = 1 ]; then
        printf 'Pair WhatsApp now (QR code to scan)? [Y/n] '; read -r a
        case "$a" in n* | N*) echo "later: foot -e $here/bin/wa-pair" ;; *) "$here/bin/wa-pair" ;; esac
    else
        echo "pairing needed: foot -e $here/bin/wa-pair"
    fi
fi
