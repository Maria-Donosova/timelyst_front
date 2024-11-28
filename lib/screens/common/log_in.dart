import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '/screens/common/sign_up.dart';
import '../../data/login_user.dart';
import '../../widgets/shared/custom_appbar.dart';
import 'agenda.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);
  static const routeName = '/log-in';

// override the createState method to return the state
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

// navigate to agenda screen
class _LogInScreenState extends State<LogInScreen> {
  void connect(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(
      Agenda.routeName,
    );
  }

  final _passFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  //bool _isSaving = false;
  bool isChecked = false;

  var currUserId;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    //final authProvider = Provider.of<AuthProvider>(context);

    //final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final appBar = CustomAppBar();

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Wrap(
            children: [
              Container(
                width: mediaQuery.size.width * 0.25,
                alignment: Alignment.center,
                height: mediaQuery.size.height,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      top: 5.0, bottom: 16.0, left: 25, right: 25),
                  child: Column(children: <Widget>[
                    Text(
                      'Welcome Friend',
                      style: Theme.of(context).textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: mediaQuery.size.width * 0.3,
                            child: TextFormField(
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
                          Container(
                            width: mediaQuery.size.width * 0.3,
                            child: TextFormField(
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
                                  return 'Wrong password.';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: TextButton(
                              child: Text(
                                'Forgot the password?',
                                softWrap: true,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ),
                              onPressed: () => {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Container(
                        width: mediaQuery.size.width * 0.2,
                        child: Wrap(
                          alignment: WrapAlignment.spaceAround,
                          runAlignment: WrapAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              // child: ElevatedButton(
                              //   child: Text('Sign Up',
                              //       style: TextStyle(
                              //         color: Theme.of(context)
                              //             .colorScheme
                              //             .onSecondary,
                              //       )),
                              //   style: ElevatedButton.styleFrom(
                              //     backgroundColor:
                              //         Theme.of(context).colorScheme.secondary,
                              //   ),
                              //   onPressed: () {
                              //     //_saveForm,
                              //     print('sign up button pressed');
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //           builder: (context) =>
                              //               const SignUpScreen()),
                              //     );
                              //     // }
                              //   },
                              // ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton(
                                child: Text('Log In',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                    )),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                onPressed: () async {
                                  print('log in button pressed');
                                  final email = _emailController.text.trim();
                                  final password =
                                      _passwordController.text.trim();
                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      //await loginUser(email, password);
                                      await Provider.of<AuthProvider>(context,
                                              listen: false)
                                          .login(email, password);
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Agenda()),
                                      );
                                      // Navigate to the agenda screen upon successful login
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('Login failed: $e')),
                                      );
                                      print("error: $e");
                                    }
                                  } else
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Please enter valid login information'),
                                      ),
                                    );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              Container(
                width: mediaQuery.size.width * 0.75,
                height: mediaQuery.size.height,
                child: Image(
                  fit: BoxFit.fill,
                  image:
                      AssetImage('/images/photos/web/landing_background.png'),
                ),
              )
            ],
          ),
        ),
        //     );
        //   },
        // ),
      ),
    );
  }
}
