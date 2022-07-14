import 'dart:developer';
import 'dart:io';

import 'package:Para/models/user.dart';
import 'package:Para/screens/view_image.dart';
import 'package:Para/utils/constants.dart';
import 'package:Para/utils/firebase.dart';
import 'package:Para/widgets/indicators.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Para/group_chats/group_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'group_info.dart';

class GroupChatRoom extends StatelessWidget {
  final String groupChatId, groupName;
  String username;

  GroupChatRoom({this.groupName, this.groupChatId, Key key}) : super(key: key);

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('users');

  get nomUtilisateur => _firestore
          .collection('users')
          .doc(_auth.currentUser.uid)
          .get()
          .then((value) {
        username = value['username'];
      });

  final TextEditingController messageController = TextEditingController();
  FocusNode focusNode = FocusNode();
  ScrollController scrollController = ScrollController();

  void onSendMessage() async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": Constants.myName,
        "message": messageController.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      messageController.clear();

      scroll() {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      }

      await _firestore
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .add(chatData);
    }

    messageController.addListener(() {
      if (focusNode.hasFocus && messageController.text.isNotEmpty) {
        //setTyping(true);
        print('message');
      } else if (!focusNode.hasFocus ||
          (focusNode.hasFocus && messageController.text.isEmpty)) {
        //setTyping(false);
        print('null');
      }
    });
  }

  File imageFile;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    String fileName = Uuid().v1();
    int status = 1;

    await _firestore
        .collection('groups')
        .doc(groupChatId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": Constants.myName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile).catchError((error) async {
      await _firestore
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextButton(
          child: Text(
            groupName,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GroupInfo(
                groupName: groupName,
                groupId: groupChatId,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GroupInfo(
                        groupName: groupName,
                        groupId: groupChatId,
                      ),
                    ),
                  ),
              icon: Icon(Icons.more_vert)),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                color: Colors.black,
                //height: size.height / 1.27,
                width: size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('groups')
                      .doc(groupChatId)
                      .collection('chats')
                      .orderBy('time')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      //List messages = snapshot.data.docs;
                      //viewModel.setReadCount(
                      //    widget.chatId, user, messages.length);
                      return ListView.builder(
                        controller: scrollController,
                        reverse: false,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> chatMap =
                              snapshot.data.docs[index].data()
                                  as Map<String, dynamic>;
                          return messageTile(size, chatMap);
                        },
                      );
                    } else {
                      return Center(child: circularProgress(context));
                    }
                  },
                ),
              ),
            ),
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: BottomAppBar(
                color: Colors.black,
                elevation: 10.0,
                child: Container(
                  constraints: BoxConstraints(maxHeight: 100.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.photo_on_rectangle,
                          color: Theme.of(context).accentColor,
                        ),
                        onPressed: () {
                          getImage();
                        },
                      ),
                      Flexible(
                        child: TextField(
                          cursorColor: Colors.white,
                          controller: messageController,
                          focusNode: focusNode,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Theme.of(context).textTheme.headline6.color,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            enabledBorder: InputBorder.none,
                            border: InputBorder.none,
                            hintText: "Saisissez votre message",
                            hintStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.headline6.color,
                            ),
                          ),
                          maxLines: null,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Feather.send,
                          color: Theme.of(context).accentColor,
                        ),
                        onPressed: () {
                          scrollController.animateTo(
                              scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut);
                          onSendMessage();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          return Builder(builder: (_) {
            if (chatMap['type'] == "text") {
              scrollController.animateTo(
                  scrollController?.position?.maxScrollExtent,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut); // A Changer
              return Container(
                width: size.width,
                alignment: chatMap['sendBy'] == Constants.myName
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: chatMap['sendBy'] == Constants.myName
                          ? BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20))
                          : BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20)),
                      gradient: LinearGradient(
                        colors: chatMap['sendBy'] == Constants.myName
                            ? [Constants.colorUserMe, Constants.colorUserMe]
                            : [
                                Constants.colorUserOther,
                                Constants.colorUserOther
                              ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          /*chatMap['sendBy'] == currentUserId()
                              ? Constants.myName
                              : 'Inconnu',*/
                          //'test',
                          chatMap['sendBy'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: size.height / 200,
                        ),
                        Text(
                          chatMap['message'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )),
              );
            } else if (chatMap['type'] == "img") {
              scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut);
              return Container(
                width: size.width,
                alignment: chatMap['sendBy'] == Constants.myName
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  height: size.height / 2,
                  child: Image.network(
                    chatMap['message'],
                  ),
                ),
              );
            } else if (chatMap['type'] == "notify") {
              scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut);
              return Container(
                width: size.width,
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.black38,
                  ),
                  child: Text(
                    chatMap['message'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            } else {
              return SizedBox();
            }
          });
        });
  }
}
