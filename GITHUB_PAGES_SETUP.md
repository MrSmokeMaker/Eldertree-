# GitHub Pages Setup

The app is published from the **`gh-pages` branch** (Settings → Pages → Source →
"Deploy from a branch" → `gh-pages` / `root`).

- Repository: <https://github.com/MrSmokeMaker/Eldertree-> (trailing dash!)
- Live URL: <https://mrsmokemaker.github.io/Eldertree-/>

## Why the base href matters

The repository name contains a trailing dash, so GitHub Pages serves the site
from `/Eldertree-/`. Every build must use exactly that prefix:

```
flutter build web --release --base-href /Eldertree-/
```

With a wrong base href (`/Eldertree/` without the dash) the browser asks for
`/Eldertree/main.dart.js`, gets a 404 from GitHub Pages and the app never boots —
only an empty page (or Flutter's grey release `ErrorWidget`) is visible.
`build_web.bat` verifies the generated `index.html` and fails the build if the
base href is wrong.

## Supabase credentials

The app needs `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` (the `sb_publishable_…`
client key; `SUPABASE_ANON_KEY` is accepted as a legacy alias). The publishable key
is public by design — it ships inside the web bundle, and the data is protected by
Row Level Security, not by hiding it. Never put a `service_role` key in the client.

Pass the values at build time:

```
set SUPABASE_URL=https://<project>.supabase.co
set SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
build_web.bat
```

or on any platform:

```
flutter build web --release --base-href /Eldertree-/ \
  --dart-define=SUPABASE_URL=https://<project>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
```

`--dart-define` wins over the `.env` file (`.env` is the template declared in
`pubspec.yaml`, served at runtime as `assets/.env`). If neither is set, the app
still starts and shows a configuration screen with these instructions instead of a
blank page.

## Deploying

1. `build_web.bat` (or the `flutter build web` command above).
2. Copy the contents of `build/web/` to the **root** of the `gh-pages` branch
   (the branch stores the compiled site, not only the sources).
3. Commit and push `gh-pages`.
4. Wait for the Pages build, then hard-reload the site (Ctrl+F5): the old service
   worker or HTTP cache may still serve the previous bundle.

## Local check before publishing

```
python -m http.server 8080
```

The site is built for the `/Eldertree-/` prefix, so serve it and open
<http://127.0.0.1:8080/Eldertree-/> — or use any static server that maps
`/Eldertree-/*` onto `build/web`.

## Troubleshooting

| Symptom | Cause |
| --- | --- |
| Blank / grey page, console shows `Null check operator used on a null value` | A widget branch was mounted outside `MaterialApp` (no `Directionality`). The first frame fails and Flutter renders its grey release `ErrorWidget`. |
| `404` for `main.dart.js`, `flutter.js` | Base href does not match the repository name. |
| "Eldertree не настроен" screen | `SUPABASE_URL` / `SUPABASE_ANON_KEY` are missing; rebuild with `--dart-define`. |
| Old version keeps loading after a deploy | Service worker / HTTP cache; hard reload or clear site data. |
| `This project is not configured for the web` | The `web/` template folder is missing from the checked out branch. |
