abstract class PlatformUtils {
  void openUrl(String url);
  void replaceState(String? data, String title, String url);
  void locationReplace(String url);
}

PlatformUtils getPlatformUtils() => throw UnsupportedError('Cannot create PlatformUtils');
