import 'package:flutter/widgets.dart';
import 'package:wip/models/user.dart';
import 'package:wip/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User? get getUser => _user;

  Future<void> refreshUser() async {
    try {
      User user = await _authMethods.getUserDetails();
      _user = user;
      notifyListeners();
    } catch (e) {
      print("Failed to fetch user details: $e");
      _user = null;
      notifyListeners();
    }
  }
}
