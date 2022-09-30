import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:task_2/CameraView.dart';
import 'package:task_2/face_detector_painter.dart';

class FaceDetectorScreen extends StatefulWidget {
  const FaceDetectorScreen({Key? key}) : super(key: key);

  @override
  State<FaceDetectorScreen> createState() => _FaceDetectorScreenState();
}

class _FaceDetectorScreenState extends State<FaceDetectorScreen> {
  final FaceDetector faceDetector = FaceDetector(
      options: FaceDetectorOptions(
          enableContours: true, enableClassification: true));
  bool canProcess = true;
  bool isbusy = false;
  CustomPaint? custompaint;
  String? _text;

  @override
  void dispose() {
    // TODO: implement dispose

    canProcess = false;
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Camera_view(
      Title: 'Face Detector',
      custompaint: custompaint,
      Text: _text,
      onImage: (inputimage) {
        processImage(inputimage);
      },
      initialDirection: CameraLensDirection.back,
    );
  }

  Future<void> processImage(final InputImage inputimage) async {
    if (!canProcess) {
      return;
    }
    if (isbusy) return;
    isbusy = true;
    setState(() {
      _text = " ";
    });
    final faces = await faceDetector.processImage(inputimage);
    if (inputimage.inputImageData?.size != null &&
        inputimage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputimage.inputImageData!.size,
          inputimage.inputImageData!.imageRotation);
      custompaint = CustomPaint(
        painter: painter,
      );
    } else {
      String text = 'faces found:${faces.length}\n\n';
      for (final face in faces) {
        text += 'face:${face.boundingBox}\n\n';
      }
      _text = text;
      custompaint = null;
    }
    isbusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
