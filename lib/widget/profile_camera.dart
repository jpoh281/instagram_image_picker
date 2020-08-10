import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ProfileCamera extends StatefulWidget {
  @override
  _ProfileCameraState createState() => _ProfileCameraState();
}

class _ProfileCameraState extends State<ProfileCamera> {
  List<CameraDescription> cameras = [];
  CameraController _cameraController;
  int frontCameraIndex;
  int backCameraIndex;
  int nowCameraIndex;
  Future<void> _initalizeControllerFuture;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initalizeControllerFuture = initCamera();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _cameraController.dispose();
    super.dispose();
  }

  initCamera() async {
    cameras = await availableCameras();
    frontCameraIndex = cameras.indexWhere(
        (element) => element.lensDirection == CameraLensDirection.front);
    backCameraIndex = cameras.indexWhere(
        (element) => element.lensDirection == CameraLensDirection.back);
    nowCameraIndex = backCameraIndex;

    _cameraController = CameraController(
        cameras[nowCameraIndex], ResolutionPreset.max,
        enableAudio: false);

    await _cameraController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initalizeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _cameraController.value.isInitialized) {
          return Column(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: ClipRect(
                  child: Transform.scale(
                    scale: 1 / _cameraController.value.aspectRatio,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _cameraController.value.aspectRatio,
                        child: CameraPreview(_cameraController),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await takePicture(context);
                  },
                  child: Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: ShapeDecoration(
                                shape: CircleBorder(
                                    side: BorderSide(
                                        color: Colors.grey[300], width: 20))),
                          ),
                        ),
                        IconButton(
                            icon: Icon(Icons.autorenew),
                            onPressed: () async => onNewCameraSelected())
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  void onNewCameraSelected() async {
    if (cameras.isEmpty) return;
    if (cameras.length < 2) return;

    if (_cameraController != null) {
      await _cameraController.dispose();
    }

    if (nowCameraIndex == backCameraIndex) {
      nowCameraIndex = frontCameraIndex;
    } else {
      nowCameraIndex = backCameraIndex;
    }

    _cameraController = CameraController(
        cameras[nowCameraIndex], ResolutionPreset.max,
        enableAudio: false);
    // If the controller is updated then update the UI.
    _cameraController.addListener(() {
      if (mounted) setState(() {});
      if (_cameraController.value.hasError) {
        print('Camera error ${_cameraController.value.errorDescription}');
      }
    });
    try {
      await _cameraController.initialize();
    } on CameraException catch (e) {
      print(e);
    }
    if (mounted) {
      setState(() {});
    }
  }

  takePicture(context) async {
    try {
      await _initalizeControllerFuture;
      final path = await createPath();
      await _cameraController.takePicture(path);
      final File croppedFile = await crop(path);
      final resizedFile = await FlutterNativeImage.compressImage(
          croppedFile.path,
          quality: 100,
          targetHeight: 250,
          targetWidth: 250);
      await showImage(context, resizedFile);
    } catch (e) {
      print(e);
    }
  }

  createPath() async {
    return join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');
  }

  Future<File> crop(String filePath) async {
    var imageProperties = await FlutterNativeImage.getImageProperties(filePath);

    var cropSize = min(imageProperties.width, imageProperties.height);
    print(cropSize);
    int offsetX = (imageProperties.width - cropSize) ~/ 2;
    int offsetY = (imageProperties.height - cropSize) ~/ 2;

    return await FlutterNativeImage.cropImage(
        filePath, offsetX, offsetY, cropSize, cropSize);
  }

  Future<Null> showImage(BuildContext context, File file) async {
    new FileImage(file)
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      print('-------------------------------------------$info');
    }));
    return showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(
                'Current screenshot：',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 1.1),
              ),
              content: SizedBox(
                width: 250,
                height: 250,
                child: Image.file(
                  file,
                ),
              ));
        });
  }
}
