# Cross-Folder Media Viewer

A static web viewer for browsing photos and movies kept across multiple folders, filterable by folder name. Styling is handled by [Simple.css](https://simplecss.org/) and follows the OS light/dark setting.

[日本語版はこちら](README.ja.md)

## How it works

1. Place the files from this repository in the folder that holds your photos and movies.
2. Build `media.json`, an index of every photo/movie found (dotfiles and dot-folders are skipped). Re-run this whenever files are added or removed:
   - Windows: double-click `update.bat` (runs `update.ps1`).
   - Mac/Linux: run `update.sh` (runs `update.py`; requires Python 3).
3. Serve that folder over HTTP (e.g. a NAS's static web server).
4. Open `view.html` in a browser.

Most browsers can't read `media.json` over `file://`; open the folder over HTTP instead.

## Features

- Recursively indexes photos and movies under the folder.
- Filter by type (photo/movie), by folder name, and by file extension (every extension starts checked; uncheck one to hide files your browser can't render).
- Selected folder names are shown at the top; they are removed from the remaining folder buttons.
- Items that fail to load can be hidden with a button (placed below the filters).
- Galleries over 300 items show a warning instead of rendering by default; a button lets you force-show them anyway.
- The entry point script keeps its window open (pause on exit) and writes its output to `update.log`.

## Files

| File | Role |
|---|---|
| `view.html` | The viewer: markup and logic |
| `update.bat` | Windows entry point; runs `update.ps1` and pauses so you can read the output |
| `update.ps1` | Builds `media.json` on Windows |
| `update.sh` | Mac/Linux entry point; runs `update.py` and pauses so you can read the output |
| `update.py` | Builds `media.json` on Mac/Linux (requires Python 3) |
| `media.json` | Generated index (path, kind, extension); created by the entry point script, not included in this repository |
| `update.log` | Generated log from the last entry point script run |
| `simple.min.css` | Styling; not included, see below |

## Getting Simple.css

`view.html` expects a `simple.min.css` file next to it, but it is not included in this repository. Either:

- Download it from the [Simple.css repository](https://github.com/kevquirk/simple.css) and place it next to `view.html`, or
- Change the `<link>` tag in `view.html` to point at the CDN instead: `https://cdn.simplecss.org/simple.min.css`.

## License

MIT — see [LICENSE](LICENSE).
