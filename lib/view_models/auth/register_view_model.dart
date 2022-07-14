import 'package:Para/helper/helperductions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Para/auth/register/profile_pic.dart';
import 'package:Para/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterViewModel extends ChangeNotifier {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validate = false;
  bool loading = false;
  String username, email, country, password, cPassword;
  FocusNode usernameFN = FocusNode();
  FocusNode emailFN = FocusNode();
  FocusNode countryFN = FocusNode();
  FocusNode passFN = FocusNode();
  FocusNode cPassFN = FocusNode();
  AuthService auth = AuthService();

  String resultname = "";

  register(BuildContext context) async {
    FormState form = formKey.currentState;
    form.save();
    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showInSnackBar(
          'Veuillez corriger les erreurs en rouge avant de soumettre.',
          context);
    } else {
      if (password == cPassword) {
        loading = true;
        notifyListeners();
        try {
          bool success = await auth.createUser(
            name: username,
            email: email,
            password: password,
            country: country,
          );
          print(success);
          if (success) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            resultname = username;

            print(resultname);
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                builder: (_) => ProfilePicture(),
              ),
            );
          }
        } catch (e) {
          loading = false;
          notifyListeners();
          print(e);
          showInSnackBar(
              '${auth.handleFirebaseAuthError(e.toString())}', context);
        }
        loading = false;
        notifyListeners();
      } else {
        showInSnackBar('Les mots de passe ne correspondent pas', context);
      }
    }
  }

  setEmail(val) {
    email = val;
    notifyListeners();
  }

  setPassword(val) {
    password = val;
    notifyListeners();
  }

  setName(val) {
    username = val;
    HelperFunctions.saveUserNameSharedPreference(val);
    notifyListeners();
  }

  setConfirmPass(val) {
    cPassword = val;
    notifyListeners();
  }

  setCountry(val) {
    country = val;
    notifyListeners();
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
