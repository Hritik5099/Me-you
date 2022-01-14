import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:me_you/progressIndicator.dart';

import 'ai_color.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool changeImage=false;
  File? _storedImage;
  var imageString="";
  String location="";
  bool isUploadingLocation=false;

  Future getimage() async {
    // get image from gallery.
    print("start");
    final ImagePicker picker=ImagePicker();
    final imagePicker=await picker.getImage(
        source: ImageSource.gallery,
    );
    print('mid');
    setState(() {
          _storedImage=File(imagePicker!.path) ;
    });
    print("end");
    _uploadimagetofirebase(File(imagePicker!.path));
  }

  Future<void> _uploadimagetofirebase(File image) async {
    try {
      // make random image name.
      int randomnumber = Random().nextInt(100000);
      String imagelocation = 'images/image${randomnumber}.jpg';

      // upload image to firebase.
      await FirebaseStorage.instance.ref().child(imagelocation).putFile(image);
      _addpathtodatabase(imagelocation);

    }catch(e){
      print(e);
    }

  }

  Future<void> _addpathtodatabase(String text) async {
    try {
      print(text);
      // get image url from firebase
      final ref = FirebaseStorage.instance.ref().child(text);
      setState(() async {
        imageString = await ref.getDownloadURL();
        location=text;
      });

      // add location and url to database
      //await FirebaseFirestore.instance.collection('storage').doc().set({'url':imagestring , 'location':text});
    }catch(e){
      print(e);
          }
    print(imageString);
    }

  getData(String name)async{
    print("get");
    return await FirebaseFirestore.instance.collection("users").where("name",isEqualTo: name).get();
  }


  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _webSiteController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();


  Future<void> _save(String name,String website,String bio,String mobile,String url,String location,String userLocation) async {
    CollectionReference users= FirebaseFirestore.instance.collection("users");
    String uid=FirebaseAuth.instance.currentUser!.uid.toString();
    users.doc(uid).set(
        {"name": name,
          "website": website,
          "bio": bio,
          "email":FirebaseAuth.instance.currentUser!.email,
          "mobile number":mobile,
          "image":url,
          "location":location,
          "id":uid,
          "userLocation":userLocation,
        }
    );
    return showAlertDialog(context,"Your data has been saved successfully");
  }
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
    try {
      Position position=await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,forceAndroidLocationManager: true);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,position.longitude
      );
      Placemark placemark =placemarks[0];
      String address="${placemark.locality}, ${placemark.postalCode}, ${placemark.country}";
      print(address);
      _locationController.text=address;
      print(_locationController.text);
    }
    catch (e){
      showAlertDialog(context, "$e");
    }
    setState(() {
      isUploadingLocation=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AIColors.primaryColor1,AIColors.primaryColor2],
          )
        ),
          child:  Container(
              child: SingleChildScrollView(
                child: Column(
                    children: [
                      AppBar(
                        backgroundColor: Colors.transparent,
                        title: Container(
                          height: MediaQuery.of(context).size.height*0.03,
                          child: Text('Account Info'),
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).size.height*0.01,),

                      Row(
                        children: [
                          SizedBox(width: MediaQuery.of(context).size.width*0.3,),
                          CircleAvatar(
                            radius: 50,
                            //backgroundImage: _storedImage!=null?Image.file(_storedImage!):Image.asset("assets/account.png"),
                            child:  _storedImage!=null?ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.file(
                                _storedImage!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.fitHeight,
                              ),
                            ):ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                "assets/account.png",
                                width: 100,
                                height: 100,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                            backgroundColor: AIColors.primaryColor2,
                          ),

                          Column(
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height*0.1,),
                              InkWell(
                                onTap: getimage,
                                child: Row(
                                  children: [
                                    Icon(Icons.image,size: 15,),
                                    SizedBox(width: MediaQuery.of(context).size.width*0.01,),
                                    Text(
                                      "Change Image",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        decoration:TextDecoration.underline
                                      ),
                                    )
                                  ],
                                ),
                              )


                            ]
                          )
                        ],
                      ),

                      SizedBox(height: MediaQuery.of(context).size.height*0.03,),

                      Container(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                              icon: Icon(Icons.edit),
                              labelText: "Name",
                              labelStyle: TextStyle(fontWeight:FontWeight.bold),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)
                              )
                          ),
                          cursorColor: Colors.black,
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).size.height*0.01,),

                      Container(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          controller: _webSiteController,
                          decoration: InputDecoration(
                              icon: Icon(Icons.link_sharp),
                              labelText: "Website",
                              labelStyle: TextStyle(fontWeight:FontWeight.bold),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)
                              )
                          ),
                          cursorColor: Colors.black,
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).size.height*0.01,),

                      Container(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          controller: _bioController,
                          decoration: InputDecoration(
                              icon: Icon(Icons.account_box_outlined),
                              labelText: "Bio",
                              labelStyle: TextStyle(fontWeight:FontWeight.bold),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)
                              )
                          ),
                          cursorColor: Colors.black,
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).size.height*0.01,),

                      Container(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                              icon: Icon(Icons.location_pin),
                              labelText: "Location",
                              labelStyle: TextStyle(fontWeight:FontWeight.bold),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)
                              ),
                            suffixIcon: GestureDetector(
                              child: Icon(Icons.my_location,color: Colors.orange,),
                              onTap: isUploadingLocation ? null: ()=>getUserLocation(),
                            )
                          ),
                          cursorColor: Colors.black,
                        ),
                      ),
                      isUploadingLocation? CircularProgress():Text(""),

                      SizedBox(height: MediaQuery.of(context).size.height*0.01,),

                      Container(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          initialValue: FirebaseAuth.instance.currentUser!.email,
                          decoration: InputDecoration(
                              icon: Icon(Icons.email),
                              labelText: "Email",
                              labelStyle: TextStyle(fontWeight:FontWeight.bold),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)
                              )
                          ),
                          cursorColor: Colors.black,
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).size.height*0.01,),

                      Container(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          controller: _mobileController,
                          decoration: InputDecoration(
                              icon: Icon(Icons.mobile_friendly),
                              labelText: "Mobil Number",
                              labelStyle: TextStyle(fontWeight:FontWeight.bold),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)
                              )
                          ),
                          cursorColor: Colors.black,
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).size.height*0.1,),

                      RaisedButton(
                          onPressed: (){
                            (_nameController.text==""||_webSiteController.text==""||_bioController.text==""||_mobileController.text=="")?
                            showAlertDialog(context,"Please fill all the entries")
                            :_save(
                                _nameController.text,
                                _webSiteController.text,
                                _bioController.text,
                                _mobileController.text,
                                imageString,
                                location,
                              _locationController.text,
                            );
                          },
                          child:Text("Submit"),
                          color: AIColors.primaryColor2,
                      ),
                    ],
                  ),
              ),
            ),
          ),
          );
  }}
