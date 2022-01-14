import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:me_you/authscreen.dart';
import 'package:me_you/homePage.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final FirebaseAuth auth= FirebaseAuth.instance;
  late User? _user ;

  @override
  void initState() {
    super.initState();
    _rebuilt(auth.currentUser);
  }

  void _rebuilt(User? user){
    setState(() {
      _user=user;
      print(_user);
    });
  }

  @override
  Widget build(BuildContext context) {
    //print(_user!.uid);
    if (_user==null){
      return AuthScreen(
          onSignIn:(user)=>_rebuilt(user)
      );
    }
    return HomePage(
        onSignOut: ()=>_rebuilt(null) ,
      Id: _user!.uid,
    );
  }
}
