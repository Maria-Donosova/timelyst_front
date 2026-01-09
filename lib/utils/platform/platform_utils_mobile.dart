import 'package:url_launcher/url_launcher.dart';
import 'platform_utils.dart';

class MobilePlatformUtils implements PlatformUtils {
  @override
  void openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void replaceState(String? data, String title, String url) {
    // No-op on mobile/VM as we don't have browser history in the same way
    print('ℹ️ [MobilePlatformUtils] replaceState called (no-op on mobile): $url');
  }

  @override
  void locationReplace(String url) async {
    // On mobile, we launch the URL in a browser/custom tab for OAuth
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

PlatformUtils getPlatformUtils() => MobilePlatformUtils();
