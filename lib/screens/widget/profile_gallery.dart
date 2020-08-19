import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:get/get.dart';
import 'package:instagramimagepicker/screens/controller/gallery_category_controller.dart';
import 'package:instagramimagepicker/screens/controller/gallery_crop_controller.dart';
import 'package:instagramimagepicker/screens/controller/gallery_grid_controller.dart';
import 'package:instagramimagepicker/screens/controller/view_scroll_controller.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:simple_image_crop/simple_image_crop.dart';

class ProfileGallery extends StatelessWidget {
  final GalleryCategoryController galleryCategoryController =
      Get.put(GalleryCategoryController());
  final GalleryCropController galleryCropController =
      Get.put(GalleryCropController());
  final GalleryGridController galleryGridController =
      Get.put(GalleryGridController());
  final ViewScrollController viewScrollController =
      Get.put(ViewScrollController());
  final cropKey = GlobalKey<ImgCropState>();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: galleryCategoryController.initalizeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done)
          return Scaffold(
            appBar: AppBar(
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GetBuilder<GalleryCategoryController>(
                      builder: (controller) => DropdownButtonHideUnderline(
                          child: DropdownButton(
                        items: controller.getItems(),
                        value: controller.value,
                        onChanged: controller.onChanged,
                      )),
                    ),
                    FlatButton(
                        onPressed: () async {
                          final crop = cropKey.currentState;

                          final croppedFile = await crop.cropCompleted(
                              await galleryCropController.image,
                              pictureQuality: 4000);
                          await PhotoManager.editor
                              .saveImageWithPath(croppedFile.path);
                          final resizedFile =
                              await FlutterNativeImage.compressImage(
                                  croppedFile.path,
                                  quality: 100,
                                  targetHeight: 250,
                                  targetWidth: 250);

                          showImage(context, resizedFile);
                        },
                        child: Text("다음"))
                  ],
                ),
              ],
            ),
            body: Column(children: <Widget>[
              Obx(() => SizedBox(
                    width: Get.width,
                    height: Get.width,
                    child: FutureBuilder(
                        future: galleryCropController.image,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done)
                            return ImgCrop.file(
                              snapshot.data,
                              key: cropKey,
                              scale: 1.0,
                              maximumScale: 1.0,
                              chipShape: 'rect',
                              chipRadius: Get.width / 2 - 10,
                            );
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }),
                  )),
              Obx(() => Expanded(
                  child: GridView.builder(
                      controller: viewScrollController.scrollController,
                      itemCount: galleryGridController.items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4),
                      itemBuilder: (BuildContext context, int index) {
                        return galleryGridController.items[index];
                      })))
            ]),
          );
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
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
                width: 125,
                height: 125,
                child: Image.file(
                  file,
                ),
              ));
        });
  }
}
