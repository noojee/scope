part of scope;

/// The only purpose of [ScopeKey]s is to be globally unique so that they
/// can be used to  uniquely identify injected values. [ScopeKey]s are opaque
/// – you are not supposed to read any other information from them except t
/// heir identity.
///
/// You must NOT extend or implement this class.
///
/// The `debugName` is only used in error messages. We recommend that
/// you use a debugName of the form:
/// `package_name.library_name.variableName`
///
/// If a key is created with a default value, it will be returned by [use]
/// when no value was provided for this key. `null` is a valid default value,
/// provided the [T] is nullable (e.g. String?), and is distinct from no value.
///
/// The type argument [T] is used to infer the return type of [use].
///
/// ```dart
///
/// ScopeKey<int> countKey = ScopeKey<int>(0);
///
/// ScopeKey<int> countKey = ScopeKey.withDefault<int>(0);
/// ```
@sealed
class ScopeKey<T> {
  /// Create a ScopeKey with a specific type.
  ///
  /// You MUST provide the type!
  ///
  /// ```
  ///  ScopeKey<int> countKey = ScopeKey<int>();
  ///  Scope()
  ///  ..value(countKey, 1)
  ///  .. run(() {
  ///     int count = use(countKey);
  /// });
  /// ```
  ScopeKey([String? debugName]) : _defaultValue = _Sentinel.noValue {
    _debugName = debugName ?? 'debugName=?';
  }

  /// Create a ScopeKey that provides a default value if the
  /// key has not been added to the scope.
  ///
  /// ```
  ///  ScopeKey<int> countKey = ScopeKey.withDefault<int>(0);
  ///
  ///  int count = use(countKey);
  /// ```
  ScopeKey.withDefault(T defaultValue, String? debugName)
      : _defaultValue = defaultValue {
    _debugName = debugName ?? 'debugName=?';
  }

  late final String _debugName;
  final Object? _defaultValue;

  T _cast(dynamic v) => v as T;

  T Function() _castFunction(dynamic v) => v as T Function();

  @override
  String toString() => 'ScopeKey<${_typeOf<T>().toString()}>($_debugName)';
}

Type _typeOf<T>() => T;
enum _Sentinel {
  /// Used to indicate that a [ScopeKey] has no default value – which is
  /// different from a default value of `null`.
  noValue
}
