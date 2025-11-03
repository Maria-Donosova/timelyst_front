import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../utils/apiClient.dart';
import 'config_service.dart';

class ContactService {
  final ApiClient _apiClient = ApiClient();
  final ConfigService _configService = ConfigService();

  Future<void> sendContactEmail({
    required String subject,
    required String details,
    required String contactEmail,
  }) async {
    // Get the base URL from config or use a default
    final baseUrl =
        _configService.get('API_BASE_URL') ?? 'https://api.timelyst.app';
    final contactEndpoint = '$baseUrl/contact';

    final contactData = {
      'subject': subject,
      'details': details,
      'contactEmail': contactEmail,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      final response = await _apiClient.post(
        contactEndpoint,
        body: contactData,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send contact email: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending contact email: $e');
    }
  }

  // Alternative method using mailto URL launcher as fallback
  Future<void> launchEmailClient({
    required String subject,
    required String details,
    required String contactEmail,
  }) async {
    final emailSubject = Uri.encodeComponent(subject);
    final emailBody = Uri.encodeComponent(details);
    final mailtoUrl =
        'mailto:mariadonosova@/linux/flutter/ephemeral/.plugin_symlinks/connectivity_plus/android/src/main/java/dev/fluttercommunity/plus/connectivity/ConnectivityMethodChannelHandler.java?subject=$emailSubject&body=$emailBody';

    try {
      if (await canLaunchUrl(Uri.parse(mailtoUrl))) {
        await launchUrl(Uri.parse(mailtoUrl));
      } else {
        throw Exception('Could not launch email client');
      }
    } catch (e) {
      throw Exception('Failed to launch email client: $e');
    }
  }

  // Primary method to send email using url_launcher
  Future<void> sendContactEmailDirectly({
    required String subject,
    required String details,
    required String contactEmail,
  }) async {
    try {
      await launchEmailClient(
        subject: subject,
        details: details,
        contactEmail: contactEmail,
      );
    } catch (e) {
      throw Exception('Failed to send contact email: $e');
    }
  }
}
