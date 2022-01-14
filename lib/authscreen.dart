import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:email_auth/email_auth.dart';
import 'package:me_you/database.dart';

import 'AccountPage.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key, required this.onSignIn}) : super(key: key);
  final void Function(User) onSignIn;

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool otpSent=false;
  var sign;
  @override
  void initState() {
    super.initState();
    sign=widget.onSignIn;
  }

    var _isSignIn=true;
  bool isSecurePassword=true;
  bool isSecureConfirmPassword=true;

  final _formkey=GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final auth=FirebaseAuth.instance;

  void sendOtp() async{
    setState(() {
      otpSent=true;
    });
    EmailAuth.sessionName="Send by hritik flutter";
    var rec= await EmailAuth.sendOtp(receiverMail: _emailController.text);
    if (rec){
      print("otp send");
    }
    else{
      print("otp send failed..retry!");
    }
    setState(() {
      otpSent=false;
    });
  }

  void verifyOtp(){
    var res=EmailAuth.validate(receiverMail: _emailController.text, userOTP: _otpController.text);
    if (res){
      print("verified");
      _submit(
        _emailController.text,
        _passwordController.text,
        _isSignIn,);
    }
    else{
      print("otp not verified");
      // need to work
      //
      //
      //
      //
      //
      //
      //
    }
  }

  String? validatorEmail(String value){
    if (_isSignIn == false){
      if (value.isEmpty && !(value.contains("@"))) {
        return "Enter a valid Email";
      }
    }
    return null;
  }

  String? validatePassword(String value) {
    //Added the regular expression which contains all the possible values for the condition of password
    if (_isSignIn == false){
      if ((value.length < 8)) {
        return 'Please enter password of 8 character';
      }
      if (value.isEmpty) {
        return 'Please enter password';
      }
      if ((!value.contains(RegExp(r"[a-z]"))) ||
          (!value.contains(RegExp(r"[A-Z]"))) ||
          (!value.contains(RegExp(r"[0-9]"))) ||
          (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')))) {
        return "Please enter a valid password";
      }
    }
    return null;
  }

  showAlertDialog(BuildContext context,Exception exception) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );


    AlertDialog alert = AlertDialog(
      title: Text("Alert"),
      content: Text("${exception.toString()}"),
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

      //showAlertDialog(BuildContext context) {
  //           Widget noButton = FlatButton(
  //               child: Text("No"),
  //               onPressed: () {
  //                 Navigator.push(context, MaterialPageRoute(builder: (context)=>AccountPage(),));
  //               }
  //           );
  //
  //           Widget yesButton = FlatButton(
  //               child: Text("Yes"),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               }
  //           );
  //           AlertDialog alert = AlertDialog(
  //             title: Text("Hello"),
  //             content: Text("Have to filled your Account info?"),
  //             actions: [noButton,yesButton],
  //           );
  //           showDialog(
  //               context: context,
  //               builder: (BuildContext context){
  //                 return alert;
  //               });
  //         }




  Future<User?> _submit(
      String email,
      String password,
      bool isSign,
      ) async{
    print(isSign);
    UserCredential userCredential;
    try{
      if (isSign){
        print("sign in");
        print(isSign);
        userCredential=await auth.signInWithEmailAndPassword(email: email, password: password);
         print(userCredential.user!.email);
        sign(userCredential.user);
      }
      else{

        print('create account');
        print(isSign);
        userCredential=await auth.createUserWithEmailAndPassword(email: email, password: password);
        print(userCredential.user!.email);
        sign(userCredential.user);
      }
    } on Exception catch (err) {
      print("worked");
      showAlertDialog(context, err);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/background.png"),
                  fit: BoxFit.fill,
              ),

          ),
          child: Stack(
              children: [
                Row(
                  children: [
                    Image(image: AssetImage("assets/light-1.png")),
                    SizedBox(width: MediaQuery.of(context).size.width*0.05,),
                    Container(
                        height: MediaQuery.of(context).size.height*0.3,
                        child: Image(image: AssetImage("assets/light-2.png"))),
                    SizedBox(width: MediaQuery.of(context).size.width*0.15,),
                    Image(image: AssetImage("assets/clock.png")),
                  ],
                ),


                Form(
                  key: _formkey,
                  child: Container(
                    padding: const EdgeInsets.only(top: 250,left:10,right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Name",style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),),

                        TextField(
                          key: ValueKey("Email"),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              icon: Icon(Icons.attach_email_outlined),
                              labelText: "Email",
                              hintText: "abc@gmail.com",
                              labelStyle: TextStyle(fontWeight:FontWeight.bold),
                              errorText: validatorEmail(_emailController.text),
                              focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                            )
                          ),
                          cursorColor: Colors.black,
                        ),

                        TextField(
                          key: ValueKey("Password"),
                          controller: _passwordController,
                          decoration: InputDecoration(
                              icon: Icon(Icons.lock),
                              labelText: "Password",
                              hintText: "Abc@5099",
                              labelStyle: TextStyle(fontWeight:FontWeight.bold),
                              errorText: validatePassword(_passwordController.text),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                              ),
                              suffixIcon: IconButton(
                                onPressed: (){
                                  print("eye");
                                  setState(() {
                                    isSecurePassword=!isSecurePassword;
                                  });
                                },
                                icon: Icon(Icons.remove_red_eye),
                              )
                          ),
                          obscureText: isSecurePassword,
                        ),

                          SizedBox(height: MediaQuery.of(context).size.height*0.015,),

                          if (_isSignIn==false)
                          Container(
                            alignment: Alignment(1,0),
                            child: otpSent==false?InkWell(
                              child: Text("Send OTP",style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                                fontSize: 15,
                              )),
                              onTap: (){
                                print("registered");
                                sendOtp();
                              },
                            ):Row(children: [
                              Icon(Icons.check_circle,color: Colors.green,),
                              Text("OTP Sent",style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                decoration: TextDecoration.underline,
                                fontSize: 15,
                              )),
                            ],)
                          ),

                          if (_isSignIn==false)
                          TextField(
                            controller: _otpController,
                            decoration: InputDecoration(
                              icon: Icon(Icons.phonelink_lock),
                              labelText: "Enter the OTP",
                              labelStyle: TextStyle(fontWeight:FontWeight.bold),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),

                        SizedBox(height: MediaQuery.of(context).size.height*0.015,),

                        if (_isSignIn==true)
                        Container(
                          alignment: Alignment(1,0),
                          child: InkWell(
                            child: Text('Forgot Password',style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                decoration:TextDecoration.underline,
                                ),),
                            onTap:(){
                              print("pas");
                            },
                          ),
                        ),

                        SizedBox(height: MediaQuery.of(context).size.height*0.015,),

                        Container(
                          height: MediaQuery.of(context).size.height*0.05,
                          child: Material(
                            borderRadius: BorderRadius.circular(10.0),
                            shadowColor: Colors.greenAccent,
                            color: Colors.green,
                            elevation: 7.0,
                            child: InkWell(
                              onTap: (){
                                final isValid = _formkey.currentState!.validate();
                                print(_isSignIn);
                                if (isValid){
                                  _formkey.currentState!.save();
                                  (_isSignIn)?
                                  _submit(
                                    _emailController.text,
                                    _passwordController.text,
                                    _isSignIn,
                                  )
                                : (_isSignIn==false)?
                                  verifyOtp():print("error");}

                              },
                              child: Center(
                                child: Text((_isSignIn==true)?"SignIn":"SignUp",style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                                ),),
                              ),
                            ),
                          ),
                        ),


                        SizedBox(height: 12.0,),
                        Text("------Or------",style: TextStyle(
                            fontWeight:FontWeight.bold,
                            color: Colors.black,
                            fontSize: 20,
                        ),),


                        SizedBox(height: 25,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((_isSignIn==true)?"Don't have account?":"Already have an account?",style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15,
                            )
                            ),
                            SizedBox(width: 8,),
                            InkWell(
                              child: Text((_isSignIn==true)?"Register":"Sign In",style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                  fontSize: 15,
                              )),
                              onTap: (){
                                print("registered");
                                setState(() {
                                  _isSignIn = ! _isSignIn;
                                  print(_isSignIn);
                                }
                                );
                                _nameController.clear();
                                _passwordController.clear();
                                _emailController.clear();
                                _otpController.clear();
                              },
                            )
                          ],
                        )
                      ],
                    ),
              ),
                ),
                ]
            ),
          ),
      ),
      );
  }
}
