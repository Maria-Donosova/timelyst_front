import 'package:universal_html/html.dart' as html;
import 'dart:convert';

class ConfigService {
  final dynamic _windowConfig;

  ConfigService() : _windowConfig = html.window.getProperty('config');

  String? get(String name) {
    if (_windowConfig != null) {
      final properties = Map<String, dynamic>.from(json.decode(json.encode(_windowConfig)));
      return properties[name];
    }
    return null;
  }
}
