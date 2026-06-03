import 'package:equatable/equatable.dart';

class SocketResponse extends Equatable {
  final String code;
  final String action;
  const SocketResponse({required this.code, required this.action});

  factory SocketResponse.fromJson(dynamic json) {
    return SocketResponse(
      code: json['code'],
      action: json['action'],
    );
  }

  @override
  List<Object?> get props => [code, action];
}
