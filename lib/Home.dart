
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:me_you/progressIndicator.dart';

import 'ai_color.dart';
import 'homePage.dart';

String imageToken="";
String nameToken="";
String bioToken="";
String webToken="";
String locationToken="";
String mobileToken="";


//final userRef= FirebaseFirestore.instance.collection("users");

class Home extends StatefulWidget {
  //final String myid;
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState(){
    print("homepage:${Id}");
    getUserData();
    super.initState();
  }

  getUserData() async{
    await  userRef.where("id" ,isEqualTo: Id).get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          imageToken=doc["image"];
          nameToken=doc["name"];
          bioToken=doc["bio"];
          locationToken=doc["userLocation"];
          webToken=doc["website"];
          mobileToken=doc["mobile number"];
          print(imageToken);
          print(nameToken);
        });
      });

    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("users").snapshots(),
            builder: (context,snapshot){
              if(!snapshot.hasData){
                return CircularProgress();
              }
              if (snapshot.hasData && snapshot.data !=null){
                print(snapshot.data!.docs.length);
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (listContext,index)=> buildItem(snapshot.data!.docs[index]),
                  itemCount: snapshot.data!.docs.length,
                );
              }
              return Text("home");
            },
          ),),
      ],
    );
    //StreamBuilder<QuerySnapshot>(
        //         stream: userRef.snapshots(),
        //         builder: (context,snapshot){
        //           if(!snapshot.hasData){
        //             return CircularProgress();
        //           }
        //           final List<Text> children=snapshot.data!.docs.map((doc) => Text(doc["name"])).toList();
        //           return ListView(
        //               children:children,
        //             );
        //         },
        //       ));
  }
}
buildItem(doc) {
  return GestureDetector(
    onTap: () {},
    child: Container(
      height: 70,
      child: Card(
        color: Colors.white,
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(doc["image"]),
            ),
            SizedBox(width: 10,),
            Text(doc["name"]),
          ],
        ),
      ),
    ),
  );
}

