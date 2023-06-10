import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Services/global_variables.dart';

class Persistent
{
  static List<String> songCategoryList = [
    'Worship',
    'Glorify',
  ];

  void getMyData() async
  {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    var name = userDoc.get('name');
    var userImage = userDoc.get('userImage');
    var location = userDoc.get('location');
  }
}