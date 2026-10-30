# Sprintur

An open source sprint timer. Running apps track distance with GPS, but a
30 m sprint is over before GPS settles. Sprintur works from a distance you
measure out with cones: it beeps the start, beeps each split at your target
pace, times the rep, and runs your rest.

No account and no server. Everything stays on the phone, with backups to a
file you control.

## Features

- Timed reps with a target time, rest, and split beeps at each cone
- Marks, set, and a random go to train reaction, with false start detection
- Auto finish on the target beep, or a partner taps the finish line
- Keeps running with the screen off, and plays over your music
- History, personal bests, weekly totals, and effort ratings
- JSON backup and restore that merges by id, weekly auto backup, CSV export
- Training reminders and new personal best alerts
- Home screen widgets on Android and iOS, and the live session on the iOS
  lock screen
- Three beep sounds

## Build

Requires Flutter 3.44 or later.

```bash
flutter pub get
flutter run
```

No keys or config to set up. After changing the database tables, regenerate
the drift code:

```bash
dart run build_runner build
```

Tests:

```bash
flutter test
```

On iOS, the widgets and the lock screen view need a signing team in Xcode
so the app and the widget extension can share the
`group.com.livinlabs.sprintur` app group.

## Releases

CI runs the analyzer, the tests, and Android and iOS builds on every push.
Pushing a tag such as `v1.1.0` builds a signed APK and AAB and publishes them
as a GitHub release; the app's update check reads that release.

Release builds need an upload keystore in two repository secrets:
`SPRINTUR_KEYSTORE_BASE64` (the `.jks` file, base64) and
`SPRINTUR_KEYSTORE_PASSWORD`. The key alias defaults to `sprintur` and its
password to the store's; `SPRINTUR_KEY_ALIAS` and `SPRINTUR_KEY_PASSWORD`
override them. Locally, put the same values
in `android/key.properties` (`storeFile`, `storePassword`, `keyAlias`,
`keyPassword`); it is ignored by git.

## Network use

The only network call is a daily check of this repository's latest GitHub
release, so the app can say when an update is out. Settings can turn it off.

## License

MIT. Barlow Condensed is under the SIL Open Font License
(`assets/fonts/OFL.txt`).
