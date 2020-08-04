import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              Container(
                width: Get.width,
                height: Get.width,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Container(
                        width: Get.width,
                        height: Get.width / _cameraController.value.aspectRatio,
                        child: CameraPreview(
                            _cameraController), // this is my CameraPreview
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {},
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

    _cameraController =
        CameraController(cameras[nowCameraIndex], ResolutionPreset.max);
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
}
