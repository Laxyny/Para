import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Para/components/notification_stream_wrapper.dart';
import 'package:Para/models/notification.dart';
import 'package:Para/utils/firebase.dart';
import 'package:Para/widgets/notification_items.dart';

class Activities extends StatefulWidget {
  @override
  _ActivitiesState createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  currentUserId() {
    return firebaseAuth.currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Text('Notifications'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              onTap: () => deleteAllItems(),
              child: Text(
                'VIDER',
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: ListView(
          children: [
            getActivities(),
          ],
        ),
      ),
    );
  }

  getActivities() {
    return Container(
      color: Colors.black,
      child: ActivityStreamWrapper(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        stream: notificationRef
            .doc(currentUserId())
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (_, DocumentSnapshot snapshot) {
          ActivityModel activities = ActivityModel.fromJson(snapshot.data());
          return Container(
            color: Colors.black,
            child: ActivityItems(
              activity: activities,
            ),
          );
        },
      ),
    );
  }

  deleteAllItems() async {
//delete all notifications associated with the authenticated user
    QuerySnapshot notificationsSnap = await notificationRef
        .doc(firebaseAuth.currentUser.uid)
        .collection('notifications')
        .get();
    notificationsSnap.docs.forEach(
      (doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      },
    );
  }
}
