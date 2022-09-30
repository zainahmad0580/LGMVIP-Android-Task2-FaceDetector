import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.orange,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Image(image: AssetImage('assets/images/face-recog.jpg')),
            Container(
              margin: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width / 2,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40))),
                icon: const Icon(Icons.camera_enhance),
                label: const Text('Open Face Detector'),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return const FaceDetectorScreen();
                  }));
                },
              ),
            ),
          ],
        ));
  }
}
