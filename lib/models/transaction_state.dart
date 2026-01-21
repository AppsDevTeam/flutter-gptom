enum GpTomTransactionState {
  /// Initial state
  created(1),

  /// The transaction has begun
  started(2),

  /// An initialization error occurred
  initError(3),

  /// Payment in progress
  inProgress(5),

  /// Payment completed
  completed(6),

  /// Payment cancelled
  cancelled(7),

  /// Global error
  error(8),

  unknown(null);

  const GpTomTransactionState(this.value);
  final int? value;

  static GpTomTransactionState fromValue(int? value) {
    if (value == null) return GpTomTransactionState.unknown;

    return GpTomTransactionState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GpTomTransactionState.unknown,
    );
  }
}
