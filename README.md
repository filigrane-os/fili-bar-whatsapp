# whatsapp (fili-bar plugin)

Unread WhatsApp counter in the Filigrane bar, without a browser: `whatsapp-unreadd` (Go daemon, ~23 MB) feeds `wa-count`, which writes the counter the bar reads. A click opens the web app.

```sh
fili-bar install https://github.com/filigrane-os/fili-bar-whatsapp
~/.local/share/filigrane/bar/plugins/whatsapp/bin/install-daemon   # builds the pinned daemon
foot -e ~/.local/share/filigrane/bar/plugins/whatsapp/bin/wa-pair   # once: scan the QR code
```

The daemon starts at login by itself (`autostart` in `module.toml`, run by niri through `fili-bar autostart`).

`fili-bar install` also runs `install.sh`: it creates your options file from `config.example.toml`, asks for what is missing (credentials go to the keyring or to a file under `~/.config`, never to this folder) and prints what is left to do. Run it again with `fili-bar setup whatsapp`; it is safe to repeat.

## Packages

Declared in `module.toml` (`packages`), installed by `fili-bar install --yes`: `socat` (relay) and `go` (build only, ~217 MB on disk, nothing resident).

## Personal data

None in this repository. Options (none yet) would go in `~/.config/filigrane/bar/whatsapp.toml`; `config.example.toml` documents the format.

## Tests

```sh
sh tests/run.sh
```

No network and no real account: the external commands (`notify-send`, `secret-tool`, `rclone`, `ip`...) are stubs and `HOME` is a temporary folder. The checks every plugin passes (manifest, scripts parse, no personal data in the repository, `install.sh` idempotent) are in `tests/common.sh`; GitHub Actions runs them on each push.
