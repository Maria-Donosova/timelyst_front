import 'package:flutter/material.dart';
import 'package:timelyst_flutter/services/microsoftIntegration/microsoftSignInManager.dart';
import 'package:timelyst_flutter/widgets/screens/common/calendarSettings.dart';
import 'dart:html' as html;

class MicrosoftOAuthCallback extends StatefulWidget {
  @override
  _MicrosoftOAuthCallbackState createState() => _MicrosoftOAuthCallbackState();
}

class _MicrosoftOAuthCallbackState extends State<MicrosoftOAuthCallback> {
  bool _isProcessing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _handleOAuthCallback();
  }

  Future<void> _handleOAuthCallback() async {
    try {
      print('🔍 [MicrosoftOAuthCallback] Processing OAuth callback');
      
      // Extract auth code from URL
      final uri = Uri.parse(html.window.location.href);
      final authCode = uri.queryParameters['code'];
      
      if (authCode == null) {
        throw Exception('No authorization code found in callback URL');
      }
      
      print('🔍 [MicrosoftOAuthCallback] Auth code extracted: ${authCode.substring(0, 10)}...');
      
      // Process the auth code through Microsoft Sign-In Manager
      final signInManager = MicrosoftSignInManager();
      final result = await signInManager.handleAuthCallback(authCode);
      
      if (result.userId != null && result.calendars != null) {
        print('✅ [MicrosoftOAuthCallback] Microsoft sign-in successful');
        print('🔍 [MicrosoftOAuthCallback] User: ${result.email} (${result.userId})');
        print('🔍 [MicrosoftOAuthCallback] Found ${result.calendars!.length} calendars');
        
        // Navigate to calendar settings
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CalendarSettings(
                userId: result.userId!,
                email: result.email!,
                calendars: result.calendars!,
              ),
            ),
          );
        }
      } else {
        throw Exception('Microsoft sign-in failed - no user data returned');
      }
      
    } catch (e) {
      print('❌ [MicrosoftOAuthCallback] Error processing callback: $e');
      setState(() {
        _error = e.toString();
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Microsoft Calendar'),
        backgroundColor: Color.fromARGB(255, 6, 117, 208),
      ),
      body: Center(
        child: _isProcessing
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Processing Microsoft authorization...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please wait while we connect your calendar',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Microsoft Authorization Failed',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    _error ?? 'Unknown error occurred',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Go Back'),
                  ),
                ],
              ),
      ),
    );
  }
}