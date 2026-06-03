import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:daily_water_tracker/common/services/secure_cache.dart';
import 'package:web_socket_client/web_socket_client.dart';

const String headerAccessToken = 'Authorization';

final _defaultBackoff = BinaryExponentialBackoff(
  initial: const Duration(milliseconds: 300),
  maximumStep: 7,
);
const _defaultTimeout = Duration(seconds: 20);

class WebSocketClient with SecureStorageMixin {
  final String baseUrl;
  WebSocket? _webSocket;

  WebSocketClient({required this.baseUrl});

  Stream<dynamic>? get messagesStream => _webSocket?.messages;
  Stream<ConnectionState>? get connectionStream => _webSocket?.connection;

  Future<void> connect() async {
    try {
      log.fine('[Web-socket] connecting...');
      final authToken = await readAuthToken();

      _webSocket = WebSocket(
        Uri.parse('wss://$baseUrl'),
        headers: {headerAccessToken: 'Bearer $authToken'},
        backoff: _defaultBackoff,
        timeout: _defaultTimeout,
      );

      /// Wait until a connection has been established.
      await _webSocket!.connection.firstWhere((state) => state is Connected);
      log.fine('[Web-socket] connected.');
    } catch (e, st) {
      logCaughtError('WebSocketClient.connect', e, st);
      rethrow;
    }
  }

  Future<void> sendMessage({required dynamic message}) async {
    try {
      if (_webSocket == null) {
        throw Exception();
      }
      log.fine('[Web-socket] sending message: $message');
      _webSocket!.send(message);
      log.fine('[Web-socket] message sent: $message');
    } catch (e, st) {
      logCaughtError('WebSocketClient.sendMessage', e, st);
      rethrow;
    }
  }

  void closeConnection() {
    try {
      log.fine('[Web-socket] closing connection...');
      _webSocket?.close();
      _webSocket = null;
      log.fine('[Web-socket] connection closed.');
    } catch (e, st) {
      logCaughtError('WebSocketClient.closeConnection', e, st);
      rethrow;
    }
  }
}
