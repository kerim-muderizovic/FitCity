import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../utils/error_mapper.dart';
import 'package:flutter/services.dart';
import 'package:webview_windows/webview_windows.dart';
import '../data/fitcity_models.dart';
import '../theme/app_theme.dart';

class AdminQrScannerView extends StatefulWidget {
  final VoidCallback onClose;
  final Future<QrScanResult> Function(String payload) onScan;

  const AdminQrScannerView({
    super.key,
    required this.onClose,
    required this.onScan,
  });

  @override
  State<AdminQrScannerView> createState() => _AdminQrScannerViewState();
}

class AlwaysOnQrScannerPanel extends StatefulWidget {
  final Future<QrScanResult> Function(String payload) onScan;

  const AlwaysOnQrScannerPanel({
    super.key,
    required this.onScan,
  });

  @override
  State<AlwaysOnQrScannerPanel> createState() => _AlwaysOnQrScannerPanelState();
}

class _AlwaysOnQrScannerPanelState extends State<AlwaysOnQrScannerPanel> with WidgetsBindingObserver {
  final WebviewController _controller = WebviewController();
  StreamSubscription? _messageSub;
  Timer? _resetTimer;
  Timer? _readyTimeout;
  HttpServer? _server;
  bool _pageReady = false;
  bool _serverHealthy = false;
  bool _initialized = false;
  bool _autoStarted = false;
  bool _processing = false;
  bool _paused = false;
  bool _autoPaused = false;
  bool _showSuccess = false;
  String? _error;
  String? _status;
  String? _lastPayload;
  DateTime? _lastPayloadAt;
  double? _videoAspectRatio;
  String? _debugInfo;
  String? _lastIgnoreReason;
  bool _receivedScan = false;
  bool _showDebug = false;

  static const Duration _successDuration = Duration(seconds: 6);
  static const Duration _debounceWindow = Duration(seconds: 10);

  Map<String, dynamic>? _decodeMessage(dynamic message) {
    if (message is Map) {
      return Map<String, dynamic>.from(message as Map);
    }
    if (message is String) {
      try {
        final decoded = jsonDecode(message);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String? _extractMemberToken(String payload, BuildContext context, void Function(String) onError) {
    final trimmed = payload.trim();
    if (trimmed.isEmpty) {
      onError(context.l10n.adminScannerInvalidQr);
      return null;
    }
    if (trimmed.startsWith('fitcity://')) {
      final uri = Uri.tryParse(trimmed);
      if (uri == null) {
        onError(context.l10n.adminScannerInvalidQr);
        return null;
      }
      if (uri.host == 'entry') {
        onError(context.l10n.adminScannerEntryQr);
        return null;
      }
      if (uri.host == 'member') {
        final token = uri.queryParameters['token']?.trim();
        if (token == null || token.isEmpty) {
          onError(context.l10n.adminScannerMemberTokenMissing);
          return null;
        }
        return token;
      }
      onError(context.l10n.adminScannerInvalidQr);
      return null;
    }
    if (RegExp(r'^[a-fA-F0-9]{32}$').hasMatch(trimmed)) {
      return trimmed;
    }
    onError(context.l10n.adminScannerInvalidQr);
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initWebview();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _autoPaused = true;
      _execIfReady('stopScan();');
    } else if (state == AppLifecycleState.resumed && !_paused && _autoPaused) {
      _autoPaused = false;
      _execIfReady('startScan();');
    }
  }

  Future<void> _initWebview() async {
    await _controller.initialize();
    _controller.setBackgroundColor(Colors.black);
    _messageSub = _controller.webMessage.listen(_handleMessage);
    final url = await _startLocalServer();
    _serverHealthy = await _healthCheck(url);
    await _controller.loadUrl(url.toString());
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _initialized = true);
    }
    _scheduleReadyFallback();
    _startCameraIfReady();
  }

  Future<Uri> _startLocalServer() async {
    if (_server != null) {
      return Uri.parse('http://127.0.0.1:${_server!.port}/admin_scanner.html?compact=1');
    }
    final html = await rootBundle.loadString('assets/qr_scanner/admin_scanner.html');
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((request) {
      request.response.headers.set('Cache-Control', 'no-store');
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      if (request.uri.path == '/' || request.uri.path == '/admin_scanner.html') {
        request.response.headers.contentType = ContentType.html;
        request.response.write(html);
      } else if (request.uri.path == '/health') {
        request.response.headers.contentType = ContentType.text;
        request.response.write('ok');
      } else {
        request.response.statusCode = HttpStatus.notFound;
      }
      request.response.close();
    });
    return Uri.parse('http://127.0.0.1:${_server!.port}/admin_scanner.html?compact=1');
  }

  Future<bool> _healthCheck(Uri url) async {
    try {
      final client = HttpClient();
      final healthUrl = Uri.parse('${url.scheme}://${url.host}:${url.port}/health');
      final request = await client.getUrl(healthUrl);
      final response = await request.close();
      await response.drain();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resetTimer?.cancel();
    _readyTimeout?.cancel();
    _messageSub?.cancel();
    _server?.close(force: true);
    _controller.dispose();
    super.dispose();
  }

  void _handleMessage(dynamic message) {
    try {
      final decoded = _decodeMessage(message);
      if (decoded == null) {
        return;
      }
      final type = decoded['type']?.toString();
      if (type == 'scan') {
        final payload = decoded['value']?.toString() ?? '';
        setState(() {
          _receivedScan = true;
          _debugInfo = _debugLine(payload, decoded);
        });
        final token = _extractMemberToken(payload, context, (message) {
          _lastIgnoreReason = message;
          _showError(message);
        });
        if (token == null) {
          return;
        }
        _handlePayload(token);
      } else if (type == 'ready') {
        setState(() => _pageReady = true);
        _startCameraIfReady();
      } else if (type == 'status') {
        setState(() => _status = decoded['message']?.toString());
      } else if (type == 'debug') {
        setState(() => _debugInfo = _debugLine(_lastPayload ?? '', decoded));
      } else if (type == 'aspect') {
        final value = decoded['value'];
        final ratio = value is num ? value.toDouble() : null;
        if (ratio != null && ratio > 0) {
          setState(() => _videoAspectRatio = ratio);
        }
      } else if (type == 'error') {
        final message = decoded['message']?.toString() ?? 'Camera error.';
        setState(() => _error = message);
      }
    } catch (_) {
      // Ignore malformed messages.
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    setState(() => _error = message);
    if (!_paused) {
      _execIfReady('startScan();');
    }
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(
    String url,
    WebviewPermissionKind kind,
    bool isUserInitiated,
  ) async {
    if (kind == WebviewPermissionKind.camera) {
      return WebviewPermissionDecision.allow;
    }
    if (kind == WebviewPermissionKind.microphone) {
      return WebviewPermissionDecision.deny;
    }
    return WebviewPermissionDecision.none;
  }

  Future<void> _handlePayload(String payload) async {
    if (_processing || _paused) {
      return;
    }
    final now = DateTime.now();
      if (_lastPayload == payload &&
        _lastPayloadAt != null &&
        now.difference(_lastPayloadAt!) < _debounceWindow) {
      _lastIgnoreReason = context.l10n.adminScannerDuplicate;
      _showError(context.l10n.adminScannerDuplicate);
      return;
    }
    _lastPayload = payload;
    _lastPayloadAt = now;

    setState(() {
      _processing = true;
      _error = null;
      _showSuccess = false;
      _lastIgnoreReason = null;
    });
    try {
      await _controller.executeScript('stopScan();');
    } catch (_) {}
    QrScanResult result;
    try {
      result = await widget.onScan(payload);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _processing = false);
      _showError(mapApiError(context, error));
      return;
    }
    if (!mounted) {
      return;
    }
    if (result.entered) {
      setState(() => _showSuccess = true);
      _resetTimer?.cancel();
      _resetTimer = Timer(_successDuration, () async {
        if (!mounted) {
          return;
        }
        setState(() {
          _showSuccess = false;
          _processing = false;
        });
        if (!_paused) {
          await _execIfReady('startScan();');
        }
      });
      return;
    }
    setState(() {
      _error = result.reason.isNotEmpty ? result.reason : context.l10n.commonTryAgain;
      _processing = false;
    });
    await _execIfReady('startScan();');
  }

  Future<void> _execIfReady(String script) async {
    if (!_initialized || !_pageReady) {
      return;
    }
    await _controller.executeScript(script);
  }

  void _scheduleReadyFallback() {
    _readyTimeout?.cancel();
    _readyTimeout = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted || _pageReady) {
        return;
      }
      _startCameraIfReady(force: true);
    });
  }

  Future<void> _startCameraIfReady({bool force = false}) async {
    if (_autoStarted) {
      return;
    }
    if (!_initialized || !_serverHealthy) {
      return;
    }
    if (!_pageReady && !force) {
      return;
    }
    _autoStarted = true;
    await Future.delayed(const Duration(milliseconds: 200));
    await _controller.executeScript('initCamera();');
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    if (_paused) {
      _execIfReady('stopScan();');
    } else {
      _execIfReady('startScan();');
    }
  }

  String _statusLabel(BuildContext context) {
    if (_paused) {
      return context.l10n.adminScannerStatusPaused;
    }
    if (_showSuccess) {
      return context.l10n.adminScannerStatusSuccess;
    }
    if (_error != null) {
      return context.l10n.adminScannerStatusError;
    }
    if (_processing) {
      return context.l10n.adminScannerStatusScanning;
    }
    return context.l10n.adminScannerStatusIdle;
  }

  void _toggleDebug() {
    setState(() => _showDebug = !_showDebug);
  }

  String _debugLine(String payload, Map<String, dynamic> meta) {
    final value = payload.trim();
    final preview = value.length > 40 ? '${value.substring(0, 40)}…' : value;
    final len = meta['length'] ?? value.length;
    final received = _receivedScan ? 'yes' : 'no';
    final ignore = _lastIgnoreReason ?? '-';
    return 'last=$preview | len=$len | received=$received | ignored=$ignore';
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 240,
        maxWidth: 320,
        minHeight: 180,
        maxHeight: 240,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Text(context.l10n.adminScannerTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    GestureDetector(
                      onLongPress: _toggleDebug,
                      child: Text(
                        _statusLabel(context),
                        style: const TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _togglePause,
                      child: Text(_paused ? context.l10n.adminScannerResume : context.l10n.adminScannerPause),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.slate,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentDeep),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: !_initialized
                      ? const Center(child: CircularProgressIndicator())
                      : Stack(
                          children: [
                            Center(
                              child: _videoAspectRatio == null
                                  ? SizedBox.expand(
                                      child: Webview(
                                        _controller,
                                        permissionRequested: _onPermissionRequested,
                                      ),
                                    )
                                  : AspectRatio(
                                      aspectRatio: _videoAspectRatio!,
                                      child: Webview(
                                        _controller,
                                        permissionRequested: _onPermissionRequested,
                                      ),
                                    ),
                            ),
                            if (_showSuccess)
                              Positioned.fill(
                                child: Container(
                                  color: Colors.white.withOpacity(0.9),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle, color: AppColors.green, size: 48),
                                      const SizedBox(height: 6),
                                      Text(context.l10n.commonEntered,
                                          style: const TextStyle(fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                  child: Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
                ),
              if ((_showDebug || kDebugMode) && _debugInfo != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                  child: Text(_debugInfo!,
                      style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                ),
            ],
          ),
        ),
      );
    }
  }

class _AdminQrScannerViewState extends State<AdminQrScannerView> {
  final WebviewController _controller = WebviewController();
  StreamSubscription? _messageSub;
  Timer? _resetTimer;
  Timer? _readyTimeout;
  HttpServer? _server;
  bool _pageReady = false;
  bool _serverHealthy = false;
  bool _initialized = false;
  bool _autoStarted = false;
  bool _processing = false;
  bool _showSuccess = false;
  String? _error;
  String? _status;
  String? _loadedUrl;
  double? _videoAspectRatio;
  String? _debugInfo;
  String? _lastIgnoreReason;
  bool _receivedScan = false;
  String? _lastPayload;
  bool _showDebug = false;

  void _toggleDebug() {
    setState(() => _showDebug = !_showDebug);
  }

  Map<String, dynamic>? _decodeMessage(dynamic message) {
    if (message is Map) {
      return Map<String, dynamic>.from(message as Map);
    }
    if (message is String) {
      try {
        final decoded = jsonDecode(message);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String? _extractMemberToken(String payload, BuildContext context, void Function(String) onError) {
    final trimmed = payload.trim();
    if (trimmed.isEmpty) {
      onError(context.l10n.adminScannerInvalidQr);
      return null;
    }
    if (trimmed.startsWith('fitcity://')) {
      final uri = Uri.tryParse(trimmed);
      if (uri == null) {
        onError(context.l10n.adminScannerInvalidQr);
        return null;
      }
      if (uri.host == 'entry') {
        onError(context.l10n.adminScannerEntryQr);
        return null;
      }
      if (uri.host == 'member') {
        final token = uri.queryParameters['token']?.trim();
        if (token == null || token.isEmpty) {
          onError(context.l10n.adminScannerMemberTokenMissing);
          return null;
        }
        return token;
      }
      onError(context.l10n.adminScannerInvalidQr);
      return null;
    }
    if (RegExp(r'^[a-fA-F0-9]{32}$').hasMatch(trimmed)) {
      return trimmed;
    }
    onError(context.l10n.adminScannerInvalidQr);
    return null;
  }

  @override
  void initState() {
    super.initState();
    _initWebview();
  }

  Future<void> _initWebview() async {
    await _controller.initialize();
    _controller.setBackgroundColor(Colors.black);
    _messageSub = _controller.webMessage.listen(_handleMessage);
    final url = await _startLocalServer();
    _loadedUrl = url.toString();
    _serverHealthy = await _healthCheck(url);
    await _controller.loadUrl(url.toString());
    await Future.delayed(const Duration(milliseconds: 350));
    if (mounted) {
      setState(() => _initialized = true);
    }
    _scheduleReadyFallback();
    _startCameraIfReady();
  }

  Future<Uri> _startLocalServer() async {
    if (_server != null) {
      return Uri.parse('http://127.0.0.1:${_server!.port}/admin_scanner.html');
    }
    final html = await rootBundle.loadString('assets/qr_scanner/admin_scanner.html');
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((request) {
      request.response.headers.set('Cache-Control', 'no-store');
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      if (request.uri.path == '/' || request.uri.path == '/admin_scanner.html') {
        request.response.headers.contentType = ContentType.html;
        request.response.write(html);
      } else if (request.uri.path == '/health') {
        request.response.headers.contentType = ContentType.text;
        request.response.write('ok');
      } else {
        request.response.statusCode = HttpStatus.notFound;
      }
      request.response.close();
    });
    return Uri.parse('http://127.0.0.1:${_server!.port}/admin_scanner.html');
  }

  Future<bool> _healthCheck(Uri url) async {
    try {
      final client = HttpClient();
      final healthUrl = Uri.parse('${url.scheme}://${url.host}:${url.port}/health');
      final request = await client.getUrl(healthUrl);
      final response = await request.close();
      await response.drain();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    _readyTimeout?.cancel();
    _messageSub?.cancel();
    _server?.close(force: true);
    _controller.dispose();
    super.dispose();
  }

  void _handleMessage(dynamic message) {
    try {
      final decoded = _decodeMessage(message);
      if (decoded == null) {
        return;
      }
      final type = decoded['type']?.toString();
      if (type == 'scan') {
        final payload = decoded['value']?.toString() ?? '';
        setState(() {
          _receivedScan = true;
          _debugInfo = _debugLine(payload, decoded);
        });
        final token = _extractMemberToken(payload, context, (message) {
          _lastIgnoreReason = message;
          setState(() => _error = message);
          _execIfReady('startScan();');
        });
        if (token == null) {
          return;
        }
        _handlePayload(token);
      } else if (type == 'ready') {
        setState(() => _pageReady = true);
        _startCameraIfReady();
      } else if (type == 'status') {
        setState(() => _status = decoded['message']?.toString());
      } else if (type == 'debug') {
        setState(() => _debugInfo = _debugLine(_lastPayload ?? '', decoded));
      } else if (type == 'aspect') {
        final value = decoded['value'];
        final ratio = value is num ? value.toDouble() : null;
        if (ratio != null && ratio > 0) {
          setState(() => _videoAspectRatio = ratio);
        }
      } else if (type == 'error') {
        final message = decoded['message']?.toString() ?? 'Camera error.';
        setState(() => _error = message);
      }
    } catch (_) {
      // Ignore malformed messages.
    }
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(
    String url,
    WebviewPermissionKind kind,
    bool isUserInitiated,
  ) async {
    if (kind == WebviewPermissionKind.camera) {
      return WebviewPermissionDecision.allow;
    }
    if (kind == WebviewPermissionKind.microphone) {
      return WebviewPermissionDecision.deny;
    }
    return WebviewPermissionDecision.none;
  }

  Future<void> _handlePayload(String payload) async {
    if (_processing) {
      return;
    }
    _lastPayload = payload;
    setState(() {
      _processing = true;
      _error = null;
      _showSuccess = false;
      _lastIgnoreReason = null;
    });
    await _controller.executeScript('stopScan();');
    QrScanResult result;
    try {
      result = await widget.onScan(payload);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = mapApiError(context, error);
        _processing = false;
      });
      await _execIfReady('startScan();');
      return;
    }
    if (!mounted) {
      return;
    }
    if (result.entered) {
      setState(() => _showSuccess = true);
      _resetTimer?.cancel();
      _resetTimer = Timer(const Duration(seconds: 6), () async {
        if (!mounted) {
          return;
        }
        setState(() {
          _showSuccess = false;
          _processing = false;
        });
        await _execIfReady('startScan();');
      });
      return;
    }
    setState(() {
      _error = result.reason.isNotEmpty ? result.reason : 'Scan failed. Try again.';
      _processing = false;
    });
    await _execIfReady('startScan();');
  }

  String _debugLine(String payload, Map<String, dynamic> meta) {
    final value = payload.trim();
    final preview = value.length > 40 ? '${value.substring(0, 40)}…' : value;
    final len = meta['length'] ?? value.length;
    final received = _receivedScan ? 'yes' : 'no';
    final ignore = _lastIgnoreReason ?? '-';
    return 'last=$preview | len=$len | received=$received | ignored=$ignore';
  }

  Future<void> _stopAndClose() async {
    await _execIfReady('stopAll();');
    widget.onClose();
  }

  Future<void> _execIfReady(String script) async {
    if (!_initialized || !_pageReady) {
      return;
    }
    await _controller.executeScript(script);
  }

  void _scheduleReadyFallback() {
    _readyTimeout?.cancel();
    _readyTimeout = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted || _pageReady) {
        return;
      }
      _startCameraIfReady(force: true);
    });
  }

  Future<void> _startCameraIfReady({bool force = false}) async {
    if (_autoStarted) {
      return;
    }
    if (!_initialized || !_serverHealthy) {
      return;
    }
    if (!_pageReady && !force) {
      return;
    }
    _autoStarted = true;
    await Future.delayed(const Duration(milliseconds: 300));
    await _controller.executeScript('initCamera();');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: false,
        title: GestureDetector(
          onLongPress: _toggleDebug,
          child: Text(context.l10n.adminScanQrCode),
        ),
      contentPadding: EdgeInsets.zero,
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 760,
          maxHeight: 620,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.slate,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.accentDeep, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: !_initialized
                            ? const Center(child: CircularProgressIndicator())
                            : Stack(
                                children: [
                                  Center(
                                    child: _videoAspectRatio == null
                                        ? SizedBox.expand(
                                            child: Webview(
                                              _controller,
                                              permissionRequested: _onPermissionRequested,
                                            ),
                                          )
                                        : AspectRatio(
                                            aspectRatio: _videoAspectRatio!,
                                            child: Webview(
                                              _controller,
                                              permissionRequested: _onPermissionRequested,
                                            ),
                                          ),
                                  ),
                                  if (_showSuccess)
                                    Positioned.fill(
                                      child: Container(
                                        color: Colors.white.withOpacity(0.92),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.check_circle, color: AppColors.green, size: 64),
                                            const SizedBox(height: 8),
                                            Text(context.l10n.commonSuccess,
                                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                                            const SizedBox(height: 4),
                                            Text(context.l10n.commonEntered,
                                                style: const TextStyle(color: AppColors.muted)),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: _error != null
                          ? Text(_error!, style: const TextStyle(color: AppColors.red), textAlign: TextAlign.center)
                          : _status != null
                              ? Text(_status!, style: const TextStyle(color: AppColors.muted), textAlign: TextAlign.center)
                              : Text(
                                  context.l10n.adminScanQrHint,
                                  style: const TextStyle(color: AppColors.muted),
                                  textAlign: TextAlign.center,
                                ),
                    ),
                    if ((_showDebug || kDebugMode) && _debugInfo != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Text(_debugInfo!,
                            style: const TextStyle(color: AppColors.muted, fontSize: 11),
                            textAlign: TextAlign.center),
                      ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: _stopAndClose, child: Text(context.l10n.commonCancel)),
      ],
    );
  }
}
