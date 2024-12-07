import 'package:flutter/material.dart';

class ConnectedAccounts with ChangeNotifier {
  List<String> _connectedAccounts = [];

  List<String> get connectedAccounts => _connectedAccounts;

  void addAccount(String account) {
    print('Adding account: $account');
    _connectedAccounts.add(account);
    notifyListeners();
  }

  void removeAccount(String account) {
    print('Removing account: $account');
    _connectedAccounts.remove(account);
    notifyListeners();
  }
}
