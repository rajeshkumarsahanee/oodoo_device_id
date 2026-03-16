import 'package:constant_device_id/constant_device_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'constant_device_id Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const DeviceIdScreen(),
    );
  }
}

class DeviceIdScreen extends StatefulWidget {
  const DeviceIdScreen({super.key});

  @override
  State<DeviceIdScreen> createState() => _DeviceIdScreenState();
}

class _DeviceIdScreenState extends State<DeviceIdScreen> {
  String? _deviceId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchId();
  }

  Future<void> _fetchId() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final id = await ConstantDeviceId.getId();
      setState(() {
        _deviceId = id;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _copyId() async {
    if (_deviceId == null) return;
    await Clipboard.setData(ClipboardData(text: _deviceId!));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device ID copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('constant_device_id'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _loading
              ? const CircularProgressIndicator()
              : _error != null
                  ? _ErrorView(error: _error!, onRetry: _fetchId)
                  : _IdView(
                      deviceId: _deviceId!,
                      onCopy: _copyId,
                      onRefresh: _fetchId,
                    ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _IdView extends StatelessWidget {
  final String deviceId;
  final VoidCallback onCopy;
  final VoidCallback onRefresh;

  const _IdView({
    required this.deviceId,
    required this.onCopy,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.fingerprint, size: 72, color: cs.primary),
        const SizedBox(height: 24),
        const Text(
          'Permanent Device ID',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Persists across app reinstalls',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SelectableText(
            deviceId,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: cs.onPrimaryContainer,
              letterSpacing: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: onCopy,
              icon: const Icon(Icons.copy),
              label: const Text('Copy'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        Text(error, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
