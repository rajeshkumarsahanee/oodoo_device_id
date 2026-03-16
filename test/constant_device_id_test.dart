import 'package:constant_device_id/constant_device_id.dart';
import 'package:constant_device_id/src/constant_device_id_method_channel.dart';
import 'package:constant_device_id/src/constant_device_id_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Mock platform that simulates a successful Widevine response
// ---------------------------------------------------------------------------
class _MockWithWidevine extends ConstantDeviceIdPlatform {
  @override
  Future<String?> getWidevineId() async => 'mock-widevine-base64-id';
}

// Mock platform that simulates a device without Widevine (e.g., emulator / iOS)
class _MockWithoutWidevine extends ConstantDeviceIdPlatform {
  @override
  Future<String?> getWidevineId() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConstantDeviceIdPlatform', () {
    test('default instance is MethodChannelConstantDeviceId', () {
      expect(
        ConstantDeviceIdPlatform.instance,
        isA<MethodChannelConstantDeviceId>(),
      );
    });
  });

  group('ConstantDeviceId.getId() — with Widevine', () {
    setUp(() => ConstantDeviceIdPlatform.instance = _MockWithWidevine());

    test('returns a non-empty string', () async {
      final id = await ConstantDeviceId.getId();
      expect(id, isNotEmpty);
    });

    test('returns a 64-character lowercase hex string (SHA-256)', () async {
      final id = await ConstantDeviceId.getId();
      expect(id.length, 64);
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(id), isTrue);
    });

    test('is deterministic — same Widevine input yields same output', () async {
      final id1 = await ConstantDeviceId.getId();
      final id2 = await ConstantDeviceId.getId();
      expect(id1, equals(id2));
    });
  });

  group('ConstantDeviceId.getId() — without Widevine (fallback layers)', () {
    setUp(() => ConstantDeviceIdPlatform.instance = _MockWithoutWidevine());

    test('still returns a non-empty string via fallback', () async {
      final id = await ConstantDeviceId.getId();
      expect(id, isNotEmpty);
    });
  });
}
