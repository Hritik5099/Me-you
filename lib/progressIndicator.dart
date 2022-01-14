import 'package:flutter/material.dart';
import 'package:me_you/ai_color.dart';

Container CircularProgress(){
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top:14),
    child: CircularProgressIndicator(
      valueColor:AlwaysStoppedAnimation(Colors.black),
    ),
  );
}

Container LinearProgress(){
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
    valueColor: AlwaysStoppedAnimation(AIColors.primaryColor2),
  ),
  );
}
