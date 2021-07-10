import 'dart:convert';

import 'package:foodgood/enums/auth_mode.dart';
import 'package:foodgood/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

class UserModel extends Model {
  List<User> _users = [];
  User _authenticatedUser;
  bool _isLoading = false;

  List<User> get users {
    return List.from(_users);
  }

  User get authenticatedUser {
    return _authenticatedUser;
  }

  bool get isLoading {
    return _isLoading;
  }

  Future<bool> addUserInfo(Map<String, dynamic> userInfo) async {
    // _foods.add(food);
    _isLoading = true;
    notifyListeners();
    try {
      final http.Response response = await http.post(
          "https://foodie2-7feed-default-rtdb.asia-southeast1.firebasedatabase.app/users.json",
          body: json.encode(userInfo));
      final Map<String, dynamic> responseData = json.decode(response.body);

      User userWithID = User(
        id: responseData["name"],
        email: userInfo['email'],
        firstName: userInfo['firstName'],
        lastName: userInfo['lastName'],
        phoneNumber: userInfo['phoneNumber'],
        token: userInfo['token'],
        userType: userInfo['userType'],
        username: userInfo['username'],
      );
      _users.add(userWithID);
      _isLoading = false;
      notifyListeners();
      return Future.value(true);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return Future.value(false);
      // print("Connection error: $e");
    }
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      {AuthMode authMode = AuthMode.SignIn}) async {
    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> authData = {
      "email": email,
      "password": password,
      "returnSecureToken": true,
    };
    String message;
    bool hasError = false;
    try {
      http.Response response;
      if (authMode == AuthMode.SignUp) {
        response = await http.post(
          "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyBdBuWh5dop3SMCl631xgmePGln9tvKuys",
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'},
        );
      } else if (authMode == AuthMode.SignIn) {
        response = await http.post(
          "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBdBuWh5dop3SMCl631xgmePGln9tvKuys",
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'},
        );
      }
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody.containsKey('idToken')) {
        _authenticatedUser = User(
          id: responseBody['localId'],
          email: responseBody['email'],
          token: responseBody['idToken'],
          userType: 'customer',
        );
        if (authMode == AuthMode.SignUp) {
          message = "Sign up successfully";
        } else {
          message = "Sign in successfully";
        }
      } else {
        hasError = true;
        if (responseBody['error']['message'] == 'EMAIL_EXISTS') {
          message = "Email already exists";
        } else if (responseBody['error']['message'] == "EMAIL_NOT_FOUND") {
          message = "Email or password does not exist";
        } else if (responseBody['error']['message'] == "INVALID_PASSWORD") {
          message = "Password is incorrect";
        }
      }
      _isLoading = false;
      notifyListeners();
      return {
        'message': message,
        'hasError': hasError,
      };
    } catch (error) {
      _isLoading = false;
      notifyListeners();

      return {
        'message': 'Failed to sign up successfully',
        'hasError': !hasError,
      };
    }
  }
}
