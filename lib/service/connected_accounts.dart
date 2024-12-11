import 'package:flutter/material.dart';

class ConnectedAccounts with ChangeNotifier {
  List<String> _connectedAccounts = [];

  List<String> get connectedAccounts => _connectedAccounts;

  void addAccount(String account) {
    // Check if the account is already in the list
    if (!_connectedAccounts.contains(account)) {
      print('Adding account: $account');
      _connectedAccounts.add(account);
      notifyListeners();
    } else {
      print('Account already exists: $account');
    }
  }

  void removeAccount(String account) {
    print('Removing account: $account');
    _connectedAccounts.remove(account);
    notifyListeners();
  }
}
