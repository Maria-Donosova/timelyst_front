import 'package:flutter/material.dart';

List<String> categories = <String>[
  'Work',
  'Personal',
  'Kids',
  'Family',
  'Friends',
  'Social',
  'Misc'
];

Color catColor(String catTitle) {
  switch (catTitle) {
    case "Work":
      return Color.fromRGBO(8, 100, 237, 1);
    case "Personal":
      return Color.fromRGBO(177, 22, 239, 1);
    case "Kids":
      return Color.fromRGBO(114, 219, 233, 1);
    case "Family":
      return Color.fromRGBO(0, 149, 63, 1);
    case "Friends":
      return Color.fromRGBO(255, 239, 91, 1);
    case "Social":
      return Color.fromRGBO(13, 202, 240, 1);
    case "Misc":
      return Color.fromRGBO(249, 200, 42, 1);
    default:
      return Color.fromRGBO(223, 3, 80, 1);
  }
}
