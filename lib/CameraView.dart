import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_2/main.dart';
import 'package:task_2/screen_mode.dart';

class Camera_view extends StatefulWidget {
  final String Title;
  final CustomPaint? custompaint;
  final String? Text;
  final Function(InputImage inputimage) onImage;
  final CameraLensDirection initialDirection;
  const Camera_view(
      {Key? key,
      required this.Title,
      required this.custompaint,
      this.Text,
      required this.onImage,
      required this.initialDirection})
      : super(key: key);

  @override
  State<Camera_view> createState() => _Camera_viewState();
}

class _Camera_viewState extends State<Camera_view> {
  ScreenMode _mode = ScreenMode.Live;
  CameraController? controller;
  File? image;
  String? _path;
  ImagePicker? imagepicker;
  int cameraindex = 0;
  double zoomlevel = 0.0, minzoomlevel = 0.0, maxzoomlevel = 0.0;
  final bool allowPicker = true;
  bool changingCameraLens = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagepicker = ImagePicker();
    if (cameras.any((element) =>
        element.lensDirection == widget.initialDirection &&
        element.sensorOrientation == 90)) {
      cameraindex = cameras.indexOf(cameras.firstWhere((element) =>
          element.lensDirection == widget.initialDirection &&
          element.sensorOrientation == 90));
    } else {
      cameraindex = cameras.indexOf(cameras.firstWhere(
          (element) => element.lensDirection == widget.initialDirection));
    }
    _startLive();
  }

  Future _startLive() async {
    final camera = cameras[cameraindex];
    controller =
        CameraController(camera, ResolutionPreset.high, enableAudio: false);
    controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller?.getMaxZoomLevel().then((value) {
        maxzoomlevel = value;
      });
      controller?.getMinZoomLevel().then((value) {
        zoomlevel = value;
        minzoomlevel = value;
      });

      controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _processCameraImage(final CameraImage image) async {
    final WriteBuffer allbytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allbytes.putUint8List(plane.bytes);
    }
    final bytes = allbytes.done().buffer.asUint8List();
    final Size imagesize =
        Size(image.width.toDouble(), image.height.toDouble());
    final camera = cameras[cameraindex];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.rotation0deg;
    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21;
    final planeData = image.planes.map((final Plane plane) {
      return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width);
    }).toList();

    final inputImageData = InputImageData(
        size: imagesize,
        imageRotation: imageRotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData);
    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
    widget.onImage(inputImage);
  }

  Widget _galleryBody() {
    return ListView(
      shrinkWrap: true,
      children: [
        image != null
            ? SizedBox(
                height: 400,
                width: 400,
                child: Stack(
                  fit: StackFit.expand,
                  children: [Image.file(image!)],
                ),
              )
            : const Icon(Icons.image, size: 200),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            child: const Text('From Gallery'),
            onPressed: () => _getImage(ImageSource.gallery),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            child: const Text('Take a Picture'),
            onPressed: () => _getImage(ImageSource.camera),
          ),
        ),
        if (image != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
                "${_path == null ? ' ' : 'image path: $_path'}\n\n${widget.Text ?? ' '}"),
          )
      ],
    );
  }

  Future _getImage(ImageSource source) async {
    setState(() {
      image = null;
      _path = null;
    });
    final pickedFile = await imagepicker?.pickImage(source: source);
    if (pickedFile != null) {
      _processPickedFile(pickedFile);
    }
    setState(() {});
  }

  Future _processPickedFile(XFile? pickedfile) async {
    final path = pickedfile?.path;
    if (path == null) {
      return;
    }
    setState(() {
      image = File(path);
    });
    _path = path;
    final inputimage = InputImage.fromFilePath(path);
    widget.onImage(inputimage);
  }

  Widget _body() {
    Widget body;
    if (_mode == ScreenMode.Live) {
      body = _liveBody();
    } else {
      body = _galleryBody();
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
      floatingActionButton: _floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget? _floatingActionButton() {
    if (_mode == ScreenMode.gallery) {
      return null;
    }
    if (cameras.length == 1) {
      return null;
    }
    return SizedBox(
      width: 70,
      height: 70,
      child: FloatingActionButton(
        onPressed: _switcherCamera,
        child: const Icon(
          Icons.cameraswitch_outlined,
          size: 40,
        ),
      ),
    );
  }

  Future _switcherCamera() async {
    setState(() {
      changingCameraLens = true;
    });
    cameraindex = (cameraindex + 1) % cameras.length;
    await _stopLive();
    await _startLive();
    setState(() => changingCameraLens = false);
  }

  Widget _liveBody() {
    if (controller?.value.isInitialized == false) {
      return Container();
    }
    final size = MediaQuery.of(context).size;

    var scale = size.aspectRatio * controller!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: scale,
            child: Center(
                child: changingCameraLens
                    ? const Center(
                        child: Text('Changing Camera Lens'),
                      )
                    : CameraPreview(controller!)),
          ),
          if (widget.custompaint != null) widget.custompaint!,
        ],
      ),
    );
  }

  void switchtoScreenMode() {
    image = null;
    if (_mode == ScreenMode.Live) {
      _mode = ScreenMode.gallery;
      _stopLive();
    } else {
      _mode = ScreenMode.Live;
      _startLive();
    }
    setState(() {});
  }

  Future _stopLive() async {
    await controller?.stopImageStream();
    await controller?.dispose();
    controller = null;
  }
}
