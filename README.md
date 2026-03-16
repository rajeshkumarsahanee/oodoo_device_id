# constant_device_id

[![pub.dev](https://img.shields.io/pub/v/constant_device_id.svg)](https://pub.dev/packages/constant_device_id)
[![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios-blue.svg)](https://pub.dev/packages/constant_device_id)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin that provides a **permanent device identifier** that persists across app reinstalls.

On **Android**, the identifier is derived from the hardware-level **Widevine DRM ID** a cryptographically unique value bound to the device at manufacture time. On **iOS**, the identifier is stored in the **system Keychain**, which Apple preserves across app reinstalls by default.


## Features

- Survives app uninstall and reinstall on both platforms
- Hardware backed on Android via Widevine DRM (L1 / L3)
- Keychain backed on iOS no extra configuration required
- SHA-256 hashed output raw hardware IDs are never exposed
- Four layer fallback for maximum reliability on edge case devices
- No Android permissions required
- Android 5.0+ (API 21) and iOS 12.0+ support


## How It Works

`ConstantDeviceId.getId()` resolves the identifier through four layers in order, returning as soon as one succeeds:

| Layer | Source                          | Survives Reinstall          | Platform     |
|-------|---------------------------------|-----------------------------|--------------|
| 0     | Widevine DRM hardware ID        | ✅ Yes (until factory reset) | Android only |
| 1     | Secure Storage / iOS Keychain   | ✅ Yes (iOS) / ❌ No (Android) | Both       |
| 2     | SharedPreferences               | ❌ No                        | Both         |
| 3     | Generated UUID v4               | ❌ No                        | Both         |

On a normal Android device **Layer 0 is always reached**, making the ID truly permanent. On iOS, **Layer 1 (Keychain)** natively persists across reinstalls so the ID is equally stable.


## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  constant_device_id: ^0.1.0
```

Then fetch packages:

```bash
flutter pub get
```


## Platform Setup

### Android

No additional setup is required. The Widevine DRM API does not need any `AndroidManifest.xml` permissions.

**Minimum SDK:** 21 (Android 5.0 Lollipop)

### iOS

No additional setup is required. The plugin uses `flutter_secure_storage` under the hood, which uses the iOS Keychain with `first_unlock` accessibility — items are retained after an app is deleted and reinstalled.

**Minimum iOS version:** 12.0


## Usage

### Get the permanent device ID

```dart
import 'package:constant_device_id/constant_device_id.dart';

final String deviceId = await ConstantDeviceId.getId();
print(deviceId);
// e.g. "a3f2c1d4e5b6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2"
```

The returned value is a **64-character lowercase hex string** (SHA-256 hash), consistent across every call on the same device.

### Reset locally stored ID

```dart
await ConstantDeviceId.reset();
```

Clears the ID from Secure Storage and SharedPreferences. On Android, the next call to `getId()` still returns the same hardware-derived ID because the Widevine layer is not affected by this operation.


## API Reference

### `ConstantDeviceId.getId()` → `Future<String>`

Returns the permanent device identifier.

- **Thread-safe** and idempotent — safe to call multiple times concurrently.
- Never throws under normal conditions; falls through all layers gracefully.
- Return format: 64-character SHA-256 hex string.

### `ConstantDeviceId.reset()` → `Future<void>`

Clears Layers 1 and 2 (Secure Storage + SharedPreferences).

> **Note:** On Android, Layer 0 (Widevine) is hardware derived and cannot be reset programmatically. Calling `getId()` after `reset()` will return the same ID on Android.


## When Does the ID Change?

Understanding the failure modes helps you design your system accordingly.

### Android

| Scenario | ID changes? |
|---|---|
| App uninstall + reinstall | No Widevine persists |
| App update | No |
| Clear app data (Settings → App → Clear Data) | No Widevine persists |
| Factory reset | **Yes** — DRM keys are wiped |
| System update re-provisioning DRM | **Rarely** OEM-specific |
| Rooted device with tampered DRM | **Yes** |
| Emulator | **Yes** Widevine unavailable; falls back to UUID |

### iOS

| Scenario | ID changes? |
|---|---|
| App uninstall + reinstall | No — Keychain persists |
| App update | No |
| Factory reset / device erase | **Yes** |
| User manually clears Keychain | **Yes** |
| Restore to a different device | **Yes** |


## Privacy

The raw Widevine hardware ID is **never stored or transmitted**. It is immediately hashed with **SHA-256** before use, making it impossible to reverse engineer the underlying hardware identifier from the output value.


## Example App

A full example is available in the [`example/`](example/) directory.

```bash
cd example
flutter run
```


## Contributing

Issues and pull requests are welcome at the [GitHub repository](https://github.com/your-org/constant_device_id).

Please ensure new code:
- Passes `flutter analyze`
- Is covered by unit tests
- Follows the existing code style


## License

[MIT License](LICENSE) © 2026 Your Organization
