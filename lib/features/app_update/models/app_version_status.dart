enum AppVersionStatus {
  none,
  loading,
  updateRequired,
  loaded,
  error;

  bool get isNone => this == AppVersionStatus.none;
  bool get isLoading => this == AppVersionStatus.loading;
  bool get isUpdateRequired => this == AppVersionStatus.updateRequired;
  bool get isLoaded => this == AppVersionStatus.loaded;
  bool get isError => this == AppVersionStatus.error;
}
