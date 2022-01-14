import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:me_you/ai_color.dart';
import 'package:me_you/progressIndicator.dart';

import 'ProfilePage.dart';

class NearYou extends StatefulWidget {
  const NearYou({Key? key}) : super(key: key);

  @override
  _NearYouState createState() => _NearYouState();
}

class _NearYouState extends State<NearYou> {
  String currentAddress="";
  bool isUploadingLocation=false;

  showAlertDialog(BuildContext context,String message) {
    Widget okButton = FlatButton(
        child: Text("Ok"),
        onPressed: () {
          Navigator.of(context).pop();
        }
    );
    AlertDialog alert = AlertDialog(
      title: Text("Hello"),
      content: Text(message),
      actions: [okButton],
    );
    showDialog(
        context: context,
        builder: (BuildContext context){
          return alert;
        });
  }

  getUserLocation() async{
    setState(() {
      isUploadingLocation=true;
    });
    try{
      Position position=await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,forceAndroidLocationManager: true);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,position.longitude
      );
      Placemark placemark =placemarks[0];
      setState(() {
        currentAddress="${placemark.locality}, ${placemark.postalCode}, ${placemark.country}";
      });
      String address="${placemark.locality}, ${placemark.postalCode}, ${placemark.country}";
      print(address);
      //locationController.text=address;
    }
    catch (e){
      showAlertDialog(context, "$e");
    }
    setState(() {
      isUploadingLocation=false;
    });
  }

  @override
  void initState() {
    getUserLocation();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [

          isUploadingLocation?CircularProgress():
          AppBar(
            backgroundColor: AIColors.primaryColor2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),),
            title: Row(
              children: [
                Icon(Icons.location_pin,color: Colors.orange,),
                Text(currentAddress),
              ],
            ),
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("users").where("userLocation",isEqualTo: currentAddress).snapshots(),
              builder: (context,snapshot){
                // if(!snapshot.hasData){
                //   return CircularProgress();
                // }
                if (snapshot.hasData && snapshot.data !=null){
                  print(snapshot.data!.docs.length);
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (listContext,index)=> buildItem(context,snapshot.data!.docs[index]),
                    itemCount: snapshot.data!.docs.length,
                  );
                }
                return Text("home");
              },
            ),),
        ],
      ),
    );
  }
}
buildItem(context,doc) {
  return GestureDetector(
    onTap: () {
      Navigator.push(context,MaterialPageRoute(builder: (context)=>Profile(profileId: doc["id"])));
    },
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