part of scope;

/// Implements the key store and lookup mechanism. The Injector [Type] is used
/// as the key into a [Zone] to store the injector instance for that zone.
class _Injector {
  _Injector(this.values) : parent = Zone.current[_Injector] as _Injector?;
  const _Injector.empty()
      : values = const <ScopeKey<dynamic>, dynamic>{},
        parent = null;

  final Map<ScopeKey<dynamic>, dynamic> values;
  final _Injector? parent;

  T get<T>(ScopeKey<T> key) {
    if (values.containsKey(key)) {
      dynamic value = values[key];

      /// If the value is a function then we have a sequence
      /// which is called each time [use] is called.
      if (value is Function) {
        // ignore: avoid_dynamic_calls
        return value = value() as T;
      }

      return value as T;
    }
    if (parent != null) {
      return parent!.get(key);
    }
    if (key._defaultValue != _Sentinel.noValue) {
      return key._defaultValue as T;
    }

    if (!isNullable<T>()) {
      throw MissingDependencyException(key);
    }
    return null as T;
  }

  /// true if the [key] is in scope
  /// or if its not in scope but has a default
  /// value.
  bool hasValue<T>(ScopeKey<T> key) {
    if (values.containsKey(key)) {
      return true;
    }
    if (parent != null) {
      return parent!.hasKey(key);
    }
    if (key._defaultValue != _Sentinel.noValue) {
      return true;
    }

    return false;
  }

  /// true if [key] is in scope.
  bool hasKey<T>(ScopeKey<T> key) {
    if (values.containsKey(key)) {
      return true;
    }
    if (parent != null) {
      return parent!.hasKey(key);
    }

    return false;
  }
}
