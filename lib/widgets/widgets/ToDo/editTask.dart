// import 'package:flutter/material.dart';

// import '../../shared/categories.dart';
// import '../../../services/tasksService.dart';
// import '../../../models/task.dart';
// import '../../../services/authService.dart';

// class EditTaskW extends StatefulWidget {
//   final Task task;
//   final Function(Task) onSave;

//   EditTaskW({
//     required this.task,
//     required this.onSave,
//   });

//   @override
//   State<EditTaskW> createState() => _EditTaskWState();
// }

// class _EditTaskWState extends State<EditTaskW> {
//   final _form = GlobalKey<FormState>();
//   final _taskDescriptionController = TextEditingController();
//   String? selectedCategory;

//   @override
//   void initState() {
//     super.initState();
//     _taskDescriptionController.text = widget.task.title;
//     selectedCategory = widget.task.category;
//   }

//   void _saveTask() async {
//     if (_form.currentState!.validate()) {
//       final updatedTask = Task(
//         taskId: widget.task.taskId,
//         title: _taskDescriptionController.text,
//         status: '',
//         category: selectedCategory!,
//         // dateCreated: widget.task.dateCreated,
//         // dateChanged: DateTime.now(),
//         //creator: widget.task.creator,
//       );

//       try {
//         // Get the auth token from secure storage
//         final authService = AuthService();
//         final authToken = await authService.getAuthToken();

//         if (authToken != null) {
//           await TasksService.updateTask(
//             updatedTask.taskId,
//             authToken,
//             updatedTask,
//           );
//           widget.onSave(updatedTask); // Notify parent widget
//           Navigator.of(context).pop(); // Close the bottom sheet

//           // Show success message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               backgroundColor: Theme.of(context).colorScheme.shadow,
//               content: Text(
//                 'Task updated successfully',
//                 style: Theme.of(context).textTheme.bodyLarge,
//               ),
//             ),
//           );
//         } else {
//           throw Exception('Authentication token not found');
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             backgroundColor: Theme.of(context).colorScheme.shadow,
//             content: Text(
//               'Failed to update task: $e',
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       behavior: HitTestBehavior.opaque,
//       child: Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Card(
//               child: Container(
//                 padding: EdgeInsets.all(10),
//                 child: Form(
//                   key: _form,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       TextFormField(
//                         controller: _taskDescriptionController,
//                         decoration: InputDecoration(labelText: 'Task Title'),
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return 'Please provide a value.';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 15),
//                       DropdownButtonFormField<String>(
//                         hint: Text('Select Category'),
//                         value: selectedCategory,
//                         onChanged: (newValue) {
//                           setState(() {
//                             selectedCategory = newValue;
//                           });
//                         },
//                         selectedItemBuilder: (BuildContext context) {
//                           return categories.map((category) {
//                             return Row(
//                               children: [
//                                 CircleAvatar(
//                                   backgroundColor: catColor(category),
//                                   radius: 5,
//                                 ),
//                                 SizedBox(width: 8),
//                                 Text(category),
//                               ],
//                             );
//                           }).toList();
//                         },
//                         items: categories.map((category) {
//                           return DropdownMenuItem<String>(
//                             value: category,
//                             child: Row(
//                               children: [
//                                 CircleAvatar(
//                                   backgroundColor: catColor(category),
//                                   radius: 5,
//                                 ),
//                                 SizedBox(width: 8),
//                                 Text(category),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           TextButton(
//                             style: TextButton.styleFrom(
//                               backgroundColor:
//                                   Theme.of(context).colorScheme.shadow,
//                             ),
//                             onPressed: _saveTask,
//                             child: Text(
//                               'Save',
//                               style: Theme.of(context).textTheme.bodyLarge,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
