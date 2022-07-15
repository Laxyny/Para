import 'package:Para/auth/register/register.dart';
import 'package:Para/screens/informations.dart';
import 'package:Para/screens/options.dart';
import 'package:Para/screens/test.dart';
import 'package:Para/screens/view_image.dart';
import 'package:Para/test.dart';
import 'package:Para/utils/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Para/utils/constants.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

var alertStyle = AlertStyle(
    backgroundColor: Colors.black,
    animationType: AnimationType.grow,
    isCloseButton: false,
    isOverlayTapDismiss: false,
    descStyle: TextStyle(fontWeight: FontWeight.bold),
    animationDuration: Duration(milliseconds: 400),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
      side: BorderSide(
        color: Colors.grey,
      ),
    ),
    titleStyle: TextStyle(
      color: Colors.white,
    ),
    constraints: BoxConstraints.expand(width: 300),
    //First to chars "55" represents transparency of color
    overlayColor: Color(0x55000000),
    alertElevation: 0,
    alertAlignment: Alignment.center);

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.keyboard_backspace),
        ),
        backgroundColor: Colors.black,
        elevation: 0.0,
        title: Text(
          "Paramètres",
          style: TextStyle(),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text(
                "A propos",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text("PARA ALPHA REBORN"),
              trailing: Icon(Icons.error),
            ),
            Divider(),
            ListTile(
                onTap: () {
                  Navigator.of(context)
                      .push(CupertinoPageRoute(builder: (_) => Informations()));
                },
                title: Text(
                  "Informations",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text(""),
                trailing: Icon(Icons.info)),
            Divider(),
            ListTile(
                onTap: () {
                  Navigator.of(context)
                      .push(CupertinoPageRoute(builder: (_) => Options()));
                },
                title: Text(
                  "Fonctionnalités",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text("Activer/désactiver des options"),
                trailing: Icon(Icons.info)),
            Divider(),
            /*ListTile(
              title: Text(
                "Mode sombre",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text("Utiliser le mode sombre"),
              trailing: Consumer<ThemeNotifier>(
                builder: (context, notifier, child) => CupertinoSwitch(
                  onChanged: (val) {
                    notifier.toggleTheme();
                  },
                  value: notifier.dark,
                  activeColor: Colors.green,
                ),
              ),
            ),
            Divider(),
            */
            ListTile(
              title: Text(
                "Deconnexion",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text("Déconnecter votre compte"),
              trailing: Icon(
                Icons.logout,
              ),
              onTap: () {
                return Alert(
                  style: alertStyle,
                  context: context,
                  type: AlertType.warning,
                  title: "Deconnexion",
                  desc: "êtes-vous sûr de vouloir vous déconnecter ?",
                  buttons: [
                    DialogButton(
                      child: Text(
                        "Annuler",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.white,
                    ),
                    DialogButton(
                        child: Text(
                          "Continuer",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                        onPressed: () {
                          firebaseAuth.signOut();
                          Navigator.of(context).push(
                              CupertinoPageRoute(builder: (_) => Register()));
                        },
                        color: Colors.white),
                  ],
                ).show();
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                "Supprimer",
                style:
                    TextStyle(fontWeight: FontWeight.w900, color: Colors.red),
              ),
              subtitle: Text("Supprimer votre compte"),
              trailing: Icon(
                Icons.delete_forever,
              ),
              onTap: () {
                return Alert(
                  style: alertStyle,
                  context: context,
                  type: AlertType.warning,
                  title: "Supprimer",
                  desc:
                      "êtes-vous sûr de vouloir supprimer votre compte ? \n Cette action est irréversible",
                  buttons: [
                    DialogButton(
                      child: Text(
                        "Annuler",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.white,
                    ),
                    DialogButton(
                        child: Text(
                          "Supprimer",
                          style: TextStyle(color: Colors.red, fontSize: 18),
                        ),
                        onPressed: () {
                          firebaseAuth.currentUser.delete();
                          firestore
                              .collection('users')
                              .doc(_auth.currentUser.uid)
                              .delete();
                          Navigator.of(context).push(
                              CupertinoPageRoute(builder: (_) => Register()));
                        },
                        color: Colors.white),
                  ],
                ).show();
              },
            ),
          ],
        ),
      ),
    );
  }
}
