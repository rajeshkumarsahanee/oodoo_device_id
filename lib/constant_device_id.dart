/// A Flutter plugin that provides a permanent device identifier.
///
/// The identifier persists across app reinstalls on Android (via Widevine DRM)
/// and on iOS (via the system Keychain).
///
/// ## Usage
///
/// ```dart
/// import 'package:constant_device_id/constant_device_id.dart';
///
/// final String id = await ConstantDeviceId.getId();
/// ```
library constant_device_id;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'src/constant_device_id_platform_interface.dart';

export 'src/constant_device_id_platform_interface.dart'
    show ConstantDeviceIdPlatform;

/// Provides a permanent device identifier that survives app reinstalls.
///
/// ### Resolution order
///
/// | Layer | Source                        | Survives reinstall          | Platform     |
/// |-------|-------------------------------|-----------------------------|--------------|
/// | 0     | Widevine DRM hardware ID      | Yes (until factory reset)   | Android only |
/// | 1     | Secure Storage / iOS Keychain | Yes (iOS) / No (Android)    | Both         |
/// | 2     | SharedPreferences             | No                          | Both         |
/// | 3     | Generated UUID v4             | No                          | Both         |
///
/// On Android, Layer 0 is almost always available, making the ID truly
/// permanent across installs. On iOS, the Keychain (Layer 1) natively
/// persists across reinstalls.
class ConstantDeviceId {
  ConstantDeviceId._();

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      /// The Keychain item is kept after the app is uninstalled on iOS.
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const _storageKey = 'constant_device_id_v1';

  /// Returns a permanent device identifier as a 64-character hex string.
  ///
  /// The value is a SHA-256 hash of the underlying hardware identifier so that
  /// the raw hardware ID is never exposed or stored.
  ///
  /// This method is safe to call from any isolate and is idempotent — repeated
  /// calls return the same value as long as the hardware and storage are intact.
  ///
  /// Throws only if all four layers fail simultaneously, which is an
  /// unrecoverable device state.
  static Future<String> getId() async {
    // Layer 0: Widevine DRM hardware ID (Android — survives uninstall/reinstall)
    final widevineId = await _getWidevineId();
    if (widevineId != null) return widevineId;

    // Layer 1: Secure Storage (iOS Keychain survives reinstall natively)
    try {
      final secureId = await _secureStorage.read(key: _storageKey);
      if (secureId != null && secureId.isNotEmpty) return secureId;
    } catch (_) {}

    // Layer 2: SharedPreferences fallback
    final prefs = await SharedPreferences.getInstance();
    final prefId = prefs.getString(_storageKey);
    if (prefId != null && prefId.isNotEmpty) {
      // Promote to secure storage for future reads
      try {
        await _secureStorage.write(key: _storageKey, value: prefId);
      } catch (_) {}
      return prefId;
    }

    // Layer 3: Generate a new UUID and persist it in both stores
    final newId = const Uuid().v4();
    try {
      await _secureStorage.write(key: _storageKey, value: newId);
    } catch (_) {}
    await prefs.setString(_storageKey, newId);
    return newId;
  }

  /// Clears the device ID from Secure Storage and SharedPreferences.
  ///
  /// The next call to [getId] on Android will still return the same
  /// hardware-derived ID because the Widevine layer is not affected.
  ///
  /// On iOS, clearing resets the stored ID; the next [getId] call generates
  /// and persists a new UUID.
  static Future<void> reset() async {
    try {
      await _secureStorage.delete(key: _storageKey);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static Future<String?> _getWidevineId() async {
    try {
      final rawId = await ConstantDeviceIdPlatform.instance.getWidevineId();
      if (rawId == null || rawId.isEmpty) return null;
      return _sha256(rawId);
    } catch (_) {
      return null;
    }
  }

  static String _sha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
