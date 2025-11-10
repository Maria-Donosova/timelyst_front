import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/providers/authProvider.dart';
import 'package:timelyst_flutter/services/googleIntegration/googleSignInManager.dart';

/// A banner widget that alerts users when their Google connection needs re-authentication
/// Displays at the top of the screen with a prominent warning message and action button
class GoogleReauthBanner extends StatelessWidget {
  const GoogleReauthBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Only show banner if re-authentication is required
    if (!authProvider.googleReAuthRequired) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        border: Border(
          bottom: BorderSide(
            color: Colors.orange.shade300,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: Colors.orange.shade800,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Google Calendar Connection Lost',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Please re-authenticate to continue syncing',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _handleReauthentication(context, authProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Reconnect',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 20,
              color: Colors.orange.shade800,
            ),
            onPressed: () => authProvider.clearGoogleReAuthRequired(),
            tooltip: 'Dismiss',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReauthentication(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Reconnecting to Google Calendar...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
        ),
      );

      // Trigger Google sign-in flow
      final googleSignInManager = GoogleSignInManager();
      final result = await googleSignInManager.signIn(context);

      if (result != null) {
        // Clear the re-auth flag on success
        authProvider.clearGoogleReAuthRequired();

        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully reconnected to Google Calendar'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to reconnect. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reconnecting: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
