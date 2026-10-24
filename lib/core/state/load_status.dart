/// Shared status for any asynchronous action in the app.
///
/// Feature states (auth, cards, exercises, ...) can reuse this instead of
/// inventing their own loading/error flags.
enum LoadStatus { idle, loading, success, failure }

extension LoadStatusX on LoadStatus {
  bool get isIdle => this == LoadStatus.idle;
  bool get isLoading => this == LoadStatus.loading;
  bool get isSuccess => this == LoadStatus.success;
  bool get isFailure => this == LoadStatus.failure;
}
