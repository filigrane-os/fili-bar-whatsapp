# whatsapp (fili-bar plugin)

Unread WhatsApp counter in the Filigrane bar, without a browser: `whatsapp-unreadd` (Go daemon, ~23 MB) feeds `wa-count`, which writes the counter the bar reads. A click opens the web app.

```sh
fili-bar install https://github.com/filigrane-os/fili-bar-whatsapp
~/.local/share/filigrane/bar/plugins/whatsapp/bin/install-daemon   # builds the pinned daemon
foot -e ~/.local/share/filigrane/bar/plugins/whatsapp/bin/wa-pair   # once: scan the QR code
```

Start `bin/wa-daemon` at login (niri `spawn-at-startup`). The pairing is stored in `~/.config/whatsapp-unread/`, outside this repository.

## Personal data

None in this repository. Options (none yet) would go in `~/.config/filigrane/bar/whatsapp.toml`; `config.example.toml` documents the format.
