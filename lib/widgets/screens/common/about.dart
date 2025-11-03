import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/customAppbar.dart';
import '../../responsive/responsive_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);
  static const routeName = '/about';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: ResponsiveBuilder(
        builder: (context, screenSize) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(
              screenSize == ScreenSize.mobile ? 16.0 : 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo
                Image.asset(
                  "assets/images/logos/timelyst_logo.png",
                  height: screenSize == ScreenSize.mobile ? 80 : 120,
                ),
                const SizedBox(height: 30),
                // App Name
                Text(
                  'Timelyst',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 10),
                // Tagline
                Text(
                  'Tame the Time',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 40),
                // About Content
                ResponsiveContainer(
                  maxWidth: screenSize == ScreenSize.mobile ? double.infinity : 600,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Timelyst',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Timelyst is your intelligent time management companion designed to help you organize, prioritize, and make the most of every day. Our app seamlessly integrates with your favorite calendar platforms including Google Calendar, Outlook, and Apple Calendar, bringing all your events and tasks into one unified view.\n\n'
                            'With Timelyst, you can effortlessly manage your schedule, set reminders, and never miss an important deadline. Our intuitive interface adapts to your needs, whether you\'re on your phone, tablet, or desktop.\n\n'
                            'We believe that time is your most valuable resource, and Timelyst is here to help you make every moment count. Join thousands of users who have transformed how they manage their time with our smart, simple, and powerful calendar solution.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Contact Us Button
                ResponsiveButton(
                  text: 'Contact Us',
                  onPressed: () => _launchContactEmail(context),
                  type: ButtonType.primary,
                  icon: Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 20),
                // Version Info
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _launchContactEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@timelyst.app',
      query: 'subject=Timelyst%20App%20Inquiry',
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch email app. Please contact us at support@timelyst.app'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}