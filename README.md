# Scope

Scope provides Inversion of Control using the dependency injection (DI) pattern for Dart applications.

Scope allows you to inject values into a scope and then 'use' those dependencies from any method (or constructor) called within that scope.

> Scope is incredibly easy to use with no additional plumbing required.

Scope is not a replacement for the likes of Provider. Provider does dependency injection for your BuildContext whilst Scope provides DI for your call stack.

For Java developers Scope provides similar functionality to thread local variables.

> Scope supports nested scopes; overload or add additional values at each level.

# Supporters

Scope is supported by OnePub the private Dart package repository.

https://onepub.dev


The best way to understand Scope is with an example:

```dart
import 'package:scope/scope.dart';
import 'package:money2/money2.dart';

const ageKey = ScopeKey<int>();
const heightKey = ScopeKey<int>();
const incomeKey = ScopeKey<Money>();
const countKey = ScopeKey<int>();

void main() {
    /// create a Scope
    Scope()
    
    /// inject values
    ..value<int>(ageKey, 18)
    ..value<int>(heightKey, 182) // centimetres
    /// single value from factory method
    ..single<Db>(incomeKey, () => calcIncome)
    /// sequence of values from factory method.
    ..sequence<int>(countKey, () => tracker)
    
    /// run some code within the Scope
    ..run(() => a();
}
void a() {
    print('Your height is ${use(heightKey)}');
    printRealWorth();
}

/// `use` the injected values
void printRealWorth() {
    print('You are the ${use(countKey)} person to ask');
    print('You are ${use(ageKey)} years old');
    print('You earn ${use(incomeKey} per hour.');
}

Money calcIncome() {
    final age = use(ageKey);
    if (age < 18) return Money.parse(r'$10.00');

    return Money.parse(r'$20.00');
}

var count = 0;
int tracker()
{
    return count++;
}
```

See the Scope documentation at:

https://scope.onepub.dev

The best practice guide is worth a read:

https://scope.onepub.dev/guides/best-practice 


    Authors: 
    Philipp Schiffmann <philippschiffmann93@gmail.com>
    S. Brett Sutton

Scope is a reimagining of Philipp's zone_id package.
All credit goes to Phillipp's original implementation without which Scope wouldn't exist.
