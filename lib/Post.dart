import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:me_you/homePage.dart';
import 'package:me_you/progressIndicator.dart';

class Post extends StatefulWidget {
  final String ownerId;
  Post({required this.ownerId});
  //final String postId;
  //   final String ownerId;
  //   final String name;
  //   final String userLocation;
  //   final String bio;
  //   final String image;
  //   int likeCount;
  //   Map likes;
  //
  //   Post({
  //     required this.postId,
  //     required this.ownerId,
  //     required this.name,
  //     required this.userLocation,
  //     required this.bio,
  //     required this.image,
  //     required this.likes,
  //     required this.likeCount,
  // })

  //factory Post.fromDoc(DocumentSnapshot doc){
    //return Post(
      //postId: doc["postId"],
      //ownerId: doc[""],
      //name: doc[""],
      //userLocation: doc[""],
      //bio: doc[""],
      //image: doc[""],
      //likes: doc[""],
    //);
  //}
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {


  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
          child:
          FutureBuilder<QuerySnapshot>(
            future: userRef.where(Id,isEqualTo:widget.ownerId).get(),
            builder: (context,snapshot){
              if(!snapshot.hasData){
                return CircularProgressIndicator();
              }
              if (snapshot.hasData && snapshot.data !=null){
                //return ListView.builder(
                //                   scrollDirection: Axis.vertical,
                //                   shrinkWrap: true,
                //                   itemBuilder: (listContext,index)=> buildItem(snapshot.data!.docs[index]),
                //                   itemCount: snapshot.data!.docs.length,
                //                 );
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (listContext,index)=> buildItem(snapshot.data!.docs[index]),
                  itemCount: snapshot.data!.docs.length,
                );
              }
              return SvgPicture.asset("assets/no_content.svg",height: 300,);
            },
          )
      ),
    );
  }
}

buildItem(doc) {
  final String userId;
  return GestureDetector(
    onTap: () {},
    child: Container(
      height: 70,
      child: Card(
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(doc["mediaUrl"]),
                ),
                SizedBox(width: 10,),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
