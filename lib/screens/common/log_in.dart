import 'package:flutter/material.dart';

import '../../widgets/shared/custom_appbar.dart';
import 'agenda.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);
  static const routeName = '/log-in';

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  void connect(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(
      Agenda.routeName,
    );
  }

  final _lnFocusNode = FocusNode();
  final _passFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  //final _form = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  //final _consentController = TextEditingController();

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
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0, bottom: 16.0),
                    child: Text(
                      'Almost there, log in',
                      // ignore: deprecated_member_use
                      style: Theme.of(context).textTheme.headline1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextFormField(
                    autocorrect: true,
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(fontSize: 14),
                      border: UnderlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4.0),
                        ),
                      ),
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
                      // add a check for the non-existing user
                      //if ()
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
                      labelStyle: TextStyle(fontSize: 14),
                      border: UnderlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4.0),
                        ),
                      ),
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
                      // add a check for the invalid password
                      // if ()
                      return null;
                    },
                    // onPressed: (value) {
                    //   _signUpUser = User(
                    //       id: _signUpUser.id,
                    //       email: _signUpUser.email,
                    //       password: value!,
                    //       consent: _signUpUser.consent);                    // },
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: TextButton(
                          child: Text(
                            'Forgot the password?',
                            softWrap: true,
                          ),
                          onPressed: () => {},
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
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
                            child: const Text(
                              'Log In',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                            ),
                            onPressed: () {
                              //_saveForm,
                              print('log in button pressed');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Agenda()),
                              );
                              //connect(context);

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
                ]),
          ),
          //     );
          //   },
          // ),
        ),
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
