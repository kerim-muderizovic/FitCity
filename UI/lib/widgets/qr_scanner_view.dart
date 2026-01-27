import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'common.dart';
import '../services/qr_scanner_service.dart';

class QrScannerView extends StatefulWidget {
  final QrScannerService service;
  final VoidCallback onClose;
  final void Function(String payload) onPayload;

  const QrScannerView({
    super.key,
    required this.service,
    required this.onClose,
    required this.onPayload,
  });

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  String? _lastPayload;
  bool _starting = true;

  @override
  void initState() {
    super.initState();
    widget.service.onResult(_handlePayload);
    _start();
  }

  Future<void> _start() async {
    await widget.service.start();
    if (mounted) {
      setState(() => _starting = false);
    }
  }

  @override
  void dispose() {
    widget.service.stop();
    super.dispose();
  }

  void _handlePayload(String payload) {
    setState(() => _lastPayload = payload);
    widget.onPayload(payload);
  }

  void _simulateScan() {
    widget.service.simulateScan('token-hash-1');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scan QR code'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 260,
              decoration: BoxDecoration(
                color: AppColors.slate,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accentDeep, width: 2),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      _starting ? 'Starting scanner...' : 'Camera feed placeholder',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.accent, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _lastPayload == null ? 'Point the code inside the frame.' : 'Last payload: $_lastPayload',
              style: const TextStyle(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: widget.onClose, child: const Text('Close')),
        AccentButton(label: 'Simulate scan', onPressed: _simulateScan),
      ],
    );
  }
}
