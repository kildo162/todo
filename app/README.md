# app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
LAN discovery
------------
This app now attempts a quick LAN service discovery at startup using UDP multicast. If a local "user-service" is found (responds to discovery request), the app will use the discovered `http://<ip>:<port>` as the API base URL. Otherwise it falls back to `https://api.khanhnd.com` (or the `BASE_URL` passed at build-time).

To override or test manually:

```bash
cd app
# optionally set custom BASE_URL
flutter run --dart-define=BASE_URL="https://api.khanhnd.com"
```

- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
