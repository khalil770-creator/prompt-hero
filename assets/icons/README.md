# App Icon Assets

Place the following files in this directory before running `flutter pub run flutter_launcher_icons`:

## Required files

- `app_icon.png` — 1024×1024 PNG, the main app icon. Used for Android, iOS, and Web.
- `app_icon_foreground.png` — 1024×1024 PNG, the foreground layer for Android adaptive icons (the logo/symbol part, with transparent background). The background colour is set to `#4F46E5` (indigo) in `pubspec.yaml`.

## Generating icons

After placing both PNG files here, run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This will overwrite the platform icon assets under `android/`, `ios/`, and `web/`.

## Design notes

- Keep important content within the central 66% of the image (safe zone for adaptive icons).
- Use a white or light-coloured foreground against the `#4F46E5` indigo background for best contrast.
- Suggested design: white "PH" monogram or a stylised lightning-bolt/sparkle icon on indigo.
