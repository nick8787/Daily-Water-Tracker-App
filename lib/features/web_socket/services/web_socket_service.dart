import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:daily_water_tracker/features/web_socket/models/socket_response.dart';
import 'package:daily_water_tracker/network/web_socket/web_socket_client.dart';
import 'package:web_socket_client/web_socket_client.dart';

class WebSocketService {
  final WebSocketClient _webSocketClient;

  WebSocketService({
    required WebSocketClient webSocketClient,
  }) : _webSocketClient = webSocketClient;

  Stream<SocketResponse>? get messagesStream =>
      _webSocketClient.messagesStream?.map((event) {
        return SocketResponse.fromJson(event);
      });
  Stream<ConnectionState>? get connectionStream =>
      _webSocketClient.connectionStream;

  Future<void> connect() async {
    try {
      await _webSocketClient.connect();
    } catch (e, st) {
      logCaughtError('WebSocketService', e, st);
      rethrow;
    }
  }

  void sendMessage({required dynamic message}) {
    try {
      _webSocketClient.sendMessage(message: message);
    } catch (e, st) {
      logCaughtError('WebSocketService.sendMessage', e, st);
      rethrow;
    }
  }

  void closeConnection() {
    try {
      _webSocketClient.closeConnection();
    } catch (e, st) {
      logCaughtError('WebSocketService.closeConnection', e, st);
      rethrow;
    }
  }
}
