import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagramimagepicker/image_picker_page.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

//  Future<bool> _checkPermission() async {
//    Map<Permission, PermissionStatus> status = {
//      Permission.camera: await Permission.camera.status,
//      Permission.storage: await Permission.storage.status,
//    };
//
//    status.forEach((Permission, PermissionStatus) {
//      if (!PermissionStatus.isGranted) Permission.request();
//    });
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Instagram Image Picker"),
      ),
      body: Center(
          child: FlatButton(
              onPressed: () async {
//                await _checkPermission();
                //await _requestPermission();
                return Get.to(ImagePickerPage());
              },
              child: Container(
                child: Text("사진 고르기"),
                color: Colors.blue,
              ))),
    );
  }
}
