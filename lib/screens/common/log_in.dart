import 'package:flutter/material.dart';

import '/screens/common/sign_up.dart';
import '../../date_network/storage.dart';
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

  //final _form = GlobalKey<FormState>();

  final _passFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _consentController = TextEditingController();

  //bool _isSaving = false;
  bool isChecked = false;

  var currUserId;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    //final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final appBar = CustomAppBar();

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        // child: Mutation(
        //   options: MutationOptions(
        //     document: gql(insertUser()),
        //     fetchPolicy: FetchPolicy.noCache,
        //     onCompleted: (data) {
        //       print(data.toString());
        //       setState(() {
        //         _isSaving = false;
        //         currUserId = data!['createUser']["id"];
        //         print(currUserId);
        //       });
        //     },
        //   ),
        //   builder: (runMutation, result) {
        //     return Form(
        //       //autovalidateMode: AutovalidateMode.onUserInteraction,
        //       key: _form,
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
                                //add a check for the short password, password should contain numbers, letters and special characters
                                if (value.length < 11) {
                                  return 'Password must be at least 11 characters long';
                                }
                                if (!RegExp(r'[a-z]').hasMatch(value)) {
                                  return 'Password must contain at least one lowercase letter';
                                }

                                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                  return 'Password must contain at least one uppercase letter';
                                }

                                if (!RegExp(r'\d').hasMatch(value)) {
                                  return 'Password must contain at least one number';
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
                              child: ElevatedButton(
                                child: Text('Sign Up',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                    )),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                onPressed: () {
                                  //_saveForm,
                                  print('sign up button pressed');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpScreen()),
                                  );
                                  // }
                                },
                              ),
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
                                  try {
                                    await loginUser(email, password);
                                    // Navigate to the agenda screen upon successful login
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Agenda()),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('Login failed: $e')),
                                    );
                                  }

                                  // if (_form.currentState!.validate()) {
                                  //   setState(() {
                                  //     _isSaving = true;
                                  //   });
                                  // runMutation({
                                  //   "name": _nameController.text.trim(),
                                  //   "last_name": _lastNameController.text.trim(),
                                  //   "email": _emailController.text.trim(),
                                  //   "password": _passwordController.text.trim(),
                                  //"consent":
                                  //_consentController.text.trim(),
                                  //"profession":
                                  //_professionController.text.trim(),
                                  //"age": int.parse(
                                  //_ageController.text.trim()),
                                  //     });
                                  //     _nameController.clear();
                                  //     _lastNameController.clear();
                                  //     _emailController.clear();
                                  //     _passwordController.clear();
                                  //     //_consentController.clear();
                                  //     //_professionController.clear();
                                  //     //_ageController.clear();
                                  //connect(context);
                                  // }
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

// String insertUser() {
//   return """
//     mutation createUser(\$name: String!, \$last_name: String!,\$email: String!, \$password: String!) {
//       createUser(name: \$name, last_name: \$last_name, email: \$email, password: \$password) {
//         id
//         name
//         last_name
//    }
// }
//   """;
// }
