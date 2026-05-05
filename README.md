# stride_io

A new Flutter project.

## Dev GPS

StrideIO includes a hidden Dev Menu for fake GPS simulation.

How to open it:

1. Run the app in debug mode.
2. Open the Profile tab.
3. Long-press the small version footer at the bottom of the page.

What you can do there:

- Toggle fake GPS on or off.
- Edit fake route config like center, loop distance, duration, and sample interval.
- Start or stop the fake GPS stream.
- Apply presets like 5km / 30min, 5km / 5min, and 1km walk.

Release safety:

- Fake GPS is disabled by default.
- In release builds, the Dev Menu stays hidden unless you build with a compile-time flag.
- Use `--dart-define=STRIDEIO_ALLOW_DEV_MENU=true` and `--dart-define=STRIDEIO_ALLOW_FAKE_GPS=true` only for internal builds.

Verification checklist:

- Toggle persists after app restart.
- Fake mode shows `DEV: Fake GPS active` on the workout screen.
- Active workout route line moves when the fake stream is on.
- Toggling off restores the real location source.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
