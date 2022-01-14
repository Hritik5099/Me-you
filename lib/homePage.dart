import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:me_you/NearYou.dart';
import 'package:me_you/ProfilePage.dart';
import 'package:me_you/ChatPage.dart';
import 'package:me_you/Home.dart';
import 'package:me_you/SearchPage.dart';
import 'package:me_you/ai_color.dart';
import 'package:me_you/AccountPage.dart';
import 'package:me_you/follower.dart';
import 'package:me_you/progressIndicator.dart';
import 'package:me_you/database.dart';
import 'package:me_you/upload.dart';


final CollectionReference userRef=FirebaseFirestore.instance.collection("users");
final postRef=FirebaseFirestore.instance.collection("posts");
final productRef=FirebaseFirestore.instance.collection("product");
final followingRef=FirebaseFirestore.instance.collection("following");
final followersRef=FirebaseFirestore.instance.collection("followers");
final storageReference=FirebaseStorage.instance.ref();
String Id="";


class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.onSignOut,required this.Id}) : super(key: key);
  final VoidCallback onSignOut;
  String Id;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  //final TextEditingController _searchController =TextEditingController();

  int _selectedIndex=0;
  late TabController controller;
  bool post=true;
  bool productPost=false;
  bool premiumPost=false;
  bool podcastPost=false;
  User? user;
  List<dynamic> users=[];
  QuerySnapshot? searchSnapshoot;
  bool doExist=true;



  //DatabaseMethods databaseMethods=new DatabaseMethods();

  showAlertDialog(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>AccountPage(),));
      },
    );


    AlertDialog alert = AlertDialog(
      title: Text("Alert"),
      content: Text("You need to fill your account details first"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });}

  final FirebaseAuth auth = FirebaseAuth.instance;
  //final User? user = auth.currentUser;

  @override

  void initState() {
    setState(() {
      Id=widget.Id;
    });
    print("widget id:${widget.Id}");
    print("uid:$Id");
    Home();
    makeSearch();
    super.initState();
    controller = new TabController(length: 3, vsync: this,initialIndex: 0);
    //tabController=new TabController(length: 4, vsync: this,initialIndex:0);
  }
  final _auth = FirebaseAuth.instance;

  Future signOut()async{
    try{
      await _auth.signOut();
      widget.onSignOut();
    }
    catch(e) {
      return null;
    }
  }

  void _onItemTap(int index){
    setState(() {
      _selectedIndex=index;
    });
  }

  // void _onIndexTap(int i){
  //   setState(() {
  //     index=i;
  //   });
  // }


  String usersImage="";




  makeSearch() async{
    final QuerySnapshot snapshot_1=await userRef.where("email",isEqualTo: FirebaseAuth.instance.currentUser!.email).get();
    snapshot_1.docs.forEach((DocumentSnapshot doc) {
      setState(() {
        doExist=doc.exists;
        //print("Do user exits:$doExist");
        if (!doExist) {
          showAlertDialog(context);
        }
      });
    });

    //await  userRef.get().then((QuerySnapshot querySnapshot) {
    //       querySnapshot.docs.forEach((doc) {
    //         setState(() {
    //           imageToken=doc["image"];
    //           print("link is:$imageToken");
    //         });
    //       });
    //
    //     });
    //setState(() {
    //       users=snapshot.docs;
    //       usersImage=users.map((user) => user["image"]).toString();
    //       String imageUrl=usersImage;
    //       imageToken = imageUrl.substring(1, imageUrl.length -1);
    //       print("link:$imageToken");
    //     });
  }



  static List<Widget> _widgetOptions = <Widget>[
    Home(),
    //Text('home page'),
    NearYou(),
    SearchPage(),
    Uplaod(),
    Profile(profileId: Id,),
    //Text("profile page"),
  ];

  Widget get bottomNavigationBar {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(30), topLeft: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
        ],
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          topLeft: Radius.circular(25),
      ),
      child: BottomNavigationBar(
      items: [
          BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text("home"),
          backgroundColor:AIColors.primaryColor2,
          ),

          BottomNavigationBarItem(
          icon: Icon(Icons.location_pin),
          title: Text("Near You"),
          backgroundColor:AIColors.primaryColor2,
          ),

          BottomNavigationBarItem(
          icon: Icon(Icons.search_rounded),
          title: Text("Near You"),
          backgroundColor:AIColors.primaryColor2,
          ),

          BottomNavigationBarItem(
          icon: Icon(Icons.add_box),
          title: Text("Upload"),
          backgroundColor:AIColors.primaryColor2,
          ),

          BottomNavigationBarItem(
          icon: Icon(Icons.account_box_outlined),
          title: Text("About You"),
          backgroundColor:AIColors.primaryColor2,
          ),
      ],
      type: BottomNavigationBarType.shifting,
      selectedItemColor: Colors.black,
      currentIndex: _selectedIndex,
      onTap: _onItemTap,
      )),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.red,
      //resizeToAvoidBottomInset: false,
      appBar: _selectedIndex==0||_selectedIndex==4?AppBar(
      //iconTheme: IconThemeData(color: Colors.black),
      title: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height*0.03,
            child: Text(_selectedIndex==0?"Me & You":"Profile",style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                //fontSize: 25,
                color: Colors.white
            ),),
          ),

        ],
      ),
      backgroundColor: AIColors.primaryColor2,
      elevation: 0.0,
      actions: [
        IconButton(
          onPressed: (){
            Navigator.push(context,MaterialPageRoute(builder: (context)=>Followers()));
          },
          icon: Icon(Icons.follow_the_signs),color:Colors.white,),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),),
    ):null,
      bottomNavigationBar: bottomNavigationBar,
      drawer: ClipRRect(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(50), bottomRight: Radius.circular(50)),
        child: Drawer(
          elevation: 0.0,
          child:  ListView(
              shrinkWrap: true,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AIColors.primaryColor1,AIColors.primaryColor2]
                    )
            ),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider("$imageToken"),
                            radius: MediaQuery.of(context).size.width*0.15,
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width*0.04,),
                          Container(
                            height: MediaQuery.of(context).size.height*0.1,
                            width: MediaQuery.of(context).size.width*0.4,
                            child: Column(
                              children: [
                                Text("Welcome,",style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width*0.07,
                                ),),
                                Text("$nameToken",style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width*0.05,
                                ),),
                              ],
                            ),
                          ),
                        ],
                      ),
                ),

                ListTile(
                  leading: Icon(Icons.edit,size: 25,),
                  title: Text('Edit Account',style:TextStyle(
                    fontSize: 20,
                  )),
                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AccountPage()));
                  },
                ),

                ListTile(
                  leading: Icon(Icons.add_shopping_cart,size: 25,),
                  title: Text('Orders Placed',style:TextStyle(
                    fontSize: 20,
                  )),
                  onTap: (){},
                ),

                ListTile(
                  leading: Icon(Icons.delivery_dining,size: 25,),
                  title: Text('Orders You Got',style:TextStyle(
                    fontSize: 20,
                  )),
                  onTap: (){},
                ),

                ListTile(
                  leading: Icon(Icons.settings,size: 25,),
                  title: Text('Setting',style:TextStyle(
                    fontSize: 20,
                  )),
                  onTap: (){},
                ),

                ListTile(
                  leading: Icon(Icons.arrow_back,size: 25,),
                  title: Text('Log Out',style:TextStyle(
                    fontSize: 20,
                  )),
                  onTap: (){
                    signOut();
                  },
                ),
              ],
            ),
        ),
      ),
        body: Container(
            child: Column(
                  children: [
                        if (_selectedIndex==0)
                        SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                        if (_selectedIndex==0)
                          Container(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    child: Column(
                                      children: [
                                        Icon(Icons.perm_media_rounded,color: post?AIColors.primaryColor2:Colors.grey,),
                                        Text("Posts")
                                      ],
                                    ),
                                    onTap: (){
                                      print("grid taped");
                                      //post();
                                      setState(() {
                                        post=true;
                                        premiumPost?premiumPost=false:premiumPost;
                                        podcastPost?podcastPost=false:podcastPost;
                                        productPost?productPost=false:productPost;
                                      });
                                      },
                                  ),
                                  GestureDetector(
                                    child: Column(
                                      children: [
                                        Icon(Icons.sell,color: productPost?AIColors.primaryColor2:Colors.grey,),
                                        Text("Products"),
                                      ],
                                    ),
                                    onTap: (){
                                      setState(() {
                                        productPost=true;
                                        post?post=false:post;
                                        premiumPost?premiumPost=false:premiumPost;
                                        podcastPost?podcastPost=false:podcastPost;
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Column(
                                      children: [
                                        Icon(Icons.monetization_on,color: premiumPost?AIColors.primaryColor2:Colors.grey,),
                                        Text("Premium"),
                                      ],
                                    ),
                                    onTap: (){
                                      setState(() {
                                        premiumPost=true;
                                        post?post=false:post;
                                        podcastPost?podcastPost=false:podcastPost;
                                        productPost?productPost=false:productPost;
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Column(
                                      children: [
                                        Icon(Icons.podcasts,color: podcastPost?AIColors.primaryColor2:Colors.grey,),
                                        Text("Podcast"),
                                      ],
                                    ),
                                    onTap: (){
                                      setState(() {
                                        podcastPost=true;
                                        productPost?productPost=false:productPost;
                                        post?post=false:post;
                                        premiumPost?premiumPost=false:premiumPost;
                                      });
                                    },
                                  ),
                                ]),
                          ),
                        Center(
                          child: _widgetOptions.elementAt(_selectedIndex),
                        ),
                      ],
                    ),
            ),
          );
  }
}
