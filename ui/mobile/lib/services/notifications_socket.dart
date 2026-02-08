import 'package:signalr_netcore/signalr_client.dart';
import '../services/fitcity_api.dart';

class NotificationsSocketService {
  NotificationsSocketService._();

  static final NotificationsSocketService instance = NotificationsSocketService._();

  HubConnection? _connection;
  final Map<void Function(Map<String, dynamic>), void Function(List<Object?>?)> _handlers = {};

  Future<void> connect() async {
    final session = FitCityApi.instance.session.value;
    if (session == null) {
      return;
    }
    if (_connection != null && _connection!.state == HubConnectionState.Connected) {
      return;
    }
    final baseUrl = FitCityApi.instance.baseUrl;
    final hubUrl = baseUrl.endsWith('/') ? '${baseUrl}hubs/notifications' : '$baseUrl/hubs/notifications';

    _connection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => session.auth.accessToken,
          ),
        )
        .withAutomaticReconnect()
        .build();

    await _connection!.start();
    _attachHandlers();
  }

  Future<void> disconnect() async {
    if (_connection != null) {
      await _connection!.stop();
      _connection = null;
    }
  }

  bool get isConnected => _connection?.state == HubConnectionState.Connected;

  void onNotificationNew(void Function(Map<String, dynamic> payload) handler) {
    if (_handlers.containsKey(handler)) {
      return;
    }
    void Function(List<Object?>?) wrapper = (args) {
      if (args == null || args.isEmpty || args.first is! Map) {
        return;
      }
      handler(Map<String, dynamic>.from(args.first as Map));
    };
    _handlers[handler] = wrapper;
    if (_connection != null) {
      _connection!.on('notification:new', wrapper);
    }
  }

  void offNotificationNew(void Function(Map<String, dynamic> payload) handler) {
    final wrapper = _handlers.remove(handler);
    if (wrapper != null && _connection != null) {
      _connection!.off('notification:new', method: wrapper);
    }
  }

  void _attachHandlers() {
    if (_connection == null) {
      return;
    }
    for (final wrapper in _handlers.values) {
      _connection!.on('notification:new', wrapper);
    }
  }
}
