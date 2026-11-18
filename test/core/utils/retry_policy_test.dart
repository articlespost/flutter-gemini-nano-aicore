import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_nano_bridge/src/core/utils/retry_policy.dart';

void main() {
  const policy = RetryPolicy(
    maxRetries: 3,
    baseDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 2),
  );

  test('aplica backoff exponencial limitado ao maxDelay', () {
    expect(policy.delayFor(0), const Duration(milliseconds: 500));
    expect(policy.delayFor(1), const Duration(seconds: 1));
    expect(policy.delayFor(2), const Duration(seconds: 2));
  });

  test('não tenta de novo depois de maxRetries', () {
    expect(policy.delayFor(3), isNull);
  });

  test('respeita o atraso sugerido pelo AICore quando cabe no limite', () {
    expect(
      policy.delayFor(0, suggested: const Duration(milliseconds: 1500)),
      const Duration(milliseconds: 1500),
    );
  });

  test('desiste quando o atraso sugerido passa do limite', () {
    expect(policy.delayFor(0, suggested: const Duration(seconds: 30)), isNull);
  });
}
