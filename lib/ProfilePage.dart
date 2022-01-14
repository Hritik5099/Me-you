
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:me_you/ai_color.dart';
import 'package:me_you/progressIndicator.dart';
import 'homePage.dart';

String imageId="";
String nameId="";
String bioId="";
String webId="";
String locationId="";
String mobileId="";
String ownerId="";
int _postCount=0;
int followersCount=0;
int followingCount=0;
bool searchedUser=true;

class Profile extends StatefulWidget {
  final String profileId;

  Profile({required this.profileId});


  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId=Id;
  int _index = 0;
  bool _isDeleted=false;
  bool _isloading=false;
  bool gridTaped=true;
  bool product=false;
  bool premium=false;
  bool podcast=false;
  bool slidView=false;
  bool _isFollowing=false;
  bool isPostLiked=false;
  bool isPostDisLiked=false;
  @override
  void initState() {
    print("profile Id:${widget.profileId}");
    getUser();
    FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.profileId)
          .collection('userPosts').get().then((value) {
            setState(() {
              _postCount=value.size;
            });
    }

        );
    bool uid= widget.profileId==Id;
    print(uid);
    if (_isDeleted){
      showDialog(
          context: context, builder: (context){
        return Dialog(
          insetAnimationDuration: Duration(seconds: 4),
          backgroundColor: AIColors.primaryColor2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 16,
          child: Text("Post deleted"),
        );
      });
    }
    getFollowers();
    getFollowing();
    checkFollowing();
    super.initState();
  }

  getFollowers()async{
    QuerySnapshot snapshot=await followersRef.doc(widget.profileId).collection("userFollowers").get();
      setState(() {
        followersCount=snapshot.docs.length;
        print(followersCount);
      });

  }

  getFollowing()async{
    QuerySnapshot snapshot=await followingRef.doc(widget.profileId).collection("userFollowing").get();
      setState(() {
        //bool v=value.exists;
        //print("Following:$");
        followingCount=snapshot.docs.length;
        print("Following:$followingCount");
      });

  }

  checkFollowing()async{
  DocumentSnapshot doc=await followersRef.doc(widget.profileId).collection("userFollowers").doc(Id).get();
    setState(() {
      _isFollowing=doc.exists;
      print("following exits:$_isFollowing");
    });

  }

  getUser() async{
    setState(() {
      _isloading=true;
      //print("size is :$size");
    });
    await  userRef.where("id" ,isEqualTo: widget.profileId).get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          imageId=doc["image"];
          nameId=doc["name"];
          bioId=doc["bio"];
          locationId=doc["userLocation"];
          webId=doc["website"];
          mobileId=doc["mobile number"];
          print(imageId);
          print(nameId);
        });
      });

    });
    setState(() {
      _isloading=false;
    });
  }


   profileScaffoldBody(){
    return Scaffold(
      resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text("Profile"),
            backgroundColor: AIColors.primaryColor2,
            // actions: [
            //   IconButton(
            //     onPressed: (){
            //       Navigator.push(context,MaterialPageRoute(builder: (context)=>Followers()));
            //     },
            //     icon: Icon(Icons.follow_the_signs),color:Colors.white,),
            // ],
          ),
          body: profileContainerBody(),
        );
  }

  handelUnFollowers(){
    setState(() {
      _isFollowing=false;
    });
    followersRef.doc(widget.profileId).collection("userFollowers").doc(Id).get().then((doc) {
      if(doc.exists){
        doc.reference.delete();
      }
    });
    followingRef.doc(Id).collection("userFollowing").doc(widget.profileId).get().then((doc) {
      if(doc.exists){
        doc.reference.delete();
      }
    });
  }

  handleFollowers(){
    setState(() {
      _isFollowing=true;
    });
    followersRef.doc(widget.profileId).collection("userFollowers").doc(Id).set({});
    followingRef.doc(Id).collection("userFollowing").doc(widget.profileId).set({});
  }

   profileContainerBody(){
    return
        Container(
          //width: MediaQuery.of(context).size.width*0.1,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01,),
              Row(
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width*0.04,),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: MediaQuery.of(context).size.width*0.14,
                          backgroundImage: CachedNetworkImageProvider("$imageId"),
                        ),
                        Text("Name:- $nameId",),
                        Text("Bio:- $bioId",),
                        //Text("Web Site:- $webId"),
                        Text("From:- $locationId"),
                      ],
                    ),
                   Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                               Text("$_postCount"),
                                Text("No. of Post"),
                              ],
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width*0.04,),
                            Column(
                              children: [
                                Text("$followingCount"),
                                Text("Following"),
                              ],
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width*0.04,),
                            Column(
                              children: [
                                Text("$followersCount"),
                                Text("Followers"),
                              ],
                            ),
                          ],
                        ),
                        if (widget.profileId!=Id)
                          SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                        if (widget.profileId!=Id)
                          Container(
                            height: MediaQuery.of(context).size.height*0.04,
                            width: MediaQuery.of(context).size.width*0.4,
                            child: Material(
                              borderRadius: BorderRadius.circular(10.0),
                              //shadowColor: _isFollowing?Colors.grey:AIColors.primaryColor2,
                              color: _isFollowing?Colors.grey:AIColors.primaryColor2,
                              elevation: 7.0,
                              child: InkWell(
                                onTap: _isFollowing?handelUnFollowers:handleFollowers,
                                child: Center(
                                  child: Text(_isFollowing?"UnFollow":"Follow",style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01,),
              Divider(
                height: 20,
                thickness: 1,
              ),

              SizedBox(height: MediaQuery.of(context).size.height*0.01,),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        child: Column(
                          children: [
                            Icon(Icons.perm_media_rounded,color: gridTaped?AIColors.primaryColor2:Colors.grey,),
                            Text("Posts")
                          ],
                        ),
                        onTap: (){
                          print("grid taped");
                          //post();
                          setState(() {
                            gridTaped=true;
                            premium?premium=false:premium;
                            podcast?podcast=false:podcast;
                            product?product=false:product;
                          });},
                      ),
                      GestureDetector(
                        child: Column(
                          children: [
                            Icon(Icons.sell,color: product?AIColors.primaryColor2:Colors.grey,),
                            Text("Products"),
                          ],
                        ),
                        onTap: (){
                          setState(() {
                            product=true;
                            gridTaped?gridTaped=false:gridTaped;
                            premium?premium=false:premium;
                            podcast?podcast=false:podcast;
                          });
                        },
                      ),
                      GestureDetector(
                        child: Column(
                          children: [
                            Icon(Icons.monetization_on,color: premium?AIColors.primaryColor2:Colors.grey,),
                            Text("Premium"),
                          ],
                        ),
                        onTap: (){
                          setState(() {
                            premium=true;
                            gridTaped?gridTaped=false:gridTaped;
                            podcast?podcast=false:podcast;
                            product?product=false:product;
                          });
                        },
                      ),
                      GestureDetector(
                        child: Column(
                          children: [
                            Icon(Icons.podcasts,color: podcast?AIColors.primaryColor2:Colors.grey,),
                            Text("Podcast"),
                          ],
                        ),
                        onTap: (){
                          setState(() {
                            podcast=true;
                            product?product=false:product;
                            gridTaped?gridTaped=false:gridTaped;
                            premium?premium=false:premium;
                          });
                        },
                      ),
                    ]),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01,),
             if (gridTaped)
             Container(
                 height: MediaQuery.of(context).size.height*0.5,
               child: StreamBuilder<QuerySnapshot>(
               //future: userRef.where(id,isEqualTo:widget.profileId).get(),
               stream: FirebaseFirestore.instance
                   .collection('posts')
                   .doc(widget.profileId)
                   .collection('userPosts')
                   .orderBy("time",descending: true)
                   .snapshots(),
               builder: (context,snapshot){
               if(!snapshot.hasData){
               print("has data");
               return CircularProgress();
               }
               if (snapshot.hasData && snapshot.data !=null){
               print("has data");
               print(snapshot.data!.docs.length);
               return ListView.builder(
                   shrinkWrap: true,
                   itemBuilder: (listContext,index)=> buildItem(context,snapshot.data!.docs[index],"mediaUrl","posts","userPosts"),
                   itemCount: snapshot.data!.docs.length,
                   );
               }
               return SvgPicture.asset("assets/no_content.svg",height: 300,);
               },
               )
               ),


              if (product)
                Container(
                      height: MediaQuery.of(context).size.height*0.5,
                      child: StreamBuilder<QuerySnapshot>(
                        //future: userRef.where(id,isEqualTo:widget.profileId).get(),
                        stream: FirebaseFirestore.instance
                            .collection('product')
                            .doc(widget.profileId)
                            .collection('userProducts')
                            .orderBy("time",descending: true)
                            .snapshots(),
                        builder: (context,snapshot){
                          if(!snapshot.hasData){
                            print("has data");
                            return CircularProgress();
                          }
                          if (snapshot.hasData && snapshot.data !=null){
                            print("has data");
                            print(snapshot.data!.docs.length);
                            return ListView.builder(
                              shrinkWrap: true,
                              itemBuilder: (listContext,index)=> buildItem(context,snapshot.data!.docs[index],"productUrl","product","userProducts"),
                              itemCount: snapshot.data!.docs.length,
                            );
                          }
                          return SvgPicture.asset("assets/no_content.svg",height: 300,);
                        },
                      )
                  ),

              if (podcast)
              GestureDetector(
                onTap: (){},
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(8),
                        height: MediaQuery.of(context).size.height*0.4,
                      child: Card(
                        shadowColor: AIColors.primaryColor2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 8,
                        color: AIColors.primaryColor2,
                        child: Icon(Icons.add_box_sharp)
                      ),
                    ),
                  ),
                ),
              ),

              //SizedBox(height: MediaQuery.of(context).size.height*0.3,),
                    ],
                  ),
                );
          }


  buildItem(context,doc,String url,String collection,String subCollection) {
    return GestureDetector(
      //onDoubleTap: (){},
      onTap: (){},
      child:  Container(
          padding: EdgeInsets.all(8),
          height: MediaQuery.of(context).size.height*0.7,
          child:Card(shadowColor: AIColors.primaryColor2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height*0.1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                              CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(imageId),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width*0.03,),
                              Text(nameId,style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),),
                            ],),
                            if (widget.profileId==Id)
                            PopupMenuButton(itemBuilder: (context)=>[
                              PopupMenuItem(
                                child: Material(
                                  borderRadius: BorderRadius.circular(10.0),
                                  shadowColor: AIColors.primaryColor2,
                                  color: AIColors.primaryColor2,
                                  elevation: 7.0,
                                  child: InkWell(
                                    onTap: (){
                                      setState(() {
                                        _isDeleted=true;
                                      });
                                      FirebaseFirestore.instance
                                          .collection('$collection')
                                          .doc(widget.profileId)
                                          .collection('$subCollection')
                                          .doc(doc["postId"])
                                          .delete();
                                      Navigator.pop(context);
                                      initState();
                                      setState(() {
                                        _isDeleted=false;
                                      });
                                    },
                                    child: Center(
                                      child: Text("Delete",style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    ),
                                  ),
                                ),
                                value: 1,
                              ),
                            ])
                          ],
                        ),

                        
                        Text(locationId),
                        //Text(doc["Caption"].length > 15 ? doc["Caption"].substring(0, 15)+'...' : doc["Caption"],),
                        //Text(doc["time"]),
                      ],
                    ),
                  ),
                  Divider(height: 0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (product)
                      Row(
                        children: [
                          Text("Quantity:",style: TextStyle(color: AIColors.primaryColor2,fontSize: 20,fontWeight: FontWeight.bold),),
                          Text("${doc["quantity"]}",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold))
                        ],
                      ),
                      Text("${doc["Caption"]}".length>10?"${doc["Caption"]}".substring(0, 10)+"..more":"${doc["Caption"]}"),
                      if (product)
                        Row(
                          children: [
                            Text("Price:",style: TextStyle(color: AIColors.primaryColor2,fontSize: 20,fontWeight: FontWeight.bold),),
                            Text("${doc["price"]}",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold))
                          ],
                        ),
                    ],
                  ),
                  Divider(height: 0,),
                  //cachedNetworkImage("${doc["mediaUrl"]}"),
                  doc["$url"]==null?CircularProgressIndicator():Container(
                    height: MediaQuery.of(context).size.height*0.4,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: CachedNetworkImageProvider("${doc["$url"]}"),
                          fit: BoxFit.fitHeight,
                        ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                          onTap: () {
                            //if (doc["likes"])
                          FirebaseFirestore
                              .instance
                              .collection(collection)
                              .doc(widget.profileId)
                              .collection(subCollection).doc(doc["postId"])
                              .set({
                            'likes': {
                              "$Id": true,
                            }
                          },SetOptions(merge: true),);
                        FirebaseFirestore
                            .instance
                            .collection(collection)
                            .doc(widget.profileId)
                            .collection(subCollection).doc(doc["postId"])
                            .set({
                          'disLikes': {
                                "$Id": false,
                              }
                            },SetOptions(merge: true),);
                          },
                          child: Icon(doc["likes"][Id]!= null && doc["likes"][Id]?Icons.thumb_up:Icons.thumb_up_alt_outlined,color: AIColors.primaryColor2,)),
                      Text("0"),
                      GestureDetector(
                          onTap: (){
                            FirebaseFirestore
                                .instance
                                .collection(collection)
                                .doc(widget.profileId)
                                .collection(subCollection).doc(doc["postId"])
                                .set({
                              'disLikes': {
                                "$Id": true,
                              }
                            },
                              SetOptions(merge: true),
                            );
                            FirebaseFirestore
                                .instance
                                .collection(collection)
                                .doc(widget.profileId)
                                .collection(subCollection).doc(doc["postId"])
                                .set({
                                "likes": {
                              "$Id": false,
                            }
                          },
                              SetOptions(merge: true)
                            );
                          },
                          child: Icon(doc["disLikes"][Id]!= null &&doc["disLikes"][Id]?Icons.thumb_down:Icons.thumb_down_off_alt,color: AIColors.primaryColor2,)),
                      Text("0"),
                      GestureDetector(
                          onTap: (){},
                          child: Icon(Icons.comment,color: AIColors.primaryColor2,)),
                    ],
                  ),
                  if (product)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        onPressed: (){},
                        child: Text("Add to Cart",style: TextStyle(color: Colors.white),),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)
                        ),
                        color: AIColors.primaryColor2,),
                      RaisedButton(
                        onPressed: (){},
                        child: Text("Buy",style: TextStyle(color: Colors.white),),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                        ),
                        color: AIColors.primaryColor2,),
                    ],
                  )
                ],
              ),
            ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    return _isloading?CircularProgress():widget.profileId==Id?profileContainerBody():profileScaffoldBody();
  }
}
// TabBarView(
// controller: controller,
// children: <Widget>[
// Tabs("assets/u.jpg"),
// Tabs2("assets/c.jpg"),
// Tabs3("assets/s.jpg"),
// ],),

