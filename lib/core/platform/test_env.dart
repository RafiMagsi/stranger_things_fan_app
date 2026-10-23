import 'test_env_io.dart' if (dart.library.js_interop) 'test_env_web.dart' as impl;

/// True inside `flutter test`. Audio plugins and platform views (the
/// YouTube embed) don't exist there, so those features stay dormant.
bool get isFlutterTest => impl.isFlutterTest;
