// ignore_for_file: unreachable_from_main

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:scope/scope.dart';
import 'package:test/test.dart';

final userKey = ScopeKey<User>();
final counterKey = ScopeKey<int>();

final realUser = User('real');
final testUser = User('test');

void main() {
  GlobalScope().single<User>(userKey, () => realUser);

  var counter = 0;
  GlobalScope().sequence<int>(counterKey, () => counter++);

  group('global scope', () {
    test('value with override', () async {
      expect(use(userKey), realUser);

      Scope()
        ..value<User>(userKey, testUser)
        ..runSync(() {
          expect(use(userKey), testUser);
        });
      expect(use(userKey), realUser);
    });

    test('single with override', () async {
      expect(use(userKey), realUser);

      Scope()
        ..value<User>(userKey, testUser)
        ..runSync(() {
          expect(use(userKey), testUser);
        });
      expect(use(userKey), realUser);
    });

    test('sequences with override', () async {
      expect(use(counterKey), 0);
      expect(use(counterKey), 1);

      var testCounter = 0;
      Scope()
        ..sequence<int>(counterKey, () => testCounter++)
        ..runSync(() {
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
