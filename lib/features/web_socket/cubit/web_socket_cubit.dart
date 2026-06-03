import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:daily_water_tracker/features/web_socket/services/web_socket_service.dart';
import 'package:web_socket_client/web_socket_client.dart';

part 'web_socket_state.dart';

const _unauthorizedCode = '401';

class WebSocketCubit extends Cubit<WebSocketState> {
  final WebSocketService webSocketService;
  StreamSubscription<void>? messagesSubscription;
  StreamSubscription<void>? connectionSubscription;
  WebSocketCubit({required this.webSocketService})
    : super(
        const WebSocketState(connectionState: Disconnected()),
      );

  Future<void> connect() async {
    await messagesSubscription?.cancel();
    await connectionSubscription?.cancel();
    webSocketService.closeConnection();

    await webSocketService.connect();

    messagesSubscription = webSocketService.messagesStream!.listen((message) {
      log.fine('[Web-socket] new message: $message');

      /// Once the token is not valid, try to reconnect(refresh token) one more time, but not more.
      if (message.code == _unauthorizedCode && state.canRetry == true) {
        emit(state.copyWith(canRetry: false));
        connect();
        return;
      }

      /// Once any other message than unauthorized is received, keep possibility to reconnect next time.
      emit(state.copyWith(canRetry: true));
    });
    connectionSubscription = webSocketService.connectionStream!.listen((
      connectionState,
    ) {
      log.fine('[Web-socket] new connection status: $connectionState');
      emit(state.copyWith(connectionState: connectionState));
      if (connectionState is Disconnected) {
        closeConnection();
      }
    });
  }

  void sendMessage({dynamic message}) {
    webSocketService.sendMessage(message: message);
  }

  void closeConnection() {
    webSocketService.closeConnection();
    messagesSubscription?.cancel();
    connectionSubscription?.cancel();
  }

  @override
  Future<void> close() {
    webSocketService.closeConnection();
    messagesSubscription?.cancel();
    connectionSubscription?.cancel();
    return super.close();
  }
}
