import 'package:Para/group_chats/create_group/add_members.dart';
import 'package:Para/group_chats/group_chat_room.dart';
import 'package:Para/group_chats/group_chat_screen.dart';
import 'package:Para/pages/feeds.dart';
import 'package:Para/screens/mainscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Para/components/chat_item.dart';
import 'package:Para/models/message.dart';
import 'package:Para/utils/firebase.dart';
import 'package:Para/view_models/user/user_view_model.dart';
import 'package:Para/widgets/indicators.dart';

class Chats extends StatefulWidget {
  const Chats({Key key}) : super(key: key);

  @override
  _ChatsState createState() => _ChatsState();

  @override
  Widget build(BuildContext context) {}
}

class _ChatsState extends State<Chats> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  List groupList = [];

  @override
  void initState() {
    super.initState();
    getAvailableGroups();
  }

  void getAvailableGroups() async {
    String uid = _auth.currentUser.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    UserViewModel viewModel =
        Provider.of<UserViewModel>(context, listen: false);
    viewModel.setUser();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            leading: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => TabScreen(),
                  ),
                );
              },
              child: Icon(Icons.keyboard_backspace),
            ),
            title: Text('Messages'),
            backgroundColor: Colors.black,
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.person)),
                Tab(icon: Icon(Icons.groups)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Container(
                color: Colors.black,
                child: StreamBuilder(
                  stream: userChatsStream('${viewModel.user?.uid ?? ""}'),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List chatList = snapshot.data.docs;
                      if (chatList.isNotEmpty) {
                        return ListView.separated(
                          itemCount: chatList.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot chatListSnapshot = chatList[index];
                            return StreamBuilder(
                              stream: messageListStream(chatListSnapshot.id),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  List messages = snapshot.data.docs;
                                  Message message = Message.fromJson(
                                    messages.first.data(),
                                  );
                                  List users = chatListSnapshot.get('users');
                                  // remove the current user's id from the Users
                                  // list so we can get the second user's id
                                  users.remove('${viewModel.user?.uid ?? ""}');
                                  String recipient = users[0];
                                  return ChatItem(
                                    userId: recipient,
                                    messageCount: messages?.length,
                                    msg: message?.content,
                                    time: message?.time,
                                    chatId: chatListSnapshot.id,
                                    type: message?.type,
                                    currentUserId: viewModel.user?.uid ?? "",
                                  );
                                } else {
                                  return SizedBox();
                                }
                              },
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                height: 0.5,
                                width: MediaQuery.of(context).size.width / 1.3,
                                child: Divider(),
                              ),
                            );
                          },
                        );
                      } else {
                        return Center(child: Text('Aucune conversation'));
                      }
                    } else {
                      return Center(child: circularProgress(context));
                    }
                  },
                ),
              ),
              Scaffold(
                backgroundColor: Colors.black,
                body: isLoading
                    ? Container(
                        height: size.height,
                        width: size.width,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemCount: groupList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GroupChatRoom(
                                  groupName: groupList[index]['name'],
                                  groupChatId: groupList[index]['id'],
                                ),
                              ),
                            ),
                            leading: Icon(Icons.group),
                            title: Text(groupList[index]['name']),
                          );
                        },
                      ),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.group_add_sharp,
                    color: Colors.black,
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddMembersInGroup(),
                    ),
                  ),
                  tooltip: "Créer groupe",
                ),
              ),
            ],
          )),
    );
  }

  Stream<QuerySnapshot> userChatsStream(String uid) {
    return chatRef
        .where('users', arrayContains: '$uid')
        .orderBy('lastTextTime', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> messageListStream(String documentId) {
    return chatRef
        .doc(documentId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }
}
