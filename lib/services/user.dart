//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pam_app/services/auth.dart';

import '../constants/widgets.dart';

class UserService {
  Auth authService = Auth();
  /* User? user = FirebaseAuth.instance.currentUser;

  Future<void> updateFirebaseUser(
      BuildContext context, Map<String, dynamic> data) {
    User? user = FirebaseAuth.instance.currentUser;
    return authService.users.doc(user!.uid).update(data).then((value) {
      customSnackBar(context: context, content: 'Location updated on database');
    }).catchError((error) {
      customSnackBar(
          context: context,
          content: 'location cannot be updated in database due to $error');
    });
  }

  Future<DocumentSnapshot> getUserData() async {
    DocumentSnapshot doc = await authService.users.doc(user!.uid).get();
    return doc;
  }*/
}
