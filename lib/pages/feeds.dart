// ignore_for_file: missing_return

import 'package:Para/helper/helperductions.dart';
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

  @override
  void initState() {
    super.initState();
    getUserInfogetChats();

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

  getUserInfogetChats() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    DatabaseMethods().getUserChats(Constants.myName).then((snapshots) {
      setState(() {
        //print("Nous avons les données c’est le nom  ${Constants.myName}");
      });
    });
  }

  //final DateTime fourHoursFromNow = DateTime.now() + Duration(hours: 4);
  final DateTime fourHoursFromNow = DateTime.now();

  String greeting() {
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
              title: Text(Constants.myName == null
                      ? greeting()
                      : greeting() + ' ' + Constants.myName
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
}
