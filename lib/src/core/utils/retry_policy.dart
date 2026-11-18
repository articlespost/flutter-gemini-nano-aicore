import 'package:flutter/foundation.dart';

@immutable
final class RetryPolicy {
  const RetryPolicy({
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 8),
  });

  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;

  Duration? delayFor(int attempt, {Duration suggested = Duration.zero}) {
    if (attempt >= maxRetries) return null;
    if (suggested > Duration.zero) {
      return suggested <= maxDelay ? suggested : null;
    }
    final exponential = baseDelay * (1 << attempt);
    return exponential <= maxDelay ? exponential : maxDelay;
  }
}
