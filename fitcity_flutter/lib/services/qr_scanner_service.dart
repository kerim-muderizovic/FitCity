import 'dart:async';

class QrScannerService {
  final List<void Function(String payload)> _listeners = [];
  bool _running = false;

  bool get isRunning => _running;

  Future<void> start() async {
    _running = true;
    // TODO: Hook up camera start + QR detection here.
  }

  Future<void> stop() async {
    _running = false;
    // TODO: Stop camera stream here.
  }

  void onResult(void Function(String payload) callback) {
    _listeners.add(callback);
  }

  void simulateScan(String payload) {
    for (final listener in List.of(_listeners)) {
      listener(payload);
    }
  }
}
