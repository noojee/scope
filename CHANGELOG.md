# 5.1.0
- changed ScopeKey ctors so they are consts. The examples that show them being consts are now correct.

# 5.0.0
- updated dev dependencies.

# 4.1.1
- Fixed an error in the README example. Use of wrong type.
- Cleared out a few lint fixes.

# 4.1.0
- update links to doc and repo.

# 4.0.1
- upgraded dependencies

# 4.0.0
- upgraded to dart 3.0.

# 3.0.0
- BREAKING: The Scope.run method is now asynchronous. Use Scope.runSync to run a synchronous method.
  You will likely have to change how you call the run method.
  If you have been using something like:
  ``` 

    final scope = Scope()
      ..value<int>(keyAge, 10)
      ..run(()  {
      Future.delayed(oneSecond, () {
        print('Age: ${use(keyAge)}');
      });
    });
  ```

  You will need to change it to:
  ```
    final scope = Scope()
      ..value<int>(keyAge, 10);

    await scope.run(() async {
      Future.delayed(oneSecond, () {
        print('Age: ${use(keyAge)}');
      });
    });
    ```

- added copyright notices.
- Created an example of how overrides work.
- Changed the debugName on ScopeKey.withDefault to optional to match ScopeKey.
- Added missing types from global scope unit tests.

# 2.3.0-beta.1
- Added a GlobalScope object which implements a Singleton pattern which can be overriden by injecting a Scope.

# 2.2.1
- Improved debug messages for ScopeKeys by providing the type and debug name if available.

# 2.2.0
- ENH: Added new method hasScopeValue
- ENH: added withDefault argument to `use` to provide site specific defaults
- BREAKING: Subtle change to method hasScopeKey. Previously it return true if the key was in scope or if it had a default value.  Use hasScopeValue to get the original implementation and use hasScopeKey to check if a key exists.


# 2.1.2
- purged singleton from the doc as it is now single.

# 2.1.1
- purged the term generator for the code/doco as it should be sequence.

# 2.1.0
- Deprecated factory in favour of single. Added sequence in favour of the originally planned generator.

# 2.0.2
updated description again.
# 2.0.1
Updated readme and pubspec description.

# 2.0.0
- renamed packaged to scope.

# 1.0.2
- changed hasScopeKey to not throw an exception internally as it is a pain when debugging with all exception catching on.

# 1.0.1
updated lib to confirm with naming conventions.

## 1.0.0

Initial release.
