import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:me_you/ProfilePage.dart';
import 'package:me_you/database.dart';
import 'package:flutter_svg/svg.dart';
import 'package:me_you/progressIndicator.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'ai_color.dart';
import 'homePage.dart';



class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController =TextEditingController();

  QuerySnapshot? searchSnapshoot;

  DatabaseMethods databaseMethods=new DatabaseMethods();




  makeSearch() {
    userRef.where("name",isGreaterThanOrEqualTo:_searchController.text.trim()).get().then((value){
    setState(() {
      searchSnapshoot=value;
    });
  });
  }


  Container noUser(){
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            SvgPicture.asset("assets/search.svg",height: MediaQuery.of(context).size.height*0.7,),
          ],
        ),
      )
    );
  }


  Widget searchList(){
    return searchSnapshoot!=null ?ListView.builder(
        itemCount: searchSnapshoot!.docs.length,
        shrinkWrap: true,
        itemBuilder: (context,index){
          return _searchController.text.trim()!=""?SearchTile(
              image: searchSnapshoot!.docs[index]["image"],
              name:searchSnapshoot!.docs[index]["name"],
              email:searchSnapshoot!.docs[index]["email"],
              userId: searchSnapshoot!.docs[index]["id"],
          ):noUser();
        }): noUser();
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),),
            title: Container(
              height: MediaQuery.of(context).size.height*0.03,
              child: TextFormField(
                cursorColor: Colors.white,
                controller: _searchController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  // suffixIcon: GestureDetector(
                  //   onTap: ()=>_searchController.clear(),
                  //   child: Icon(Icons.clear_rounded,color: Colors.white,),
                  // ),
                  fillColor: Colors.white,
                  hintText: "  Search..",
                  hintStyle: TextStyle(
                    color: Colors.white
                  ),
                  focusColor: Colors.white,
                ),
                onFieldSubmitted: makeSearch(),
              ),
            ),
            backgroundColor: AIColors.primaryColor2,
            elevation: 0.0,
            actions: [
              // IconButton(
              //   onPressed: (){
              //     makeSearch();
              //   },
              //   icon: Icon(Icons.search_rounded),color:Colors.white,
              //   iconSize: 30,
              // ),
              IconButton(
                onPressed: ()=>_searchController.clear(),
                icon: Icon(Icons.clear),color:Colors.white,
                iconSize: 30,
              ),
            ],
          ),
          searchList(),
        ],
      ),);
  }
}
class SearchTile extends StatelessWidget {
  final String name;
  final String email;
  final String image;
  final String userId;
  SearchTile({required this.name, required this.email,required this.image,required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: (){
              Navigator.push(context,MaterialPageRoute(builder: (context)=>Profile(profileId: userId)));
              FocusScope.of(context).unfocus();
            },
            child:ListTile(
                leading:CircleAvatar(
                  //child:image!=null?CachedNetworkImageProvider(image):Text('no image'),
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(image,),
                ),
              title: Text(name,style:TextStyle(
                color: Colors.black,fontWeight: FontWeight.bold,
              ),
              ),
              subtitle: Text(email,style:TextStyle(
                color: Colors.black,fontWeight: FontWeight.bold,
              ),),
              ),
            ),
          Divider(height: 2.0,color: Colors.black,),
        ],
      ),
      );
  }
}
