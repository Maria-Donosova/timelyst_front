import 'package:flutter/material.dart';
import 'package:timelyst_flutter/services/microsoftIntegration/microsoftSignInManager.dart';
import 'package:timelyst_flutter/widgets/screens/common/calendarSettings.dart';
import 'package:timelyst_flutter/widgets/screens/common/connectCalendars.dart';
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
      
      // Extract auth code from URL BEFORE any URL manipulation
      final uri = Uri.parse(html.window.location.href);
      final authCode = uri.queryParameters['code'];
      
      print('🔍 [MicrosoftOAuthCallback] Current URL: ${html.window.location.href}');
      print('🔍 [MicrosoftOAuthCallback] Query parameters: ${uri.queryParameters}');
      print('🔍 [MicrosoftOAuthCallback] Extracted auth code: ${authCode?.substring(0, 10) ?? 'NULL'}...');
      
      if (authCode == null || authCode.isEmpty) {
        throw Exception('No authorization code found in callback URL. URL: ${html.window.location.href}');
      }
      
      print('🔍 [MicrosoftOAuthCallback] Auth code extracted: ${authCode.substring(0, 10)}...');
      
      // Process the auth code through Microsoft Sign-In Manager
      final signInManager = MicrosoftSignInManager();
      final result = await signInManager.handleAuthCallback(authCode);
      
      if (result.userId != null && result.calendars != null) {
        print('✅ [MicrosoftOAuthCallback] Microsoft sign-in successful');
        print('🔍 [MicrosoftOAuthCallback] User: ${result.email} (${result.userId})');
        print('🔍 [MicrosoftOAuthCallback] Found ${result.calendars!.length} calendars');
        
        // Clean up URL before navigation
        html.window.history.replaceState(null, '', '/');
        
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
    // This component is now deprecated - Microsoft OAuth is handled in ConnectCalendars
    // If we somehow reach here, redirect to ConnectCalendars with snackbar error
    if (!_isProcessing && _error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConnectCal()),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Microsoft authorization failed: $_error'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Microsoft Calendar'),
        backgroundColor: Color.fromARGB(255, 6, 117, 208),
      ),
      body: Center(
        child: Column(
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
              'Redirecting to Connect Calendars...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}