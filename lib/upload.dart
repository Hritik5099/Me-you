import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:me_you/Podcast.dart';
import 'package:me_you/ai_color.dart';
import 'package:me_you/progressIndicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'homePage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


class Uplaod extends StatefulWidget {
  const Uplaod({Key? key}) : super(key: key);

  @override
  _UplaodState createState() => _UplaodState();
}

class _UplaodState extends State<Uplaod> {
  File? file;
  bool isUploading =false;
  bool isUploadingLocation =false;
  String image="";
  String postId=Uuid().v4();
  String productId=Uuid().v4();
  bool _isPostType=false;

  final TextEditingController captionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  getUserCurrentState() async{
    await  userRef.where("id" ,isEqualTo: Id).get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          image=doc["image"];
          print(image);
        });
      });

    }
    );
  }


  @override

  void initState() {
    getUserCurrentState();
    print(Id);
    super.initState();
  }

  takePhoto()async{
    final ImagePicker picker=ImagePicker();
    final imagePicker=await picker.getImage(
      source: ImageSource.camera,
    );
    setState(() {
      file=File(imagePicker!.path);
    });
  }

  choosePhoto() async{
    final ImagePicker picker=ImagePicker();
    final imagePicker=await picker.getImage(
      source: ImageSource.gallery,
    );
    setState(() {
      file=File(imagePicker!.path);
    });
  }

   buildUploadScreen(){
    return Container(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.1,),
              SvgPicture.asset("assets/upload.svg",height: MediaQuery.of(context).size.height*0.3,),
              SizedBox(height: MediaQuery.of(context).size.height*0.1,),
              Center(child: Text("Upload with:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),),
              SizedBox(height: MediaQuery.of(context).size.height*0.02,),
              Container(
                height: MediaQuery.of(context).size.height*0.05,
                width: MediaQuery.of(context).size.width*0.3,
                child: Material(
                  shadowColor: AIColors.primaryColor2,
                  borderRadius: BorderRadius.circular(10.0),
                  elevation: 7.0,
                  child: InkWell(
                    onTap: takePhoto,
                    child:  Row(
                      children: [
                        Icon(Icons.camera),
                        SizedBox(width: MediaQuery.of(context).size.width*0.05,),
                        Text("Camera",style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                          ),),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.02,),
              Container(
                height: MediaQuery.of(context).size.height*0.05,
                width: MediaQuery.of(context).size.width*0.3,
                child: Material(
                  shadowColor: AIColors.primaryColor2,
                  borderRadius: BorderRadius.circular(10.0),
                  elevation: 7.0,
                  child: InkWell(
                    onTap: choosePhoto,
                    child:  Row(
                      children: [
                        Icon(Icons.image),
                        SizedBox(width: MediaQuery.of(context).size.width*0.05,),
                        Text("Gallery",style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                        ),),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.02,),
              Container(
                height: MediaQuery.of(context).size.height*0.05,
                width: MediaQuery.of(context).size.width*0.3,
                child: Material(
                  shadowColor: AIColors.primaryColor2,
                  borderRadius: BorderRadius.circular(10.0),
                  elevation: 7.0,
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>Podcast()));
                    },
                    child:  Row(
                      children: [
                        Icon(Icons.podcasts),
                        SizedBox(width: MediaQuery.of(context).size.width*0.05,),
                        Text("Podcast",style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                        ),),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.13,),
            ],
          ),
        );

  }
  clearimage(){
    setState(() {
      file =null;
    });
  }

   dialogBox(){
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(20.0)),
      child:Column(
        children: [
          Text("Normal Post"),
          Text("Sell the item"),
        ],
      ),
    );
  }

  compressImage() async{
    final temDir=await getTemporaryDirectory();
    final path=temDir.path;
    Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());
    final compressImageFile=File("$path/img_$postId.jpg")..writeAsBytesSync(Im.encodeJpg(imageFile!,quality:83));
    setState(() {
      file=compressImageFile;
    });
  }

  Future<String> uploadImage(imageFile)async{
     await storageReference.child("post_$postId.jpg").putFile(imageFile);
     final ref = FirebaseStorage.instance.ref().child("post_$postId.jpg");
     String downloadUrl= await ref.getDownloadURL();
     print(downloadUrl);
     return downloadUrl;
  }

  creatPostInFireStrore({required String mediaUrl,required String location,required String caption,}){
    print(Id);
    postRef
        .doc(Id)
        .collection("userPosts")
        .doc(postId)
        .set({
      "postId":postId,
      "ownerId":Id,
      "mediaUrl":mediaUrl,
      "Caption":caption,
      "location":location,
      "time":DateTime.now(),
      "likes":{},
      "disLikes":{},
    });
  }

  creatProductInFireStore({
    required String productUrl,
    required String location,
    required String caption,
    required String quantity,
    required String price}){
    productRef
        .doc(Id)
        .collection("userProducts")
        .doc(productId)
        .set({
      "postId":productId,
      "ownerId":Id,
      "productUrl":productUrl,
      "Caption":caption,
      "location":location,
      "price":"$price Rs.",
      "quantity":quantity,
      "time":DateTime.now(),
      "likes":{},
      "disLikes":{},
    });
  }

  handleProductSubmit()async{
    setState(() {
      isUploading=true;
    });
    await compressImage();
    String productUrl=await uploadImage(file);
    creatProductInFireStore(
      productUrl: productUrl,
      location: locationController.text.trim(),
      caption: captionController.text.trim(),
      quantity: quantityController.text.trim(),
      price: priceController.text.trim(),
    );
    captionController.clear();
    locationController.clear();
    quantityController.clear();
    priceController.clear();
    Navigator.pop(context);
    setState(() {
      file=null;
      isUploading=false;
      productId=Uuid().v4();
    });
  }

  handlePostSubmit()async{
    setState(() {
      isUploading=true;
    });
    await compressImage();
    String mediaUrl=await uploadImage(file);
    creatPostInFireStrore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      caption: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    Navigator.pop(context);
    setState(() {
      file=null;
      isUploading=false;
      postId=Uuid().v4();
    });
  }


  premiumSubmit(){
    print("premium");
    Navigator.pop(context);
  }



  Container buildUpload(){
    return Container(
        child: ListView(
          shrinkWrap: true,
          children: [
            Column(
              children:[
                AppBar(
                  elevation: 10,
              backgroundColor: Colors.white70,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,color: Colors.black,), onPressed: clearimage,  ),
              title: Text("Caption Post",
              style: TextStyle(
                color: Colors.black
              ),),
              actions: [
                FlatButton(
                    //onPressed: isUploading ? null: ()=>handleSubmit(),

                  onPressed: (){
                    // setState(() {
                    //   _isPostType=true;
                    // });
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          backgroundColor: AIColors.primaryColor2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 16,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: ListView(
                              shrinkWrap: true,
                              children: <Widget>[
                                Center(child: Text("PostType",style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white
                                ),),),
                                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                                //_buildRow('Normal Post',Icon(Icons.perm_media_rounded),handleSubmit()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    height: MediaQuery.of(context).size.height*0.04,
                                    child: Material(
                                      borderRadius: BorderRadius.circular(8.0),
                                      shadowColor: Colors.white,
                                      color: Colors.white,
                                      elevation: 10.0,
                                      child:
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          InkWell(
                                            onTap: isUploading ? null: ()=>handlePostSubmit(),
                                            child: Text("Normal Post",style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold
                                            ),),
                                          ),
                                          Icon(Icons.perm_media_rounded),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                                //_buildRow('Product',Icon(Icons.sell),productSubmit()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height: MediaQuery.of(context).size.height*0.04,
                                        child: Material(
                                          borderRadius: BorderRadius.circular(8.0),
                                          shadowColor: Colors.white,
                                          color: Colors.white,
                                          elevation: 10.0,
                                          child:
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              InkWell(
                                                //onTap: _showPersistantBottomSheetCallBack,
                                                onTap:(){
                                                  Navigator.pop(context);
                                                  showModalBottomSheet(
                                                      //isScrollControlled = false,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                                                      ),
                                                      isScrollControlled: true,
                                                      context: context,
                                                      builder: (context) {
                                                        return Container(
                                                            padding: EdgeInsets.only(
                                                            bottom: MediaQuery.of(context).viewInsets.bottom,),
                                                          child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: <Widget>[
                                                                  Text("Product detail",style: TextStyle(
                                                                    fontSize: 25,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),),
                                                                  ListTile(
                                                                    leading: new Icon(Icons.production_quantity_limits_sharp),
                                                                    title: new Container(
                                                                      decoration: BoxDecoration(
                                                                        shape: BoxShape.rectangle,
                                                                          color: AIColors.primaryColor2,
                                                                          borderRadius: BorderRadius.circular(9)
                                                                      ),
                                                                      child:TextFormField(
                                                                        controller: quantityController,
                                                                          decoration: new InputDecoration(
                                                                            hintText: '   Quantity of Product',
                                                                            hintStyle: TextStyle(color: Colors.white),
                                                                            prefixText: "   ",
                                                                            border: InputBorder.none,

                                                                          ),
                                                                        ),
                                                                    ),
                                                                  ),
                                                                  ListTile(
                                                                    leading: new Icon(Icons.price_change_sharp),
                                                                    title: new Container(
                                                                        decoration: BoxDecoration(
                                                                          shape: BoxShape.rectangle,
                                                                          color: AIColors.primaryColor2,
                                                                          borderRadius: BorderRadius.circular(9)
                                                                        ),
                                                                        child:TextFormField(
                                                                            controller: priceController,
                                                                            decoration: new InputDecoration(
                                                                              hintText: '   Price of Product',
                                                                              hintStyle: TextStyle(color: Colors.white),
                                                                              prefixText: "Rs.",

                                                                              border: InputBorder.none,

                                                                            ),
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  RaisedButton(
                                                                    elevation: 5,
                                                                    onPressed: isUploading ? null: ()=>handleProductSubmit(),
                                                                    child: Text("submit",style: TextStyle(
                                                                      color: Colors.white
                                                                    ),),
                                                                    color: AIColors.primaryColor2,
                                                                  ),
                                                                  SizedBox(
                                                                    height: MediaQuery.of(context).size.height*0.01,
                                                                  )
                                                                ],
                                                              ),
                                                        );
                                                      });},
                                                child: Text("Product",style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold
                                                ),),
                                              ),
                                              Icon(Icons.sell),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                                //_buildRow('Premium',Icon(Icons.monetization_on),premiumSubmit()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height: MediaQuery.of(context).size.height*0.04,
                                        child: Material(
                                          borderRadius: BorderRadius.circular(8.0),
                                          shadowColor: Colors.white,
                                          color: Colors.white,
                                          elevation: 10.0,
                                          child:
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              InkWell(
                                                onTap: isUploading ? null: ()=>premiumSubmit(),
                                                child: Text("Premium",style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold
                                                ),),
                                              ),
                                              Icon(Icons.monetization_on),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                    },
                    child: Text("Post Type",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),))],
              ),
            
            isUploading? LinearProgress():Text(""),
            Container(
                  height: MediaQuery.of(context).size.height*0.4,
                  width: MediaQuery.of(context).size.width*0.95,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: FileImage(file!),
                      )
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                Container(
                  color: Colors.grey[300],
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider("$image"),
                    ),
                    title: Container(
                      width: 250,
                      child: TextField(
                        controller: captionController,
                        decoration: InputDecoration(
                          hintText: "Write  a caption..",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(),
                Container(
                  color: Colors.grey[300],
                  child: ListTile(
                    leading: Icon(Icons.pin_drop,color: Colors.orange,size: 35,),
                    title: Container(
                      width: 250,
                      child:TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          hintText: "Add Location",
                          border: InputBorder.none,
                        ),
                      )
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.04,),
                Container(
                  alignment: Alignment.center,
                  child: RaisedButton.icon(
                      onPressed: isUploadingLocation ? null: ()=>getUserLocation(),
                      icon: Icon(Icons.my_location),
                      label: Text("Use Current Location",style:TextStyle(
                        color:Colors.white
                      )),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                  ),
                  color: AIColors.primaryColor2,),
                ),
                isUploadingLocation? CircularProgress():Text(""),
                SizedBox(height: MediaQuery.of(context).size.height*0.09,),
            ],),
          ],
        ),
        );
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
    try{
      Position position=await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,forceAndroidLocationManager: true);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,position.longitude
      );
      Placemark placemark =placemarks[0];
      String address="${placemark.locality}, ${placemark.postalCode}, ${placemark.country}";
      print(address);
      locationController.text=address;
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
    return file==null?buildUploadScreen():buildUpload();
  }
}
