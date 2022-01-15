import 'package:scope/scope.dart';
import 'package:test/test.dart';

final userKey = ScopeKey<User>();
final counterKey = ScopeKey<int>();

final realUser = User('real');
final testUser = User('test');

void main() {
  GlobalScope().single(userKey, () => realUser);

  var counter = 0;
  GlobalScope().sequence(counterKey, () => counter++);

  group('global scope', () {
    test('value with override', () async {
      expect(use(userKey), realUser);

      Scope()
        ..value(userKey, testUser)
        ..run(() {
          expect(use(userKey), testUser);
        });
      expect(use(userKey), realUser);
    });

    test('single with override', () async {
      expect(use(userKey), realUser);

      Scope()
        ..value(userKey, testUser)
        ..run(() {
          expect(use(userKey), testUser);
        });
      expect(use(userKey), realUser);
    });

    test('sequences with override', () async {
      expect(use(counterKey), 0);
      expect(use(counterKey), 1);

      var testCounter = 0;
      Scope()
        ..sequence(counterKey, () => testCounter++)
        ..run(() {
          expect(use(counterKey), 0);
          expect(use(counterKey), 1);
        });
      expect(use(counterKey), 2);
    });
  });
}

class User {
  User(this.name);
  String name;
}
