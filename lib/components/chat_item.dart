import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Para/chats/conversation.dart';
import 'package:Para/components/text_time.dart';
import 'package:Para/models/enum/message_type.dart';
import 'package:Para/models/user.dart';
import 'package:Para/utils/firebase.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatItem extends StatelessWidget {
  final String userId;
  final Timestamp time;
  final String msg;
  final int messageCount;
  final String chatId;
  final MessageType type;
  final String currentUserId;

  ChatItem({
    Key key,
    @required this.userId,
    @required this.time,
    @required this.msg,
    @required this.messageCount,
    @required this.chatId,
    @required this.type,
    @required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: usersRef.doc('$userId').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot documentSnapshot = snapshot.data;
          UserModel user = UserModel.fromJson(documentSnapshot.data());

          return ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            leading: Stack(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    '${user?.photoUrl}',
                  ),
                  radius: 25.0,
                ),
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    height: 15,
                    width: 15,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: user?.isOnline ?? false
                              ? Color(0xff00d72f)
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        height: 11,
                        width: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              '${user.username}',
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              type == MessageType.IMAGE ? "IMAGE" : "$msg",
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SizedBox(height: 10),
                TextTime(
                  child: Text(
                    "${timeago.format(time.toDate())}",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 11,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                //buildCounter(context),
              ],
            ),
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute(
                  builder: (BuildContext context) {
                    return Conversation(
                      userId: userId,
                      chatId: chatId,
                    );
                  },
                ),
              );
            },
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  Stream<DocumentSnapshot> messageBodyStream() {
    return chatRef.doc(chatId).snapshots();
  }
}
