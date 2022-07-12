import 'dart:io';

import 'package:Para/auth/register/register.dart';
import 'package:Para/models/user.dart';
import 'package:Para/screens/test.dart';
import 'package:Para/screens/view_image.dart';
import 'package:Para/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:Para/utils/constants.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Informations extends StatefulWidget {
  @override
  _InformationsState createState() => _InformationsState();
}

String username;
String country;

String flutterVersionName;

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> checkAvailable() async {
  DocumentReference documentReference =
      FirebaseFirestore.instance.collection('para').doc('para');

  bool serveurs = (await documentReference.get()).get('serveurs');
}

bool bddserv = true;

String currentUid() {
  return firebaseAuth.currentUser.uid;
}

currentUserEmail() {
  return _auth.currentUser.email;
}

currentUserNum() {
  return currentUserId().phoneNumber;
}

class _InformationsState extends State<Informations> {
  List<DocumentSnapshot> filteredUsers = [];
  User user;
  bool isLoading = false;
  int postCount = 0;
  int followersCount = 0;
  int followingCount = 0;
  bool isToggle = true;
  bool isFollowing = false;
  UserModel users;
  final DateTime timestamp = DateTime.now();
  ScrollController controller = ScrollController();

  final Stream<DocumentSnapshot<Map<String, dynamic>>> _usersStream =
      FirebaseFirestore.instance.collection('para').doc('para').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('para')
            .doc('para')
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
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
                "Informations",
                style: TextStyle(),
              ),
            ),
            backgroundColor: Colors.black,
            body: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(_auth.currentUser.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  return Padding(
                    padding: EdgeInsets.all(10.0),
                    child: ListView(
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            "COMPTE",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          subtitle: Text(""),

                          //trailing: Icon(Icons.error),
                        ),
                        Divider(),
                        ListTile(
                          //onTap: () {},
                          title: Text(
                            "Nom d'utilisateur",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          subtitle:
                              Text(snapshot.data['username'] ?? 'Indisponible'),
                          //trailing: Icon(Icons.info),
                        ),
                        Divider(),
                        ListTile(
                          //onTap: () {},
                          title: Text(
                            "Email",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          subtitle: Text(currentUserEmail() ?? 'Indisponible'),
                          //trailing: Icon(Icons.info),
                        ),
                        Divider(),
                        ListTile(
                          //onTap: () {},
                          title: Text(
                            "Numéro de téléphone",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          //subtitle: Text('Indisponible'),
                          subtitle: Text(_auth.currentUser.phoneNumber != null
                              ? 'Indisponible'
                              : 'Indisponible'),
                        ),
                        Divider(),
                        ListTile(
                          //onTap: () {},
                          title: Text(
                            "Pays",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          subtitle:
                              Text(snapshot.data['country'] ?? 'Indisponible'),
                          //trailing: Icon(Icons.info),
                        ),
                        //trailing: Icon(Icons.info),
                        Divider(height: 100),
                        ListTile(
                          /*onTap: () {
                            Navigator.of(context).push(
                                CupertinoPageRoute(builder: (_) => HogeApp()));
                          },*/
                          title: Text(
                            "PARA",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          subtitle: Text(''),
                        ),
                        //trailing: Icon(Icons.info),
                        Divider(),
                        ListTile(
                          onTap: () {
                            print(checkAvailable());
                            print('LOG');
                          },
                          title: Text(
                            "Etats des serveurs",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          trailing: bddserv == true
                              ? Icon(
                                  Icons.check_circle_outline_outlined,
                                  color: Colors.green,
                                )
                              : Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                ),
                          subtitle: Text(
                            bddserv == true
                                ? 'Fonctionne normalement'
                                : 'Erreur base de données',
                            style: bddserv == true
                                ? TextStyle(color: Colors.green)
                                : TextStyle(color: Colors.red),
                          ),
                        ),
                        //trailing: Icon(Icons.info),
                        Divider(),
                        StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('para')
                                .doc('para')
                                .snapshots(),
                            builder: (context, snapshot) {
                              return ListTile(
                                //onTap: () {},
                                title: Text(
                                  "Nombre d'utilisateurs",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                subtitle: Text('Indisponible'),
                              );
                            }),
                        //trailing: Icon(Icons.info),
                        Divider(),
                        StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('para')
                                .doc('para')
                                .snapshots(),
                            builder: (context, snapshot) {
                              return ListTile(
                                /*onTap: () {
                                  print(testa);
                                },*/
                                title: Text(
                                  "Version",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                subtitle: Text(
                                    //snapshot.data['flutterVersionName'] ??
                                    'Indisponible'),
                              );
                            }),
                        //trailing: Icon(Icons.info),
                        Divider(),
                        ListTile(
                          //onTap: () {},
                          title: Text(
                            "PARA",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          subtitle: Text(""),
                        ),
                        //trailing: Icon(Icons.info),
                        Divider(),
                        ListTile(
                          //onTap: () {},
                          title: Text(
                            "PARA",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          subtitle: Text(''),
                        ),
                        //trailing: Icon(Icons.info),
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
                      ],
                    ),
                  );
                }),
          );
        });
  }
}
