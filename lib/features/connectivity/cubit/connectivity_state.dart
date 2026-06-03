part of 'connectivity_cubit.dart';

class ConnectivityState extends Equatable {
  final ConnectivityStatus status;
  const ConnectivityState({this.status = ConnectivityStatus.none});

  @override
  List<Object?> get props => [status];

  ConnectivityState copyWith({ConnectivityStatus? status}) {
    return ConnectivityState(status: status ?? this.status);
  }
}

enum ConnectivityStatus {
  none,
  loading,
  hasConnection,
  noConnection;

  bool get isNone => this == ConnectivityStatus.none;
  bool get isLoading => this == ConnectivityStatus.loading;
  bool get isHasConnection => this == ConnectivityStatus.hasConnection;
  bool get isNoConnection => this == ConnectivityStatus.noConnection;
}
