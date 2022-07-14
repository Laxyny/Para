import 'package:Para/screens/view_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseFirestore _auth = FirebaseFirestore.instance;

String username;

final _fireStore = FirebaseFirestore.instance;
//final FirebaseAuth _auth = FirebaseAuth.instance;

final _usersRef = _fireStore.collection('users');

final followersRef = _fireStore.collection('followers');

final followingRef = _fireStore.collection('following');

class Constants {
  //App related strings
  static String appName = "Para";
  static String myName = "";

  static Color colorUserMe = Colors.blue[600];
  static Color colorUserOther = Colors.grey[800];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  get nomUtilisateur => _firestore
          .collection('users')
          .doc(_auth.currentUser.uid)
          .get()
          .then((value) {
        username = value['username'];
      });

  //Colors for theme
  static Color lightPrimary = Color(0xfff3f4f9);
  static Color darkPrimary = Color(0xff2B2B2B);

  static Color lightAccent = Color(0xFF2B1EEB);

  static Color darkAccent = Color(0xFF2B1EEB);

  static Color lightBG = Color(0xfff3f4f9);
  static Color darkBG = Color(0xff2B2B2B);

  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Lato-Regular',
    backgroundColor: lightBG,
    primaryColor: lightPrimary,
    accentColor: lightAccent,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: lightAccent,
    ),
    scaffoldBackgroundColor: lightBG,
    bottomAppBarTheme: BottomAppBarTheme(
      elevation: 0,
      color: lightBG,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      textTheme: TextTheme(
        headline6: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Lato-Regular',
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    fontFamily: 'Lato-Regular',
    brightness: Brightness.dark,
    backgroundColor: darkBG,
    primaryColor: darkPrimary,
    accentColor: Colors.white,
    scaffoldBackgroundColor: darkBG,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: lightAccent,
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      elevation: 0,
      color: darkBG,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      textTheme: TextTheme(
        headline6: TextStyle(
          color: lightBG,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Lato-Regular',
        ),
      ),
    ),
  );

  static List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }
}

class ThemeNotifier extends ChangeNotifier {
  final String key = 'theme';
  SharedPreferences _prefs;
  bool _darkTheme;
  bool get dark => _darkTheme;

  ThemeNotifier() {
    _darkTheme = true;
    _loadfromPrefs();
  }
  toggleTheme() {
    _darkTheme = !_darkTheme;
    _saveToPrefs();
    notifyListeners();
  }

  _initPrefs() async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
  }

  _loadfromPrefs() async {
    await _initPrefs();
    _darkTheme = _prefs.getBool(key) ?? true;
    notifyListeners();
  }

  _saveToPrefs() async {
    await _initPrefs();
    _prefs.setBool(key, _darkTheme);
  }
}
