import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:me_you/ai_color.dart';
import 'package:me_you/authscreen.dart';
import 'package:me_you/homePage.dart';
import 'package:me_you/landingPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final Future<FirebaseApp> _initialization=Firebase.initializeApp();
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context,appSnapshot){
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'My App',
            home: LandingPage());
        //     home:appSnapshot.connectionState != ConnectionState.done
        //         ? CircularProgressIndicator() : StreamBuilder(
        //     stream: FirebaseAuth.instance.authStateChanges(),
        // builder: (ctx,userSnapshot){
        // if(userSnapshot.connectionState == ConnectionState.waiting){
        // return CircularProgressIndicator();
        // }
        // return LandingPage();
        // }));
      },
    );
  }
}

