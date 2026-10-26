# music-trainer.app

Front page and nginx config for [music-trainer.app](https://music-trainer.app), which hosts three free, browser-based apps:

- [Chord Trainer](https://github.com/nvlass/chordtrainer) at `/chordtrainer/`
- [Counterpointer](https://github.com/nvlass/counterpointer) at `/counterpointer/`
- [Dicteeineer](https://github.com/nvlass/dicteeineer) at `/dicteeineer/`
- [Harmoneer](https://github.com/nvlass/harmoneer) at `/harmoneer/`

The front page is a single static `index.html` + `style.css` (English and Greek, picked from the browser language, with a toggle). No build step.

## Server layout

| URL | Folder |
|---|---|
| `/` | `/var/www/html/music-trainer.app/` (this repo) |
| `/chordtrainer/` | `/var/www/html/megacorp1.eu/chordtrainer/` |
| `/counterpointer/` | `/var/www/html/megacorp1.eu/counterpointer/` |
| `/dicteeineer/` | `/var/www/html/megacorp1.eu/dicteeineer/` |
| `/harmoneer/` | `/var/www/html/megacorp1.eu/harmoneer/` |

The apps use relative paths throughout, so they work under a path without changes. Each one's service worker is scoped to its own folder.

## Deploy

`./deploy.sh` rsyncs the front page and each app's committed `dist/` to the server (all of them, or the ones named: `./deploy.sh harmoneer front`). It expects the app repos next to this one and an ssh host called `server`; override with `SERVER=… WORK=…`. It refuses to deploy an app with uncommitted changes in `src/`, `resources/` or `dist/`.

Front page by hand:

```sh
rsync -a --delete --exclude '.git' --exclude 'nginx' --exclude 'README.md' ./ server:/var/www/html/music-trainer.app/
```

nginx:

```sh
sudo mkdir -p /var/www/html/music-trainer.app
sudo cp nginx/music-trainer.app.conf /etc/nginx/sites-available/music-trainer.app
sudo ln -s /etc/nginx/sites-available/music-trainer.app /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d music-trainer.app -d www.music-trainer.app
```

Everything is served `no-cache` (the browser revalidates, so deploys show up at once) except the piano samples, which never change.

Moving from the old subdomains: progress is stored per origin (IndexedDB), so it doesn't carry over to the new domain. Users can export stats from the old address (Chord Trainer has export/import).

## License

MIT, see [LICENSE](LICENSE).
