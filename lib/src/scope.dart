library scope;

import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';

import 'exceptions.dart';

part 'scope_key.dart';
part '__injector.dart';
part '__single_injector.dart';

typedef _Factory = dynamic Function();

/// Creates a Scope providing dependency injection to your call stack.
///
/// Scopes may be nested with the nearest Scope overriding parent scopes.
class Scope {
  /// Create a [Scope] that allows you to inject values.
  ///
  /// Any methods directly or indirectly called from the
  /// [Scope]s [run] method have access to those injected values.
  ///
  /// The [debugName] is useful when debugging allowing yo to
  /// provide each [Scope] with a unique name.
  ///
  /// ```dart
  /// final ageKey = ScopeKey<int>();
  /// final daysOldKey = ScopeKey<int>();
  /// final countKey = ScopeKey<int>();
  /// Scope()
  ///   ..value<int>(ageKey, 18)
  ///   ..single<int>(daysOldKey, () => calculateDaysOld(use(ageKey)))
  ///   ..sequence<int>(countKey, () => count++)
  ///   ..run(() {
  ///       print('You are ${use(ageKey)} which is ${use(daysOldKey)} '
  ///         'count: ${use(countKey)}'));
  ///   });
  Scope([String? debugName]) {
    _debugName = debugName ?? 'Unnamed Scope - pass debugName to ctor';
  }

  @override
  String toString() => _debugName;

  late final String _debugName;

  final _provided = <ScopeKey<dynamic>, dynamic>{};
  final _singles = <ScopeKey<dynamic>, _Factory>{};
  final _sequences = <ScopeKey<dynamic>, _Factory>{};

  /// Injects [value] into the [Scope].
  ///
  /// The [value] can be retrieve by calling
  /// [use] from anywhere within the action
  /// method provided to [run]
  void value<T>(ScopeKey<T> key, T value) {
    if (_provided.containsKey(key)) {
      throw DuplicateDependencyException(key);
    }
    _provided.putIfAbsent(key, () => value);
  }

  @Deprecated('Use single')

  /// Use [single].
  void factory<T>(ScopeKey<T> key, T Function() factory) =>
      single(key, factory);

  /// Injects a [single] value into the [Scope].
  ///
  /// A [single] may [use] [value]s, other [single]s
  /// and [sequence]s registered within the same [Scope].
  ///
  /// Each [single] is eagerly called when [Scope.run] is called
  /// and are fully resolved when the [Scope.run]'s s action is called.
  void single<T>(ScopeKey<T> key, T Function() factory) {
    if (_singles.containsKey(key)) {
      throw DuplicateDependencyException(key);
    }
    _singles.putIfAbsent(key, () => factory);
  }

  /// Injects a generated value into the [Scope].
  ///
  /// The [sequence]'s [factory] method is called each time [use]
  /// for the [key] is called.
  ///
  /// The difference between [single] and [sequence] is that
  /// for a [single] the [factory] method is only called once where as
  /// the [sequence]s [factory] method is called each time [use] for
  /// the [sequence]'s key is called.
  ///
  /// The [sequence] [factory] method is NOT called when the [run] method
  /// is called.
  ///
  void sequence<T>(ScopeKey<T> key, T Function() factory) {
    if (_sequences.containsKey(key)) {
      throw DuplicateDependencyException(key);
    }
    value<dynamic>(key, factory);
  }

  /// Runs [action] within the defined [Scope].
  R run<R>(R Function() action) {
    _resolveSingles();

    return runZoned(action, zoneValues: {
      _Injector:
          _Injector(_provided.map<ScopeKey<dynamic>, dynamic>((t, dynamic v) {
        if (v is Function) {
          return MapEntry<ScopeKey<dynamic>, dynamic>(t, t._castFunction(v));
        } else {
          return MapEntry<ScopeKey<dynamic>, dynamic>(t, t._cast(v));
        }
      })),
    });
  }

  void _resolveSingles() {
    final injector = _SingleInjector(_singles);
    runZoned(() {
      injector.zone = Zone.current;
      // Cause [injector] to call all factories.
      for (final key in _singles.keys) {
        /// Resolve the singlton by calling its factory method
        /// and adding it as a value.
        value<dynamic>(key, injector.get<dynamic>(key));
      }
    }, zoneValues: {_Injector: injector});
  }

  /// Returns the value provided for [key], or the keys default value if no
  /// value was provided.
  ///
  /// A [MissingDependencyException] will be thrown if the passed [key]
  /// is not in scope.
  ///
  /// A [CircularDependencyException] will be thrown if a circular
  /// dependency is discovered values provided by [single] or [sequence].
  static T use<T>(ScopeKey<T> key, {T Function()? withDefault}) =>
      _use(key, withDefault: withDefault);

  /// Returns true if [key] is contained within the current [Scope]
  /// or an ancestor [Scope]
  ///
  /// For nullable types even if the value is null [hasScopeKey]
  /// will return true if a value was injected.
  static bool hasScopeKey<T>(ScopeKey<T> key) => _hasScopeKey(key);

  /// Returns true if [key] is contained within the current scope
  /// or an ancestor [Scope] or if the [key] has a default value.
  ///
  /// For nullable types even if the value is null [hasScopeValue]
  /// will return true if a value was injected.
  static bool hasScopeValue<T>(ScopeKey<T> key) => _hasScopeValue(key);

  /// Returns true if the caller is running within a [Scope]
  static bool isWithinScope() => _isWithinScope();
}

/// Returns the value provided for [key], or the keys default value if no
/// value was provided.
///
/// A [MissingDependencyException] will be thrown if the passed [key]
/// is not in scope.
///
/// A [CircularDependencyException] will be thrown if a circular
/// dependency is discovered values provided by [Scope.single]
/// or [Scope.sequence].
T use<T>(ScopeKey<T> key, {T Function()? withDefault}) =>
    _use(key, withDefault: withDefault);

T _use<T>(ScopeKey<T> key, {T Function()? withDefault}) {
  final injector =
      (Zone.current[_Injector] as _Injector?) ?? const _Injector.empty();

  T value;
  if (_hasScopeKey(key)) {
    value = injector.get(key);
  } else if (withDefault != null) {
    value = withDefault();
  } else {
    /// the key may have a default so lets get it
    /// or throw a MissingDependencyException
    value = injector.get(key);
  }

  return value;
}

/// Returns true if [T] was declared as a nullable type (e.g. String?)
bool isNullable<T>() => null is T;

/// Returns true if [key] is contained within the current [Scope]
/// or an ancestor [Scope]
///
/// For nullable types even if the value is null [hasScopeKey]
/// will return true if a value was injected.
bool hasScopeKey<T>(ScopeKey<T> key) => _hasScopeKey(key);

/// Returns true if [key] is contained within the current scope
/// or an ancestor [Scope] or if the [key] has a default value.
///
/// For nullable types even if the value is null [hasScopeValue]
/// will return true if a value was injected.
bool hasScopeValue<T>(ScopeKey<T> key) => _hasScopeValue(key);

/// Returns true if [key] is contained within the current scope
bool _hasScopeValue<T>(ScopeKey<T> key) {
  var _hasScopeKey = true;
  final injector =
      (Zone.current[_Injector] as _Injector?) ?? const _Injector.empty();
  if (injector.hasValue(key)) {
    _hasScopeKey = true;
  } else {
    _hasScopeKey = false;
  }
  return _hasScopeKey;
}

/// Returns true if [key] is contained within the current scope
bool _hasScopeKey<T>(ScopeKey<T> key) {
  var _hasScopeKey = true;
  final injector =
      (Zone.current[_Injector] as _Injector?) ?? const _Injector.empty();
  if (injector.hasKey(key)) {
    // final value = injector.get(key);
    // if (isNullable<T>() && value == null) {
    //   _hasScopeKey = false;
    // }
    _hasScopeKey = true;
  } else {
    _hasScopeKey = false;
  }
  return _hasScopeKey;
}

/// Returns true if the caller is running within a [Scope]
bool isWithinScope() => _isWithinScope();

bool _isWithinScope() => Zone.current[_Injector] != null;
