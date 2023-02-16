
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:human_genertor/home.dart';

class MySplash extends StatefulWidget {
  const MySplash({super.key});

  @override
  State<MySplash> createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 2,
      navigateAfterSeconds: Home(),
      title: Text('Face Generator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),),
      gradientBackground: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.fromRGBO(138, 35, 135, 1),Color.fromRGBO(255, 64, 87, 1)]),
      loaderColor: Colors.white,
    );
  }
}