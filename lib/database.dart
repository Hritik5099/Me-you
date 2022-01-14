import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods{
  getUserByName(String name)async{
    print("get");
    return await FirebaseFirestore.instance.collection("users").where("name",isEqualTo: name).get();
  }
}