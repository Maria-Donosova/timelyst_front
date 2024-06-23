import 'package:flutter/material.dart';
import '../shared/categories.dart';

class EditTaskW extends StatefulWidget {
  EditTaskW({super.key});

  @override
  State<EditTaskW> createState() => _EditTaskWState();
}

class _EditTaskWState extends State<EditTaskW> {
  final titleController = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _taskDescriptionController = TextEditingController();
  final _taskFocusNode = FocusNode();
  final _taskTypeController = TextEditingController();
  final _categoryController = TextEditingController();

  void clearInput() {
    _taskDescriptionController.clear;
    selectedCategory = null;
  }

  var currUserId;
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    //final selectedCatColor = catColor;
    return GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Card(
                  elevation: 5,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 10,
                      left: 10,
                      right: 10,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 50,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Colors.grey,
                          width: 3,
                          style: BorderStyle.solid,
                        ),
                      ),
                      shape: BoxShape.rectangle,
                    ),
                    child:
                        // Mutation(
                        //   options: MutationOptions(
                        //     document: gql(insertTask()),
                        //     fetchPolicy: FetchPolicy.noCache,
                        //     onCompleted: (data) {
                        //       print(data.toString());
                        //       setState(() {
                        //         currUserId = (data as Map)['createUser']["id"];
                        //         //currUserId = data['createUser']["id"];
                        //       });
                        //     },
                        //   ),
                        //   builder: (runMutation, result) {
                        //     return
                        Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextFormField(
                            autocorrect: true,
                            controller: _taskDescriptionController,
                            style: Theme.of(context).textTheme.bodyText1,
                            maxLines: null,
                            decoration: const InputDecoration(
                              labelText: 'Add new task',
                              labelStyle: TextStyle(fontSize: 14),
                              border: InputBorder.none,
                              errorStyle: TextStyle(color: Colors.redAccent),
                            ),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please provide a value.';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_taskFocusNode);
                            },
                          ),
                          DropdownButton<String>(
                            hint: Text(
                              'Category',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 14,
                            value: selectedCategory,
                            onChanged: (newValue) {
                              if (_form.currentState!.validate()) {
                                setState(() {
                                  // selectedCategory = newValue;
                                  // runMutation({
                                  //   "task_description":
                                  //       _taskDescriptionController.text
                                  //           .trim(),
                                  //   // "task_type":
                                  //   //  _taskTypeController.text.trim(),
                                  //   "category": _selectedCategory,
                                  //   'userId': currUserId,
                                  // });
                                });
                                Navigator.of(context).pop();
                                clearInput();
                              }
                            },
                            items: categories.map((category) {
                              return DropdownMenuItem(
                                child: Text(category),
                                value: category,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}

// // //   String updateTask() {
// // //     return """
// // //       mutation updateTask(\$task_description: String!, \$task_type: String, \$category: String!, \$userId: String) {
// // //         createTask(task_description: \$task_description, task_type: \$task_type, category: \$category, userId: \$userId) {
// // //           id
// // //           task_description

// // //    }
// // // }
// // // """;
// // //   }
// // // }
