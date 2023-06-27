import 'package:flutter/material.dart';

import 'agenda.dart';
import '../../widgets/shared/custom_appbar.dart';

//import '../../utilities/index.dart';

class AgendaSettings extends StatefulWidget {
  const AgendaSettings({Key? key}) : super(key: key);
  static const routeName = '/landing-page-logo';

  @override
  State<AgendaSettings> createState() => _AgendaSettingsState();
}

class _AgendaSettingsState extends State<AgendaSettings> {
  void connectSignUp(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(
      Agenda.routeName,
    );
  }

  final _form = GlobalKey<FormState>();
  // //var _dataPicked = SelectedCalData(
  //     id: '',
  //     all: false,
  //     subject: false,
  //     body: false,
  //     attachements: false,
  //     conference_info: false,
  //     organizer: false,
  //     recepients: false);

  bool isCheckedAll = false;
  bool isCheckedSubj = false;
  bool isCheckedBody = false;
  bool isCheckedAtt = false;
  bool isCheckedConf = false;
  bool isCheckedOrg = false;
  bool isCheckedRec = false;

  //Categories _category = Categories.Work;

  void _saveForm() {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }

    _form.currentState!.save();
    // print('saved');
    // print(_dataPicked.all);
    // print(_dataPicked.subject);
    // print(_dataPicked.body);
    // print(_dataPicked.attachements);
    // print(_dataPicked.conference_info);
    // print(_dataPicked.organizer);
    // print(_dataPicked.recepients);
    //print(_dataPicked.subject);
    connectSignUp(context);
  }

  @override
  Widget build(BuildContext context) {
    final appBar = CustomAppBar();

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _form,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Text(
                    'Choose what you’d like to import for',
                    style: Theme.of(context).textTheme.headline2,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    'Maria Donosova calendar',
                    style: Theme.of(context).textTheme.headline1,
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  color: Colors.grey[200],
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    width: double.infinity,
                    child: const Text(
                      'Information that will be imported',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'All',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Checkbox(
                              checkColor: Colors.grey[800],
                              activeColor:
                                  const Color.fromRGBO(207, 204, 215, 100),
                              visualDensity: VisualDensity.compact,
                              value: isCheckedAll,
                              onChanged: (value) {
                                setState(() {
                                  isCheckedAll = value ?? false;
                                  print(isCheckedAll);
                                });
                                // _dataPicked = SelectedCalData(
                                //     id: _dataPicked.id,
                                //     all: value!,
                                //     subject: _dataPicked.subject,
                                //     body: _dataPicked.body,
                                //     attachements: _dataPicked.attachements,
                                //     conference_info:
                                //         _dataPicked.conference_info,
                                //     organizer: _dataPicked.organizer,
                                //     recepients: _dataPicked.recepients);
                              }),
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Subject',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Checkbox(
                              checkColor: Colors.grey[800],
                              activeColor:
                                  const Color.fromRGBO(207, 204, 215, 100),
                              visualDensity: VisualDensity.compact,
                              value: isCheckedSubj,
                              onChanged: (value) {
                                setState(() {
                                  isCheckedSubj = value ?? false;
                                  print(isCheckedSubj);
                                });
                                // _dataPicked = SelectedCalData(
                                //     id: _dataPicked.id,
                                //     all: _dataPicked.all,
                                //     subject: value!,
                                //     body: _dataPicked.body,
                                //     attachements: _dataPicked.attachements,
                                //     conference_info:
                                //         _dataPicked.conference_info,
                                //     organizer: _dataPicked.organizer,
                                //     recepients: _dataPicked.recepients);
                              }),
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Body',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Checkbox(
                              checkColor: Colors.grey[800],
                              activeColor:
                                  const Color.fromRGBO(207, 204, 215, 100),
                              visualDensity: VisualDensity.compact,
                              value: isCheckedBody,
                              onChanged: (value) {
                                setState(() {
                                  isCheckedBody = value ?? false;
                                  //state.didChange(value);
                                  print(isCheckedBody);
                                });
                                // _dataPicked = SelectedCalData(
                                //     id: _dataPicked.id,
                                //     all: _dataPicked.all,
                                //     subject: _dataPicked.subject,
                                //     body: value!,
                                //     attachements: _dataPicked.attachements,
                                //     conference_info:
                                //         _dataPicked.conference_info,
                                //     organizer: _dataPicked.organizer,
                                //     recepients: _dataPicked.recepients);
                              }),
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Attachments',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Checkbox(
                              checkColor: Colors.grey[800],
                              activeColor:
                                  const Color.fromRGBO(207, 204, 215, 100),
                              visualDensity: VisualDensity.compact,
                              value: isCheckedAtt,
                              onChanged: (value) {
                                setState(() {
                                  isCheckedAtt = value ?? false;
                                  //state.didChange(value);
                                  print(isCheckedAtt);
                                });
                                // _dataPicked = SelectedCalData(
                                //     id: _dataPicked.id,
                                //     all: _dataPicked.all,
                                //     subject: _dataPicked.subject,
                                //     body: _dataPicked.body,
                                //     attachements: value!,
                                //     conference_info:
                                //         _dataPicked.conference_info,
                                //     organizer: _dataPicked.organizer,
                                //     recepients: _dataPicked.recepients);
                              }),
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Conference Info',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Checkbox(
                              checkColor: Colors.grey[800],
                              activeColor:
                                  const Color.fromRGBO(207, 204, 215, 100),
                              visualDensity: VisualDensity.compact,
                              value: isCheckedConf,
                              onChanged: (value) {
                                setState(() {
                                  isCheckedConf = value ?? false;
                                  //state.didChange(value);
                                  print(isCheckedConf);
                                });
                                // _dataPicked = SelectedCalData(
                                //     id: _dataPicked.id,
                                //     all: _dataPicked.all,
                                //     subject: _dataPicked.subject,
                                //     body: _dataPicked.body,
                                //     attachements: _dataPicked.attachements,
                                //     conference_info: value!,
                                //     organizer: _dataPicked.organizer,
                                //     recepients: _dataPicked.recepients);
                              }),
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Organizer',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Checkbox(
                              checkColor: Colors.grey[800],
                              activeColor:
                                  const Color.fromRGBO(207, 204, 215, 100),
                              visualDensity: VisualDensity.compact,
                              value: isCheckedOrg,
                              onChanged: (value) {
                                setState(() {
                                  isCheckedOrg = value ?? false;
                                  //state.didChange(value);
                                  print(isCheckedOrg);
                                });
                                // _dataPicked = SelectedCalData(
                                //     id: _dataPicked.id,
                                //     all: _dataPicked.all,
                                //     subject: _dataPicked.subject,
                                //     body: _dataPicked.body,
                                //     attachements: _dataPicked.attachements,
                                //     conference_info:
                                //         _dataPicked.conference_info,
                                //     organizer: value!,
                                //     recepients: _dataPicked.recepients);
                              }),
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Recpeints Info',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Checkbox(
                              checkColor: Colors.grey[800],
                              activeColor:
                                  const Color.fromRGBO(207, 204, 215, 100),
                              visualDensity: VisualDensity.compact,
                              value: isCheckedRec,
                              onChanged: (value) {
                                setState(() {
                                  isCheckedRec = value ?? false;
                                  //state.didChange(value);
                                  print(isCheckedRec);
                                });
                                // // _dataPicked = SelectedCalData(
                                // //     id: _dataPicked.id,
                                // //     all: _dataPicked.all,
                                // //     subject: _dataPicked.subject,
                                // //     body: _dataPicked.body,
                                // //     attachements: _dataPicked.attachements,
                                // //     conference_info:
                                // //         _dataPicked.conference_info,
                                // //     organizer: _dataPicked.organizer,
                                //     recepients: value!);
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
                // Container(
                //   margin: const EdgeInsets.only(top: 15),
                //   color: Colors.grey[200],
                //   child: Container(
                //     padding: const EdgeInsets.all(4),
                //     width: double.infinity,
                //     child: const Text('Assign Color'),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       const CircleAvatar(
                //         radius: 10,
                //         backgroundColor: Colors.deepPurple,
                //       ),
                //       const CircleAvatar(
                //         radius: 10,
                //         backgroundColor: Colors.green,
                //       ),
                //       const CircleAvatar(
                //         radius: 10,
                //         backgroundColor: Colors.red,
                //       ),
                //       const CircleAvatar(
                //         radius: 10,
                //         backgroundColor: Colors.indigo,
                //       ),
                //       const CircleAvatar(
                //         radius: 10,
                //         backgroundColor: Colors.yellow,
                //       ),
                //       CircleAvatar(
                //         radius: 10,
                //         backgroundColor: Colors.cyan[600],
                //       ),
                //     ],
                //   ),
                // ),
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  color: Colors.grey[200],
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    width: double.infinity,
                    child: const Text('Assign Category'),
                  ),
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 150,
                            // child: RadioListTile(
                            //   activeColor: Colors.deepPurple,
                            //   //visualDensity: VisualDensity.comfortable,
                            //   dense: true,
                            //   value: Categories.Work,
                            //   groupValue: _category,
                            //   title: const Text('Work'),
                            //   onChanged: (Categories? value) {
                            //     setState(() {
                            //       _category = value!;
                            //     });
                            //     print(value);
                            //   },
                            // ),
                          ),
                          Container(
                            width: 150,
                            // child: RadioListTile(
                            //   activeColor: Colors.green,
                            //   //visualDensity: VisualDensity.comfortable,
                            //   dense: true,
                            //   value: Categories.Personal,
                            //   groupValue: _category,
                            //   title: const Text('Personal'),
                            //   onChanged: (Categories? value) {
                            //     setState(() {
                            //       _category = value!;
                            //     });
                            //     print(value);
                            //   },
                            // ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 150,
                          // child: RadioListTile(
                          //   activeColor: Colors.red,
                          //   //visualDensity: VisualDensity.comfortable,
                          //   dense: true,
                          //   value: Categories.Kids,
                          //   groupValue: _category,
                          //   title: const Text('Kids'),
                          //   onChanged: (Categories? value) {
                          //     setState(() {
                          //       _category = value!;
                          //     });
                          //     print(value);
                          //   },
                          // ),
                        ),
                        Container(
                          width: 150,
                          // child: RadioListTile(
                          //   activeColor: Colors.yellow,
                          //   //visualDensity: VisualDensity.comfortable,
                          //   dense: true,
                          //   value: Categories.Friends,
                          //   groupValue: _category,
                          //   title: const Text('Friends'),
                          //   onChanged: (Categories? value) {
                          //     setState(() {
                          //       _category = value!;
                          //     });
                          //     print(value);
                          //   },
                          // ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 150,
                          // child: RadioListTile(
                          //   activeColor: Colors.indigo,
                          //   //visualDensity: VisualDensity.comfortable,
                          //   dense: true,
                          //   value: Categories.Parents,
                          //   groupValue: _category,
                          //   title: const Text('Parents'),
                          //   onChanged: (Categories? value) {
                          //     setState(() {
                          //       _category = value!;
                          //     });
                          //     print(value);
                          //   },
                          // ),
                        ),
                        Container(
                          width: 150,
                          // child: RadioListTile(
                          //   activeColor: Colors.cyan.shade600,
                          //   //visualDensity: VisualDensity.comfortable,
                          //   dense: true,
                          //   value: Categories.Misc,
                          //   groupValue: _category,
                          //   title: const Text('Misc'),
                          //   onChanged: (Categories? value) {
                          //     setState(() {
                          //       _category = value!;
                          //     });
                          //     print(value);
                          //   },
                          // ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey[800],
                    ),
                    child: const Text('Next'),
                    onPressed: () {
                      _saveForm();
                      print(
                        'next button pressed',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
