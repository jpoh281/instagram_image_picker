//import 'dart:io';
//import 'package:flutter/material.dart';
//import 'package:flutter_native_image/flutter_native_image.dart';
//import 'package:get/get.dart';
//import 'package:instagramimagepicker/controller/old_gallery_controller.dart';
//import 'package:instagramimagepicker/widget/media_grid.dart';
//import 'package:photo_manager/photo_manager.dart';
//import 'package:simple_image_crop/simple_image_crop.dart';
//
////oldVersion 2020-08-20.
//
//class ProfileGallery extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text("갤러리"),
//        actions: <Widget>[
//          FlatButton(
//              onPressed: () async {
//                final crop = OldGalleryController.to.cropKey.currentState;
//
//                final croppedFile = await crop.cropCompleted(
//                    File(OldGalleryController.to.indexFilePath),
//                    pictureQuality: 4000);
//                await PhotoManager.editor.saveImageWithPath(croppedFile.path);
//                final resizedFile = await FlutterNativeImage.compressImage(
//                    croppedFile.path,
//                    quality: 100,
//                    targetHeight: 250,
//                    targetWidth: 250);
//
//                showImage(context, resizedFile);
//              },
//              child: Text("선택"))
//        ],
//      ),
//      body: GetBuilder<OldGalleryController>(
//          init: OldGalleryController(),
//          builder: (_) {
//            return FutureBuilder(
//                future: _.getMaxIndex(),
//                builder: (context, snapshot) {
//                  _.maxIndex = snapshot.data;
//                  if (snapshot.hasData) {
//                    return Column(
//                      children: <Widget>[
//                        PictureCrop(),
//                        Expanded(child: ThumbnailLists()),
//                        //Expanded(child: ThumbnailLists()),
//                      ],
//                    );
//                  }
//                  return Container();
//                });
//          }),
//    );
//  }
//
//  Future<Null> showImage(BuildContext context, File file) async {
//    new FileImage(file)
//        .resolve(new ImageConfiguration())
//        .addListener(ImageStreamListener((ImageInfo info, bool _) {
//      print('-------------------------------------------$info');
//    }));
//    return showDialog<Null>(
//        context: context,
//        builder: (BuildContext context) {
//          return AlertDialog(
//              title: Text(
//                'Current screenshot：',
//                style: TextStyle(
//                    fontFamily: 'Roboto',
//                    fontWeight: FontWeight.w300,
//                    color: Theme.of(context).primaryColor,
//                    letterSpacing: 1.1),
//              ),
//              content: SizedBox(
//                width: 125,
//                height: 125,
//                child: Image.file(
//                  file,
//                ),
//              ));
//        });
//  }
//}
//
//class PictureCrop extends StatelessWidget {
//  final cropKey = GlobalKey<ImgCropState>();
//  @override
//  Widget build(BuildContext context) {
//    return SizedBox(
//      width: Get.width,
//      height: Get.width,
//      child: FutureBuilder(
//        future: OldGalleryController.to.getBigItem(OldGalleryController.to.index),
//        builder: (context, snapshot) {
//          if (snapshot.connectionState == ConnectionState.done) {
//            OldGalleryController.to.indexFilePath = snapshot.data;
//            return ImgCrop.file(
//              File(snapshot.data),
//              key: OldGalleryController.to.cropKey,
//              scale: 1.0,
//              maximumScale: 1.0,
//              chipShape: 'rect',
//              chipRadius: Get.width / 2 - 10,
//            );
//          }
//          return Center(child: CircularProgressIndicator());
//        },
//      ),
//    );
//  }
//}
//
//class ThumbnailLists extends StatelessWidget {
//  const ThumbnailLists({
//    Key key,
//  }) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    return GridView.builder(
//        gridDelegate:
//            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
//        itemCount: OldGalleryController.to.maxIndex,
//        itemBuilder: (context, index) {
//          return _buildItem(index);
//        });
//  }
//
//  _buildItem(int index) => GestureDetector(
//      onTap: () {
//        if (!(OldGalleryController.to.index == index) &&
//            !OldGalleryController.to.loading) {
//          OldGalleryController.to.index = index;
//          OldGalleryController.to.update();
//        }
//      },
//      child: FutureBuilder(
//          future: OldGalleryController.to.getItem(index),
//          builder: (context, snapshot) {
//            if (snapshot.hasData) {
//              var item = snapshot?.data;
//              if (item != null) {
//                return Container(
//                    decoration: BoxDecoration(
//                  border: Border.all(color: Colors.black, width: 1),
//                  image: DecorationImage(
//                      image: MemoryImage(item.bytes), fit: BoxFit.cover),
//                ));
//              }
//            }
//
//            return Container();
//          }));
//}
