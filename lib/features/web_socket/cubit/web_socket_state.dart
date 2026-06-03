part of 'web_socket_cubit.dart';

class WebSocketState extends Equatable {
  final ConnectionState connectionState;
  final bool canRetry;
  const WebSocketState({
    required this.connectionState,
    this.canRetry = true,
  });

  WebSocketState copyWith({
    ConnectionState? connectionState,
    bool? canRetry,
  }) {
    return WebSocketState(
      connectionState: connectionState ?? this.connectionState,
      canRetry: canRetry ?? this.canRetry,
    );
  }

  @override
  List<Object?> get props => [
    connectionState,
    canRetry,
  ];
}
