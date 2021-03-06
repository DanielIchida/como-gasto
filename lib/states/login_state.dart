import 'package:como_gasto/auth_providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginState with ChangeNotifier {
  FirebaseAuth _auth;
  AuthenticationProvider _authenticationProvider;

  SharedPreferences _prefs;

  bool _loggedIn = false;
  bool _loading = true;

  FirebaseUser _user;

  LoginState({
    @required SharedPreferences preferences,
    @required FirebaseAuth firebaseAuth,
  }) {
    _prefs = preferences;
    _auth = firebaseAuth;
    loginState();
  }

  bool isLoggedIn() => _loggedIn;

  bool isLoading() => _loading;

  FirebaseUser currentUser() => _user;

  void login(LoginProvider loginProvider) async {
    _authenticationProvider =
        AuthenticationProvider.createAuthProvider(loginProvider);

    _loading = true;
    notifyListeners();

    var authCredentials = await _authenticationProvider.handleSignIn();

    if (authCredentials != null) {
      final FirebaseUser user = await _auth.signInWithCredential(
          authCredentials);

      if (user != null) {
        print("signed in " + user.displayName);
      }
    }

    _loading = false;
    _loggedIn = _user != null;
    _prefs.setBool('isLoggedIn', _loggedIn);
    notifyListeners();
  }

  void logout() {
    _prefs.clear();
    if (_authenticationProvider != null) {
      _authenticationProvider.logout();
      _authenticationProvider = null;
    }
    _loggedIn = false;
    notifyListeners();
  }

  void loginState() async {
    if (_prefs.containsKey('isLoggedIn')) {
      _user = await _auth.currentUser();
      _loggedIn = _user != null;
      _loading = false;
      notifyListeners();
    } else {
      _loading = false;
      notifyListeners();
    }
  }
}
