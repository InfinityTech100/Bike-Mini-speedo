
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:urad3/pages/SplashPage.dart';
import 'package:urad3/pages/homePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        //accentColor: Color(0xFF3BB5EA),
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var splash = SplashScreen('assets/images/logo.png');

  bool showsplash = true;


  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    Timer(Duration(seconds: 4), () {

      thread();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    //var HomePage = HomePge(screenWidth,screenHeight);
    return Scaffold(
     // body:(showsplash==true)? splash.SplashPage():HomePage.build(),
        body:splash.SplashPage(),
    );
  }

  void thread() {
    setState(() {
      showsplash = false;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  HomePge()),
      );

    });

  }
}
// Timer? timer;
// @override
// void initState() {
//   super.initState();
//   startTimer();
// }
//
// void startTimer() {
//   timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
//     print("hello");
//   });
// }
//
// @override
// void dispose() {
//   timer?.cancel(); // Cancel the timer when the state is disposed
//   super.dispose();
// }
//
