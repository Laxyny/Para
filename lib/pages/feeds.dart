// ignore_for_file: missing_return

import 'dart:async';

import 'package:Para/helper/helperductions.dart';
import 'package:Para/models/user.dart';
import 'package:Para/services/database.dart';
import 'package:Para/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:Para/chats/recent_chats.dart';
import 'package:Para/models/post.dart';
import 'package:Para/utils/firebase.dart';
import 'package:Para/widgets/indicators.dart';
import 'package:Para/widgets/userpost.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time/time.dart';

import 'search.dart' as search;

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<DocumentSnapshot> post = [];

  bool isLoading = false;

  bool hasMore = true;

  int documentLimit = 10;

  DocumentSnapshot lastDocument;

  ScrollController _scrollController;
  User user;
  TextEditingController searchController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> users = [];
  List<DocumentSnapshot> filteredUsers = [];
  bool loading = true;

  getPosts() async {
    if (!hasMore) {
      print('Aucun nouveau post');
    }
    if (isLoading) {
      return CircularProgressIndicator();
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = await postRef
          .orderBy('timestamp', descending: true)
          .limit(documentLimit)
          .get();
    } else {
      querySnapshot = await postRef
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDocument)
          .limit(documentLimit)
          .get();
    }
    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }
    lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    post.addAll(querySnapshot.docs);
    setState(() {
      isLoading = false;
    });
  }

  String resultname = "";

  @override
  void initState() {
    super.initState();
    
    getPosts();
    _scrollController?.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxScroll - currentScroll <= delta) {
        getPosts();
      }
    });
  }

  //final DateTime fourHoursFromNow = DateTime.now() + Duration(hours: 4);
  final DateTime fourHoursFromNow = DateTime.now();

  String greeting() {
    //search.SearchState().printSample();
    search.SearchState().buildUsers2();
    var heure = DateTime.now().hour;
    if ((heure > 05) && (heure <= 12)) {
      return 'Bonne Matinée';
    }
    if ((heure > 12) && (heure <= 17)) {
      return 'Bon Après Midi';
    }
    if ((heure > 17) && (heure <= 22)) {
      return 'Bonne Soirée';
    } else
      return 'Bonne Nuit';
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: Colors.black,
            key: scaffoldKey,
            appBar: AppBar(
              backgroundColor: Colors.black,
              automaticallyImplyLeading: false,
              title: Text(
                greeting() + ' ' + resultname ?? 'Indisponible',
                //style: TextStyle(fontFamily: 'Algerian-Regular'),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: Icon(
                    CupertinoIcons.chat_bubble_2_fill,
                    size: 30.0,
                    color: Theme.of(context).accentColor,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => Chats(),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: feedBody(context),
          );
        });
  }

  Widget feedBody(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Container(
          child: Scaffold(
            backgroundColor: Colors.black,
            body: isLoading
                ? circularProgress(context)
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: post.length,
                    itemBuilder: (context, index) {
                      internetChecker(context);
                      PostModel posts = PostModel.fromJson(post[index].data());
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: UserPost(post: posts),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  internetChecker(context) async {
    bool result = await DataConnectionChecker().hasConnection;
    if (result == false) {
      showInSnackBar('Aucune connexion internet', context);
    }
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  /*currentUserId() {
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
    print('2222');
    ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (BuildContext context, int index) {
        DocumentSnapshot doc = filteredUsers[index];
        UserModel user = UserModel.fromJson(doc.data());
        if (doc.id == currentUserId()) {
          print('Laaaaaa');
          Timer(Duration(milliseconds: 500), () {
            setState(() {
              Constants.myName = user.username;
              //removeFromList(index);
            });
          });
        }
      },
    );
  }*/
}
