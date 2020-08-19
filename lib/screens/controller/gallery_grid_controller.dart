import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:instagramimagepicker/screens/controller/gallery_crop_controller.dart';

import 'package:photo_manager/photo_manager.dart';

class GalleryGridController extends GetxController {
  final RxList _items = List<Widget>().obs;

  int nowPage = 0;
  int indexCount = 60;

  List<Widget> get items => _items.value;
  List<Widget> onReBuild(List<AssetEntity> images) {
    List<Widget> temp = [];
    for (var asset in images) {
      temp.add(
        FutureBuilder(
          future: asset.thumbDataWithSize(200, 200),
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done)
              return GestureDetector(
                onTap: () async {
                  Get.find<GalleryCropController>().image = asset.originFile;
                },
                child: Container(
                    decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  image: DecorationImage(
                      image: MemoryImage(snapshot.data), fit: BoxFit.cover),
                )),
              );
            return Container();
          },
        ),
      );
    }
    _items.assignAll(temp);
    return _items.value;
  }

  List<Widget> onBuild(List<AssetEntity> images) {
    List<Widget> temp = [];
    for (var asset in images) {
      temp.add(
        FutureBuilder(
          future: asset.thumbDataWithSize(200, 200),
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done)
              return GestureDetector(
                onTap: () async {
                  Get.find<GalleryCropController>().image = asset.originFile;
                },
                child: Container(
                    decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  image: DecorationImage(
                      image: MemoryImage(snapshot.data), fit: BoxFit.cover),
                )),
              );
            return Container();
          },
        ),
      );
    }
    _items.addAll(temp);
    return _items.value;
  }
}
