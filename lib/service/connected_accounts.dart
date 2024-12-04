import 'package:flutter/material.dart';
import 'google_connect.dart';

class ConnectedAccounts with ChangeNotifier {
  final GoogleService _googleService = GoogleService();
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

  Future<void> googleSignIn(BuildContext context) async {
    // Use GoogleService to sign in
    String account = await _googleService.googleSignIn(context);
    addAccount(account);
  }

  Future<void> googleSignOut(BuildContext context) async {
    // Use GoogleService to sign out
    String account = await _googleService.googleSignOut(context);
    //String account = await _googleService.googleSignIn.currentUser;
    removeAccount(account);
  }
}
