import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

import '../../widgets/shared/custom_appbar.dart';

import 'connect_calendars.dart';

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
    //final mediaQuery = MediaQuery.of(context);
    //final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final appBar = CustomAppBar();

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 120.0, left: 30, right: 30),
          child: Form(
            key: _form,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 16.0),
                      child: Text(
                        'Tell us more about yourself',
                        style: Theme.of(context).textTheme.displayLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    TextFormField(
                      autocorrect: true,
                      controller: _nameController,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        errorStyle: TextStyle(color: Colors.redAccent),
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        } else {
                          return null;
                        }
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_lnFocusNode);
                      },
                    ),
                    TextFormField(
                      autocorrect: true,
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        errorStyle: TextStyle(color: Colors.redAccent),
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.name,
                      focusNode: _lnFocusNode,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_emailFocusNode);
                      },
                    ),
                    TextFormField(
                      autocorrect: true,
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
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        errorStyle: TextStyle(color: Colors.redAccent),
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      focusNode: _passFocusNode,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        }
                        const pattern =
                            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                        final regExp = RegExp(pattern);

                        if (!regExp.hasMatch(value)) {
                          return 'Please enter a strong password.';
                        }
                        return null;
                      },
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Checkbox(
                              checkColor: Colors.grey[800],
                              activeColor:
                                  const Color.fromRGBO(207, 204, 215, 100),
                              visualDensity: VisualDensity.compact,
                              value: isChecked,
                              onChanged: (value) {
                                setState(() {
                                  isChecked = value ?? false;
                                  print(isChecked);
                                });
                                if (value = true) {}
                                return;
                              }),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            'I would like to receive T-Emails',
                            softWrap: true,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Text(
                        'By signing up, you agree to our Terms, Data Policy and Cookies Policy.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 30.0),
                            child: ElevatedButton(
                              child: Text('Sign Up',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  )),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.shadow,
                              ),
                              onPressed: () async {
                                print('sign up button pressed');
                                final email = _emailController.text.trim();
                                final password =
                                    _passwordController.text.trim();
                                final name = _nameController.text.trim();
                                final lastName =
                                    _lastNameController.text.trim();
                                final consent = isChecked;
                                if (_form.currentState!.validate()) {
                                  try {
                                    setState(() {
                                      _isSaving = true;
                                    });
                                    await Provider.of<AuthProvider>(context,
                                            listen: false)
                                        .register(email, password, name,
                                            lastName, consent);
                                    setState(() {
                                      _isSaving = false;
                                    });
                                    // await registerUser(email, password, name,
                                    //     lastName, consent);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ConnectCal()),
                                    );
                                  } catch (e) {
                                    setState(() {
                                      _isSaving = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Registration failed: $e')),
                                    );
                                    print("error: $e");
                                  }
                                } else
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Please enter valid sign up information'),
                                    ),
                                  );
                              },
                            ),
                          ),
                  ]),
            ),
          ),
          //     );
          //   },
          // ),
        ),
      ),
    );
  }
}
