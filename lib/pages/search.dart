import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:Para/chats/conversation.dart';
import 'package:Para/models/user.dart';
import 'package:Para/pages/profile.dart';
import 'package:Para/utils/firebase.dart';
import 'package:Para/widgets/indicators.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  User user;
  TextEditingController searchController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> users = [];
  List<DocumentSnapshot> filteredUsers = [];
  bool loading = true;

  currentUserId() {
    return firebaseAuth.currentUser.uid;
  }

  getUsers() async {
    QuerySnapshot snap = await usersRef.get();
    List<DocumentSnapshot> doc = snap.docs;
    users = doc;
    filteredUsers = doc;
    setState(() {
      loading = false;
    });
  }

  search(String query) {
    if (query == "") {
      filteredUsers = users;
    } else {
      List userSearch = users.where((userSnap) {
        Map user = userSnap.data();
        String userName = user['username'];
        return userName.toLowerCase().contains(query.toLowerCase());
      }).toList();

      setState(() {
        filteredUsers = userSearch;
      });
    }
  }

  removeFromList(index) {
    filteredUsers.removeAt(index);
  }

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: buildSearch(),
      ),
      body: buildUsers(),
    );
  }

  buildSearch() {
    return Row(
      children: [
        Container(
          height: 35.0,
          width: MediaQuery.of(context).size.width - 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Center(
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                controller: searchController,
                textAlignVertical: TextAlignVertical.center,
                maxLength: 10,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                ],
                textCapitalization: TextCapitalization.sentences,
                onChanged: (query) {
                  search(query);
                },
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                    onTap: () {
                      searchController.clear();
                    },
                    child: Icon(Feather.x, size: 12.0, color: Colors.black),
                  ),
                  contentPadding: EdgeInsets.only(bottom: 10.0, left: 10.0),
                  border: InputBorder.none,
                  counterText: '',
                  hintText: 'Rechercher...',
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  buildUsers() {
    if (!loading) {
      if (filteredUsers.isEmpty) {
        return Center(
          child: Text("Aucun utilisateur trouvé",
              style: TextStyle(fontWeight: FontWeight.bold)),
        );
      } else {
        return Container(
          color: Colors.black,
          child: ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot doc = filteredUsers[index];
              UserModel user = UserModel.fromJson(doc.data());
              if (doc.id == currentUserId()) {
                Timer(Duration(milliseconds: 500), () {
                  setState(() {
                    //removeFromList(index);
                  });
                });
              }
              return Container(
                color: Colors.black,
                child: Column(
                  children: [
                    ListTile(
                      onTap: () => showProfile(context, profileId: user?.id),
                      contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                      leading: CircleAvatar(
                        radius: 35.0,
                        backgroundImage: (user?.photoUrl == null)
                            ? AssetImage('assets/images/ParaIcon.png')
                            : NetworkImage(user?.photoUrl),
                      ),
                      title: (user?.username == null)
                          ? Text('')
                          : Text(user?.username,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                      //subtitle: Text(
                      //user?.email,
                      //),
                      trailing: (doc.id == currentUserId())
                          ? Text('')
                          : GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => Conversation(
                                      userId: doc.id,
                                      chatId: 'newChat',
                                    ),
                                  ),
                                );
                              },
                              child: (doc.id == currentUserId())
                                  ? Text('')
                                  : Container(
                                      height: 30.0,
                                      width: 62.0,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).accentColor,
                                        borderRadius:
                                            BorderRadius.circular(3.0),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            'Message',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )),
                    ),
                    Divider(),
                  ],
                ),
              );
            },
          ),
        );
      }
    } else {
      return Center(
        child: circularProgress(context),
      );
    }
  }

  showProfile(BuildContext context, {String profileId}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => Profile(profileId: profileId),
      ),
    );
  }
}
