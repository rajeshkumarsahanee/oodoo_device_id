# Changelog

All notable changes to this package are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [0.1.0] — 2026-03-16

### Added
- Initial release.
- `ConstantDeviceId.getId()` — returns a permanent, privacy-safe device identifier.
- `ConstantDeviceId.reset()` — clears locally stored ID from Secure Storage and SharedPreferences.
- **Layer 0 — Widevine DRM** (Android): hardware-bound ID that survives app uninstall and reinstall. SHA-256 hashed before use.
- **Layer 1 — Secure Storage / iOS Keychain**: encrypted storage that persists across reinstalls on iOS.
- **Layer 2 — SharedPreferences**: lightweight fallback with automatic promotion to secure storage.
- **Layer 3 — UUID v4 generation**: last-resort ID generated once and persisted to both stores.
- Android minimum SDK: 21 (Android 5.0 Lollipop).
- iOS minimum version: 12.0.
- Full unit-test suite with mock platform implementations.
- Example app demonstrating basic usage.
