import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/authProvider.dart';
import '../../shared/customAppbar.dart';
import '../../responsive/responsive_widgets.dart';
import 'agenda.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);
  static const routeName = '/log-in';

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  // Form controllers and focus nodes
  final _passFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // ScaffoldMessenger reference
  late ScaffoldMessengerState scaffoldMessenger;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please enter valid login information')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Agenda()),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
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
    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Welcome Friend',
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            errorStyle: TextStyle(color: Colors.redAccent),
                          ),
                          style: Theme.of(context).textTheme.bodyLarge,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          focusNode: _emailFocusNode,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please provide a value.';
                            }
                            const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                            final regExp = RegExp(pattern);
                            if (!regExp.hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_passFocusNode);
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            errorStyle: TextStyle(color: Colors.redAccent),
                          ),
                          style: Theme.of(context).textTheme.bodyLarge,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          focusNode: _passFocusNode,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please provide a value.';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _submitForm(),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                          )
                        : Text(
                            'Log In',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const ModalBarrier(
              dismissible: false,
              color: Colors.black54,
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final mediaQuery = MediaQuery.of(context);
    
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Wrap(
              children: [
                // Left side - Form
                Container(
                  width: mediaQuery.size.width * 0.25,
                  alignment: Alignment.center,
                  height: mediaQuery.size.height,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        top: 5.0, bottom: 16.0, left: 25, right: 25),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Welcome Friend',
                          style: Theme.of(context).textTheme.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        Form(
                          autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: mediaQuery.size.width * 0.3,
                                child: TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    errorStyle:
                                        TextStyle(color: Colors.redAccent),
                                  ),
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                  focusNode: _emailFocusNode,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please provide a value.';
                                    }
                                    const pattern =
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                                    final regExp = RegExp(pattern);
                                    if (!regExp.hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context)
                                        .requestFocus(_passFocusNode);
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: mediaQuery.size.width * 0.3,
                                child: TextFormField(
                                  controller: _passwordController,
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    errorStyle:
                                        TextStyle(color: Colors.redAccent),
                                  ),
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: true,
                                  focusNode: _passFocusNode,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please provide a value.';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _submitForm(),
                                ),
                              ),
                              TextButton(
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                )
                              : Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right side - Image
                Container(
                  width: mediaQuery.size.width * 0.75,
                  height: mediaQuery.size.height,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(
                          'assets/images/photos/web/landing_background.png'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const ModalBarrier(
              dismissible: false,
              color: Colors.black54,
            ),
        ],
      ),
    );
  }
}
