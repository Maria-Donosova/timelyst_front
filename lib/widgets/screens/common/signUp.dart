import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/authProvider.dart';
import '../../shared/customAppbar.dart';
import '../../responsive/responsive_widgets.dart';
import 'connectCalendars.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  static const routeName = '/sign-up';

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _lnFocusNode = FocusNode();
  final _passFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  final _form = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSaving = false;
  bool isChecked = false;

  var currUserId;

  @override
  Widget build(BuildContext context) {
    final appBar = CustomAppBar();
    final screenSize = ResponsiveHelper.getScreenSize(context);

    return Scaffold(
      appBar: appBar,
      body: ResponsiveBuilder(
        builder: (context, screenSize) {
          // For mobile phones, show only the form without background
          if (screenSize == ScreenSize.mobile) {
            return _buildMobileForm();
          }
          // For tablet and desktop, show form with background image
          return _buildDesktopLayout();
        },
      ),
    );
  }

  Widget _buildMobileForm() {
    return AdaptiveForm(
      formKey: _form,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ResponsiveHeadline(
              'Tell us more about yourself',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveSpacing.getTitleSpacing(context)),
            ResponsiveFormField(
              labelText: 'Name',
              controller: _nameController,
              keyboardType: TextInputType.name,
              validator: ResponsiveFormValidator.validateName,
              onFieldSubmitted: () {
                FocusScope.of(context).requestFocus(_lnFocusNode);
              },
            ),
            ResponsiveFormField(
              labelText: 'Last Name',
              controller: _lastNameController,
              keyboardType: TextInputType.name,
              focusNode: _lnFocusNode,
              validator: ResponsiveFormValidator.validateName,
              onFieldSubmitted: () {
                FocusScope.of(context).requestFocus(_emailFocusNode);
              },
            ),
            ResponsiveFormField(
              labelText: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              focusNode: _emailFocusNode,
              validator: ResponsiveFormValidator.validateEmail,
              onFieldSubmitted: () {
                FocusScope.of(context).requestFocus(_passFocusNode);
              },
            ),
            ResponsiveFormField(
              labelText: 'Password',
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              focusNode: _passFocusNode,
              validator: ResponsiveFormValidator.validatePassword,
            ),
            ResponsiveCheckboxRow(
              label: 'I would like to receive T-Emails',
              value: isChecked,
              onChanged: (value) {
                setState(() {
                  isChecked = value ?? false;
                });
              },
            ),
            SizedBox(height: ResponsiveSpacing.getSectionSpacing(context)),
            ResponsiveCaptionText(
              'By signing up, you agree to our Terms, Data Policy and Cookies Policy.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveSpacing.getButtonSpacing(context)),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SafeArea(
      child: Row(
        children: [
          // Left side - Form (40% width)
          Expanded(
            flex: 4,
            child: AdaptiveForm(
              formKey: _form,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ResponsiveHeadline(
                      'Tell us more about yourself',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ResponsiveSpacing.getTitleSpacing(context)),
                    ResponsiveFormField(
                      labelText: 'Name',
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      validator: ResponsiveFormValidator.validateName,
                      onFieldSubmitted: () {
                        FocusScope.of(context).requestFocus(_lnFocusNode);
                      },
                    ),
                    ResponsiveFormField(
                      labelText: 'Last Name',
                      controller: _lastNameController,
                      keyboardType: TextInputType.name,
                      focusNode: _lnFocusNode,
                      validator: ResponsiveFormValidator.validateName,
                      onFieldSubmitted: () {
                        FocusScope.of(context).requestFocus(_emailFocusNode);
                      },
                    ),
                    ResponsiveFormField(
                      labelText: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      focusNode: _emailFocusNode,
                      validator: ResponsiveFormValidator.validateEmail,
                      onFieldSubmitted: () {
                        FocusScope.of(context).requestFocus(_passFocusNode);
                      },
                    ),
                    ResponsiveFormField(
                      labelText: 'Password',
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      focusNode: _passFocusNode,
                      validator: ResponsiveFormValidator.validatePassword,
                    ),
                    ResponsiveCheckboxRow(
                      label: 'I would like to receive T-Emails',
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value ?? false;
                        });
                      },
                    ),
                    SizedBox(height: ResponsiveSpacing.getSectionSpacing(context)),
                    ResponsiveCaptionText(
                      'By signing up, you agree to our Terms, Data Policy and Cookies Policy.',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ResponsiveSpacing.getButtonSpacing(context)),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
          // Right side - Image (60% width)
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/photos/web/landing_background.png'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return _isSaving
        ? const CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          )
        : ResponsiveButton(
            text: 'Sign Up',
            isLoading: _isSaving,
            onPressed: () async {
              final email = _emailController.text.trim();
              final password = _passwordController.text.trim();
              final name = _nameController.text.trim();
              final lastName = _lastNameController.text.trim();
              final consent = isChecked;
              
              if (_form.currentState!.validate()) {
                try {
                  setState(() {
                    _isSaving = true;
                  });
                  await Provider.of<AuthProvider>(context, listen: false)
                      .register(email, password, name, lastName, consent);
                  setState(() {
                    _isSaving = false;
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ConnectCal()),
                  );
                } catch (e) {
                  setState(() {
                    _isSaving = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registration failed: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter valid sign up information'),
                  ),
                );
              }
            },
          );
  }
}
