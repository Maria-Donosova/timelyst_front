import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelyst_flutter/services/appleIntegration/appleCalDAVManager.dart';
import 'package:timelyst_flutter/services/appleIntegration/appleSignInResult.dart';

/// Form widget for connecting Apple Calendar using Apple ID and App-Specific Password
class AppleCalendarConnectionForm extends StatefulWidget {
  final Function(AppleSignInResult) onSuccess;
  final Function(String) onError;
  final VoidCallback? onCancel;

  const AppleCalendarConnectionForm({
    Key? key,
    required this.onSuccess,
    required this.onError,
    this.onCancel,
  }) : super(key: key);

  @override
  State<AppleCalendarConnectionForm> createState() => _AppleCalendarConnectionFormState();
}

class _AppleCalendarConnectionFormState extends State<AppleCalendarConnectionForm> {
  final _formKey = GlobalKey<FormState>();
  final _appleIdController = TextEditingController();
  final _appPasswordController = TextEditingController();
  final _appleCalDAVManager = AppleCalDAVManager();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _appleIdController.dispose();
    _appPasswordController.dispose();
    super.dispose();
  }

  String? _validateAppleId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Apple ID is required';
    }
    
    // Basic email validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  String? _validateAppPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'App-Specific Password is required';
    }
    
    // Remove dashes and check if it's 16 alphanumeric characters
    final cleanPassword = value.replaceAll('-', '');
    if (cleanPassword.length != 16) {
      return 'App-Specific Password must be 16 characters';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(cleanPassword)) {
      return 'App-Specific Password contains invalid characters';
    }
    
    return null;
  }

  void _formatAppPassword() {
    final text = _appPasswordController.text.replaceAll('-', '');
    if (text.length <= 16) {
      String formatted = '';
      for (int i = 0; i < text.length; i++) {
        if (i > 0 && i % 4 == 0) {
          formatted += '-';
        }
        formatted += text[i];
      }
      
      if (formatted != _appPasswordController.text) {
        _appPasswordController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  Future<void> _connectAppleCalendar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      
      final result = await _appleCalDAVManager.connectAppleCalendar(
        appleId: _appleIdController.text.trim(),
        appPassword: _appPasswordController.text.trim(),
      );

      widget.onSuccess(result);
      
    } catch (e) {
      print('❌ [AppleCalendarConnectionForm] Connection failed: $e');
      widget.onError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.apple,
                  size: 28,
                  color: Colors.black,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Connect Apple Calendar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.onCancel != null)
                  IconButton(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Apple Calendar syncs every 15 minutes. You\'ll need an App-Specific Password from your Apple ID settings.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Apple ID field
            TextFormField(
              controller: _appleIdController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              validator: _validateAppleId,
              decoration: const InputDecoration(
                labelText: 'Apple ID',
                hintText: 'your.email@icloud.com',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // App-Specific Password field
            TextFormField(
              controller: _appPasswordController,
              obscureText: _obscurePassword,
              maxLength: 19, // 16 chars + 3 dashes
              validator: _validateAppPassword,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-]')),
              ],
              onChanged: (_) => _formatAppPassword(),
              decoration: InputDecoration(
                labelText: 'App-Specific Password',
                hintText: 'xxxx-xxxx-xxxx-xxxx',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                    IconButton(
                      onPressed: () => AppleCalDAVManager.showAppPasswordHelp(context),
                      icon: const Icon(Icons.help_outline),
                      tooltip: 'How to generate App-Specific Password',
                    ),
                  ],
                ),
                border: const OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),

            // Connect button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _connectAppleCalendar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Connect Apple Calendar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Help text
            Center(
              child: TextButton.icon(
                onPressed: () => AppleCalDAVManager.showAppPasswordHelp(context),
                icon: const Icon(Icons.help_outline, size: 16),
                label: const Text(
                  'How to generate App-Specific Password',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}