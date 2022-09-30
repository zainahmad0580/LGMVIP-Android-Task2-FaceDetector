import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import 'screens/home_screen.dart';
import 'home_screen2.dart';

List<CameraDescription> cameras = [];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]); //to hide status bar
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]); //to restrict screen rotation
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Face Detector',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        //home: const FaceDetectorScreen(),
        home: AnimatedSplashScreen(
          duration: 3000,
          splash: Lottie.asset('assets/images/splash.json'),
          splashIconSize: 300,
          splashTransition: SplashTransition.fadeTransition,
          nextScreen: const FaceDetectorScreen(),
        ));
  }
}
