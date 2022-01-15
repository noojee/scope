import 'package:meta/meta.dart';

import 'scope.dart';

/// Thrown by [use] when no value has been registered in the [Scope]
/// for [_key] and it has no default value.
class MissingDependencyException<T> implements Exception {
  /// Thrown by [use] when no value has been registered in the [Scope]
  /// for [_key] and it has no default value.
  MissingDependencyException(this._key);

  final ScopeKey<T> _key;

  @override
  String toString() => 'MissingDependencyException: '
      'No value has been provided for $_key '
      'and it has no default value.';
}

/// Thrown by [use] when called inside a [Scope.single] or [Scope.sequence]
/// callback and the [keys] factories try to mutually inject each other.
class CircularDependencyException<T> implements Exception {
  /// Thrown by [use] when called inside a [Scope.single] or [Scope.sequence]
  /// callback and the [keys] factories try to mutually inject each other.
  CircularDependencyException(this.keys);
  @visibleForTesting

  /// The key that caused the circular dependency.
  final List<ScopeKey<T>> keys;

  @override
  String toString() => 'CircularDependencyException: The factories for these '
      'keys depend on each other: ${keys.join(" -> ")} -> ${keys.first}';
}

/// Thrown if an attempt is made to inject the same [ScopeKey]
/// twice into the same Scope.
class DuplicateDependencyException<T> implements Exception {
  /// Thrown if an attempt is made to inject the same [ScopeKey]
  /// twice.
  DuplicateDependencyException(this.key);

  @visibleForTesting

  /// the key that was a duplicate.
  final ScopeKey<T> key;

  @override
  String toString() => 'DuplicateDependencyException: '
      'The key $key has already been added to this Scope.';
}
