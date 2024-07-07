// import 'package:flutter/material.dart';

// class FilterTasksEvents extends StatelessWidget {
//   FilterTasksEvents({Key? key}) : super(key: key);

//   TextEditingController _searchController = TextEditingController();
//   List<String> _allTasksEvents = [
//     'Task 1',
//     'Event 1',
//     'Task 2',
//     'Event 2'
//   ]; // Example list
//   List<String> _filteredTasksEvents = [];

//   @override
//   void initState() {
//     super.initState();
//     _filteredTasksEvents = _allTasksEvents;
//     _searchController.addListener(_filterTasksEvents);
//   }

//   void _filterTasksEvents() {
//     String query = _searchController.text.toLowerCase();
//     setState(() {
//       _filteredTasksEvents = _allTasksEvents.where((taskEvent) {
//         return taskEvent.toLowerCase().contains(query);
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Filter Tasks & Events'),
//       ),
//       body: Column(
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 labelText: 'Search',
//                 suffixIcon: Icon(Icons.search),
//               ),
//             ),
//           ),
//           Expanded(
//             child: FIlterByTaskEvent(),
//           ),
//         ],
//       ),
//     );
//   }

//   ListView FIlterByTaskEvent() {
//     return ListView.builder(
//             itemCount: _filteredTasksEvents.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text(_filteredTasksEvents[index]),
//               );
//             },
//           );
//   }

//   // @override
//   // void dispose() {
//   //   _searchController.dispose();
//   //   super.dispose();
//   // }
// }
