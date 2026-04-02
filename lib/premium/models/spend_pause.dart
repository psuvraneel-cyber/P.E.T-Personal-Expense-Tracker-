class SpendPause {
  final bool enabled;

  /// When the pause auto-expires. Null means indefinite.
  final DateTime? until;

  /// Category names that are blocked during the pause.
  final List<String> blockedCategories;

  SpendPause({
    required this.enabled,
    this.until,
    this.blockedCategories = const [],
  });

  /// Returns true if the pause is enabled and has not yet expired.
  bool get isActive {
    if (!enabled) return false;
    if (until == null) return true;
    return DateTime.now().isBefore(until!);
  }
}
