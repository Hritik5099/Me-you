import 'package:flutter/material.dart';
import 'package:me_you/ai_color.dart';

class Podcast extends StatefulWidget {
  const Podcast({Key? key}) : super(key: key);

  @override
  _PodcastState createState() => _PodcastState();
}

class _PodcastState extends State<Podcast> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AIColors.primaryColor2,
        actions: [
          FlatButton(onPressed: (){}, child: Text("Upload",style: TextStyle(fontSize: 20,color: Colors.white),))
        ],
        //leading: Icon(Icons.arrow_back_outlined,color: Colors.black,),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                //image:AssetImage("assets/podcast.png")
              ),
              child: Image.asset("assets/podcast.png"),
              height: 500,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Material(
                  borderRadius: BorderRadius.circular(10.0),
                  shadowColor: Colors.greenAccent,
                  color: Colors.green,
                  elevation: 7.0,
                  child: InkWell(
                    onTap: (){},
                    child: Center(
                      child: Icon(Icons.mic,size: 40,),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
