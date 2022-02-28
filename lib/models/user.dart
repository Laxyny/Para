import 'package:Para/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String currentUid() {
  return firebaseAuth.currentUser.uid;
}

final CollectionReference usercol =
    FirebaseFirestore.instance.collection("users");

Stream<UserModel> get getCurrentUser {
  final user = FirebaseAuth.instance.currentUser;
  return user != null
      ? usercol.doc(user.uid).snapshots().map((user) {
          UserModel.currentUser = UserModel.fromJson(user.data());
          return UserModel.fromJson(user.data());
        })
      : null;
}

Future getUser(String id) async {
  try {
    final data = await usercol.doc(id).get();
    final user = UserModel.fromJson(data.data());
    return user;
  } catch (e) {
    return false;
  }
}

class UserModel {
  static UserModel currentUser;

  String username;
  String email;
  String photoUrl;
  String country;
  String bio;
  String id;
  Timestamp signedUpAt;
  Timestamp lastSeen;
  bool isOnline;
  bool certif, admin, enable;

  UserModel({
    this.username,
    this.email,
    this.id,
    this.photoUrl,
    this.signedUpAt,
    this.isOnline,
    this.lastSeen,
    this.bio,
    this.country,
    this.certif = false,
    this.admin = false,
    this.enable = true,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
    country = json['country'];
    photoUrl = json['photoUrl'];
    signedUpAt = json['signedUpAt'];
    isOnline = json['isOnline'];
    lastSeen = json['lastSeen'];
    bio = json['bio'];
    id = json['id'];
    certif = json['certif'];
    admin = json['admin'];
    enable = json['enable'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['country'] = this.country;
    data['email'] = this.email;
    data['photoUrl'] = this.photoUrl;
    data['bio'] = this.bio;
    data['signedUpAt'] = this.signedUpAt;
    data['isOnline'] = this.isOnline;
    data['lastSeen'] = this.lastSeen;
    data['id'] = this.id;
    data['certif'] = this.certif;
    data['admin'] = this.admin;
    data['enable'] = this.enable;

    return data;
  }

  Map<String, dynamic> toMap() => {
        "username": username,
        "country": country,
        "email": email,
        "photoUrl": photoUrl,
        "bio": bio,
        "signedUpAt": signedUpAt,
        "isOnline": isOnline,
        "lastSeen": lastSeen,
        "id": id,
        "certif": certif,
        "admin": admin,
        "enable": enable,
      };
}
