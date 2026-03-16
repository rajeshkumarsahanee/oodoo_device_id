import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'constant_device_id_platform_interface.dart';

/// The default [ConstantDeviceIdPlatform] implementation using a [MethodChannel].
class MethodChannelConstantDeviceId extends ConstantDeviceIdPlatform {
  /// The method channel used to communicate with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('constant_device_id');

  @override
  Future<String?> getWidevineId() async {
    return methodChannel.invokeMethod<String>('getWidevineId');
  }
}
