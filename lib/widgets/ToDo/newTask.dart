import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/providers/taskProvider.dart';
import 'package:timelyst_flutter/widgets/shared/categories.dart';

class NewTaskW extends StatefulWidget {
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return NewTaskW();
      },
    );
  }

  @override
  _NewTaskWState createState() => _NewTaskWState();
}

class _NewTaskWState extends State<NewTaskW> {
  final _form = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  String? selectedCategory;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _createTask(BuildContext context) async {
    if (_form.currentState!.validate() && selectedCategory != null) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      try {
        await taskProvider.createTask(
          _taskController.text,
          selectedCategory!,
        );

        final scaffoldContext = ScaffoldMessenger.of(context);
        final themeData = Theme.of(context);

        Navigator.of(context).pop();

        Future.delayed(Duration(milliseconds: 500), () {
          scaffoldContext.showSnackBar(
            SnackBar(
              backgroundColor: themeData.colorScheme.shadow,
              content: Text(
                'Task created successfully',
                style: themeData.textTheme.bodyLarge,
              ),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(10),
              elevation: 6,
            ),
          );
        });
      } catch (e) {
        print('Error creating task: $e');
        final scaffoldContext = ScaffoldMessenger.of(context);
        final themeData = Theme.of(context);

        Navigator.of(context).pop();

        Future.delayed(Duration(milliseconds: 500), () {
          scaffoldContext.showSnackBar(
            SnackBar(
              backgroundColor: themeData.colorScheme.shadow,
              content: Text(
                'Failed to create task: $e',
                style: themeData.textTheme.bodyLarge,
              ),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(10),
              elevation: 6,
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _taskController,
                            decoration: InputDecoration(labelText: 'Task'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please provide a value.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          DropdownButtonFormField<String>(
                            hint: Text('Select Category'),
                            value: selectedCategory,
                            onChanged: (newValue) {
                              setModalState(() {
                                selectedCategory = newValue;
                              });
                            },
                            selectedItemBuilder: (BuildContext context) {
                              return categories.map((category) {
                                return Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: catColor(category),
                                      radius: 5,
                                    ),
                                    SizedBox(width: 8),
                                    Text(category),
                                  ],
                                );
                              }).toList();
                            },
                            items: categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: catColor(category),
                                      radius: 5,
                                    ),
                                    SizedBox(width: 8),
                                    Text(category),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.shadow,
                                ),
                                onPressed: () => _createTask(context),
                                child: Text(
                                  'Save',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}