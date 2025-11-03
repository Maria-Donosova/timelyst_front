import 'package:flutter/material.dart';
import '../../shared/customAppbar.dart';
import '../../responsive/responsive_widgets.dart';
import '../../responsive/responsive_form_field.dart';
import '../../responsive/responsive_button.dart';
import '../../responsive/adaptive_form.dart';
import '../../../services/contactService.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);
  static const routeName = '/contact';

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _detailsController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectFocusNode = FocusNode();
  final _detailsFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  bool _isLoading = false;
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _detailsController.dispose();
    _emailController.dispose();
    _subjectFocusNode.dispose();
    _detailsFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final contactService = ContactService();
      await contactService.sendContactEmailDirectly(
        subject: _subjectController.text.trim(),
        details: _detailsController.text.trim(),
        contactEmail: _emailController.text.trim(),
      );

      if (mounted) {
        _scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Your message has been sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form after successful submission
        _formKey.currentState?.reset();
        _subjectController.clear();
        _detailsController.clear();
        _emailController.clear();
      }
    } catch (e) {
      if (mounted) {
        _scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
            child: AdaptiveForm(
              formKey: _formKey,
              centerForm: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Header
                  Text(
                    'Contact Us',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We\'d love to hear from you',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),
                  const SizedBox(height: 40),
                  // Contact Form
                  ResponsiveContainer(
                    maxWidth:
                        screenSize == ScreenSize.mobile ? double.infinity : 600,
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
                              'Send us a message',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            // Subject Field
                            ResponsiveFormField(
                              labelText: 'Subject',
                              controller: _subjectController,
                              focusNode: _subjectFocusNode,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a subject';
                                }
                                if (value.length < 3) {
                                  return 'Subject must be at least 3 characters long';
                                }
                                return null;
                              },
                              onFieldSubmitted: () {
                                FocusScope.of(context)
                                    .requestFocus(_emailFocusNode);
                              },
                              prefixIcon: Icon(Icons.subject),
                            ),
                            const SizedBox(height: 16),
                            // Email Field
                            ResponsiveFormField(
                              labelText: 'Contact Email',
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              validator: ResponsiveFormValidator.validateEmail,
                              onFieldSubmitted: () {
                                FocusScope.of(context)
                                    .requestFocus(_detailsFocusNode);
                              },
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            const SizedBox(height: 16),
                            // Details Field
                            ResponsiveFormField(
                              labelText: 'Details',
                              controller: _detailsController,
                              focusNode: _detailsFocusNode,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              minLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter message details';
                                }
                                if (value.length < 10) {
                                  return 'Please provide more details (at least 10 characters)';
                                }
                                return null;
                              },
                              onFieldSubmitted: () => _submitForm(),
                              prefixIcon: Icon(Icons.message_outlined),
                            ),
                            const SizedBox(height: 32),
                            // Submit Button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.send),
                                        const SizedBox(width: 8),
                                        Text('Submit'),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
