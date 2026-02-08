import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import '../services/fitcity_api.dart';

class ChatSocketService {
  ChatSocketService._();

  static final ChatSocketService instance = ChatSocketService._();

  HubConnection? _connection;
  StreamSubscription? _reconnectSubscription;
  final Map<void Function(Map<String, dynamic>), MethodInvocationFunc> _messageHandlers = {};
  final Map<void Function(Map<String, dynamic>), MethodInvocationFunc> _readHandlers = {};
  final Set<String> _joinedConversations = {};

  Future<void> connect() async {
    final session = FitCityApi.instance.session.value;
    if (session == null) {
      return;
    }
    if (_connection != null && _connection!.state == HubConnectionState.Connected) {
      return;
    }
    final baseUrl = FitCityApi.instance.baseUrl;
    final hubUrl = baseUrl.endsWith('/') ? '${baseUrl}hubs/chat' : '$baseUrl/hubs/chat';

    _connection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => session.auth.accessToken,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.onreconnected(({String? connectionId}) async {
      await _rejoinConversations();
      _registerHandlers();
    });
    _connection!.onclose(({Exception? error}) async {
      // Keep handlers and joined conversations for reconnect.
    });

    await _connection!.start();
    _registerHandlers();
    await _rejoinConversations();
  }

  Future<void> disconnect() async {
    await _reconnectSubscription?.cancel();
    _reconnectSubscription = null;
    if (_connection != null) {
      await _connection!.stop();
      _connection = null;
    }
  }

  bool get isConnected => _connection?.state == HubConnectionState.Connected;

  void onMessageNew(void Function(Map<String, dynamic> payload) handler) {
    if (_messageHandlers.containsKey(handler)) {
      return;
    }
    void Function(List<Object?>?) wrapper = (args) {
      if (args == null || args.isEmpty || args.first is! Map) {
        return;
      }
      handler(Map<String, dynamic>.from(args.first as Map));
    };
    _messageHandlers[handler] = wrapper;
    _connection?.on('message:new', wrapper);
  }

  void offMessageNew(void Function(Map<String, dynamic> payload) handler) {
    final wrapper = _messageHandlers.remove(handler);
    if (wrapper != null) {
      _connection?.off('message:new', method: wrapper);
    }
  }

  void onConversationRead(void Function(Map<String, dynamic> payload) handler) {
    if (_readHandlers.containsKey(handler)) {
      return;
    }
    void Function(List<Object?>?) wrapper = (args) {
      if (args == null || args.isEmpty || args.first is! Map) {
        return;
      }
      handler(Map<String, dynamic>.from(args.first as Map));
    };
    _readHandlers[handler] = wrapper;
    _connection?.on('conversation:read', wrapper);
  }

  void offConversationRead(void Function(Map<String, dynamic> payload) handler) {
    final wrapper = _readHandlers.remove(handler);
    if (wrapper != null) {
      _connection?.off('conversation:read', method: wrapper);
    }
  }

  Future<void> joinConversation(String conversationId) async {
    _joinedConversations.add(conversationId);
    if (_connection?.state != HubConnectionState.Connected) {
      await connect();
    }
    await _connection?.invoke('conversation:join', args: [conversationId]);
  }

  Future<void> leaveConversation(String conversationId) async {
    _joinedConversations.remove(conversationId);
    await _connection?.invoke('conversation:leave', args: [conversationId]);
  }

  Future<void> sendMessage(String conversationId, String text) async {
    await _connection?.invoke('message:send', args: [conversationId, text]);
  }

  void _registerHandlers() {
    if (_connection == null) {
      return;
    }
    for (final wrapper in _messageHandlers.values) {
      _connection!.on('message:new', wrapper);
    }
    for (final wrapper in _readHandlers.values) {
      _connection!.on('conversation:read', wrapper);
    }
  }

  Future<void> _rejoinConversations() async {
    if (_connection?.state != HubConnectionState.Connected) {
      return;
    }
    for (final conversationId in _joinedConversations) {
      await _connection?.invoke('conversation:join', args: [conversationId]);
    }
  }
}
