import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'constant_device_id_method_channel.dart';

/// The interface that platform-specific implementations must implement.
///
/// Platform implementations should extend this class rather than implement
/// it, as new methods may be added in minor versions without breaking changes.
abstract class ConstantDeviceIdPlatform extends PlatformInterface {
  ConstantDeviceIdPlatform() : super(token: _token);

  static final Object _token = Object();

  static ConstantDeviceIdPlatform _instance = MethodChannelConstantDeviceId();

  /// The default instance of [ConstantDeviceIdPlatform] to use.
  ///
  /// Defaults to [MethodChannelConstantDeviceId].
  static ConstantDeviceIdPlatform get instance => _instance;

  /// Sets a custom [ConstantDeviceIdPlatform] implementation.
  ///
  /// Platform-specific implementations should call this when they register
  /// themselves. Tests may also set a mock implementation here.
  static set instance(ConstantDeviceIdPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the raw Base64-encoded Widevine DRM device unique ID, or `null`
  /// if unavailable (e.g., on iOS, emulators, or devices without DRM support).
  Future<String?> getWidevineId() {
    throw UnimplementedError('getWidevineId() has not been implemented.');
  }
}
