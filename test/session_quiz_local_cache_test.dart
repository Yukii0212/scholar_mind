import 'package:flutter_test/flutter_test.dart';
import 'package:scholar_mind/features/quiz/services/quiz_local_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('active quiz attempts are isolated by user id', () async {
    SharedPreferences.setMockInitialValues({
      'active_quiz_attempt': '{"id":"legacy"}',
    });
    const cache = QuizLocalCacheService();

    await cache.saveAttempt(
      userId: 'account-a',
      json: {'id': 'attempt-a'},
    );
    await cache.saveAttempt(
      userId: 'account-b',
      json: {'id': 'attempt-b'},
    );

    expect(
      await cache.loadCurrentAttempt(userId: 'account-a'),
      {'id': 'attempt-a'},
    );
    expect(
      await cache.loadCurrentAttempt(userId: 'account-b'),
      {'id': 'attempt-b'},
    );

    await cache.clearCurrentAttempt(userId: 'account-a');

    expect(
      await cache.loadCurrentAttempt(userId: 'account-a'),
      isNull,
    );
    expect(
      await cache.loadCurrentAttempt(userId: 'account-b'),
      {'id': 'attempt-b'},
    );

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey('active_quiz_attempt'), isFalse);
  });
}
