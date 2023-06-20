import 'package:flutter/material.dart';

class SearchW extends StatelessWidget {
  SearchW({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      margin: const EdgeInsets.only(bottom: 4),
      child: TextField(
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: const InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
