import 'dart:js_util' as js_util;

class ConfigService {
  final dynamic _windowConfig;

  ConfigService() : _windowConfig = js_util.getProperty(js_util.globalThis, 'config');

  String? get(String name) {
    if (_windowConfig != null) {
      return js_util.getProperty(_windowConfig, name);
    }
    return null;
  }
}
