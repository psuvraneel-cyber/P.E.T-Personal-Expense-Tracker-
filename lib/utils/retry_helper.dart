import 'dart:async';
import 'package:pet/core/utils/app_logger.dart';

/// Retries [action] up to [maxAttempts] times with exponential backoff.
///
/// Delays between attempts: 2s → 4s → 8s (doubles each time).
/// Calls [onRetry] (if provided) before each retry attempt.
/// Rethrows the last exception if all attempts fail.
///
/// Usage:
/// ```dart
/// final result = await retryWithBackoff(
///   () => fetchData(),
///   maxAttempts: 3,
///   onRetry: (attempt, error) => AppLogger.debug('Retry $attempt: $error'),
/// );
/// ```
Future<T> retryWithBackoff<T>(
  Future<T> Function() action, {
  int maxAttempts = 3,
  Duration initialDelay = const Duration(seconds: 2),
  void Function(int attempt, Object error)? onRetry,
}) async {
  assert(maxAttempts >= 1, 'maxAttempts must be >= 1');

  Object? lastError;
  StackTrace? lastStack;

  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await action();
    } catch (e, stack) {
      lastError = e;
      lastStack = stack;

      if (attempt == maxAttempts) break; // don't delay after the final failure

      final delay = initialDelay * (1 << (attempt - 1)); // 2s, 4s, 8s …
      AppLogger.debug(
        '[RetryHelper] Attempt $attempt/$maxAttempts failed: $e — '
        'retrying in ${delay.inSeconds}s',
      );
      onRetry?.call(attempt, e);
      await Future.delayed(delay);
    }
  }

  AppLogger.debug('[RetryHelper] All $maxAttempts attempts failed');
  Error.throwWithStackTrace(lastError!, lastStack!);
}
