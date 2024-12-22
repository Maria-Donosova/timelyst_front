import 'package:flutter/material.dart';
import '../../widgets/shared/customAppbar.dart';

class UsersAdminScreen extends StatelessWidget {
  const UsersAdminScreen({
    Key? key,
  }) : super(key: key);

  List<DataColumn> _createColumns() {
    return [
      DataColumn(label: Text('ID')),
      DataColumn(label: Text('Name')),
      DataColumn(label: Text('Last Name')),
      DataColumn(label: Text('Email')),
      DataColumn(label: Text('Password')),
      DataColumn(label: Text('Tasks')),
      DataColumn(label: Text('Events')),
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
