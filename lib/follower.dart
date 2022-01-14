import 'package:flutter/material.dart';
import 'package:me_you/ProfilePage.dart';

import 'ai_color.dart';


class Followers extends StatefulWidget {
  const Followers({Key? key}) : super(key: key);

  @override
  _FollowersState createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            AppBar(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),),
              backgroundColor: AIColors.primaryColor2,
              //leading: IconButton(
              //               icon: Icon(Icons.arrow_back,color: Colors.black,) ),
              title: Text("Followers List",
                style: TextStyle(
                    color: Colors.white
                ),),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.01,),
            Text("No. of Followers: $followersCount",style: TextStyle(fontSize: 20),),
            Divider(
              thickness: 2,
            ),
          ],
        ),
      )
    );
  }
}
