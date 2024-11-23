import 'package:flutter/material.dart';

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
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 16.0),
                      child: Text(
                        'Tell us more about yourself',
                        // ignore: deprecated_member_use
                        style: Theme.of(context).textTheme.displayLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    TextFormField(
                      autocorrect: true,
                      controller: _nameController,
                      // ignore: deprecated_member_use
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(fontSize: 14),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4.0),
                          ),
                        ),
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
                      // onSaved: (value) {
                      //   _signUpUser = User(
                      //       id: _signUpUser.id,
                      //       name: value!,
                      //       lastName: _signUpUser.lastName,
                      //       email: _signUpUser.email,
                      //       password: _signUpUser.password,
                      //       consent: _signUpUser.consent);
                      // },
                    ),
                    TextFormField(
                      autocorrect: true,
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
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
                      // onSaved: (value) {
                      //   _signUpUser = User(
                      //       id: _signUpUser.id,
                      //       name: _signUpUser.name,
                      //       lastName: value!,
                      //       email: _signUpUser.email,
                      //       password: _signUpUser.password,
                      //       consent: _signUpUser.consent);
                      // },
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
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_passFocusNode);
                      },
                      // onSaved: (value) {
                      //   _signUpUser = User(
                      //       id: _signUpUser.id,
                      //       name: _signUpUser.name,
                      //       lastName: _signUpUser.lastName,
                      //       email: value!,
                      //       password: _signUpUser.password,
                      //       consent: _signUpUser.consent);
                      // },
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
                        const pattern =
                            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                        final regExp = RegExp(pattern);

                        if (!regExp.hasMatch(value)) {
                          return 'Please enter a strong password.';
                        }
                        return null;
                      },
                      // onSaved: (value) {
                      //   _signUpUser = User(
                      //       id: _signUpUser.id,
                      //       name: _signUpUser.name,
                      //       lastName: _signUpUser.lastName,
                      //       email: _signUpUser.email,
                      //       password: value!,
                      //       consent: _signUpUser.consent);
                      // },
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
                                  //state.didChange(value);
                                  print(isChecked);
                                });
                                if (value = true) {
                                  // _signUpUser = User(
                                  //   id: _signUpUser.id,
                                  //   name: _signUpUser.name,
                                  //   lastName: _signUpUser.lastName,
                                  //   email: _signUpUser.email,
                                  //   password: _signUpUser.password,
                                  //   consent: value,
                                  // );
                                }
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
                              onPressed: () {
                                //_saveForm,
                                print('sign up button pressed');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const ConnectCal()),
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