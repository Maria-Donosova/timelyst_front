import 'package:flutter/material.dart';
import '../../shared/customAppbar.dart';

class EventsAdminScreen extends StatelessWidget {
  const EventsAdminScreen({
    Key? key,
  }) : super(key: key);

  List<DataColumn> _createColumns() {
    return [
      DataColumn(label: Text('ID')),
      DataColumn(label: Text('Title')),
      DataColumn(label: Text('Category')),
      DataColumn(label: Text('From')),
      DataColumn(label: Text('To')),
      DataColumn(label: Text('SourceCalendar')),
      DataColumn(label: Text('CalendarType')),
      DataColumn(label: Text('EventBody')),
      DataColumn(label: Text('User ID')),
      DataColumn(label: Text('User Email')),
      DataColumn(label: Text('User Name')),
      DataColumn(label: Text('Actions')),
    ];
  }

  List<DataRow> _createRows() {
    return [];
  }

  @override
  Widget build(BuildContext context) {
    //final mediaQuery = MediaQuery.of(context);
    //final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final appBar = CustomAppBar();

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Container(
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 150.0, left: 10, right: 10),
              child: DataTable(
                columns: _createColumns(),
                rows: _createRows(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
