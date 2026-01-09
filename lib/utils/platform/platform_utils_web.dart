import 'dart:html' as html;
import 'platform_utils.dart';

class WebPlatformUtils implements PlatformUtils {
  @override
  void openUrl(String url) {
    html.window.open(url, '_blank');
  }

  @override
  void replaceState(String? data, String title, String url) {
    html.window.history.replaceState(data, title, url);
  }

  @override
  void locationReplace(String url) {
    html.window.location.replace(url);
  }
}

PlatformUtils getPlatformUtils() => WebPlatformUtils();
