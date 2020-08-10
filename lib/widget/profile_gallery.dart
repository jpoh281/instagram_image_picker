import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

import 'package:get/get.dart';
import 'package:instagramimagepicker/controller/gallery_controller.dart';
import 'package:simple_image_crop/simple_image_crop.dart';

class ProfileGallery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("갤러리"),
        actions: <Widget>[
          FlatButton(
              onPressed: () async {
                final crop = GalleryController.to.cropKey.currentState;

                final croppedFile = await crop.cropCompleted(
                    File(GalleryController.to.indexFilePath),
                    pictureQuality: 1080);

                final resizedFile = await FlutterNativeImage.compressImage(
                    croppedFile.path,
                    quality: 100,
                    targetHeight: 250,
                    targetWidth: 250);

                showImage(context, resizedFile);
              },
              child: Text("선택"))
        ],
      ),
      body: GetBuilder<GalleryController>(
          init: GalleryController(),
          builder: (_) {
            return FutureBuilder(
                future: _.getMaxIndex(),
                builder: (context, snapshot) {
                  _.maxIndex = snapshot.data;
                  if (snapshot.hasData) {
                    return Column(
                      children: <Widget>[
                        PictureCrop(),
                        Expanded(child: ThumbnailLists()),
                      ],
                    );
                  }
                  return Container();
                });
          }),
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
                width: 250,
                height: 250,
                child: Image.file(
                  file,
                ),
              ));
        });
  }
}

class PictureCrop extends StatelessWidget {
  final cropKey = GlobalKey<ImgCropState>();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      height: Get.width,
      child: FutureBuilder(
        future: GalleryController.to.getBigItem(GalleryController.to.index),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            GalleryController.to.indexFilePath = snapshot.data;
            return ImgCrop.file(
              File(snapshot.data),
              key: GalleryController.to.cropKey,
              scale: 1.0,
              maximumScale: 1.0,
              chipShape: 'rect',
              chipRadius: Get.width / 2 - 10,
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class ThumbnailLists extends StatelessWidget {
  const ThumbnailLists({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
        itemCount: GalleryController.to.maxIndex,
        itemBuilder: (context, index) {
          return _buildItem(index);
        });
  }

  _buildItem(int index) => GestureDetector(
      onTap: () {
        if (!(GalleryController.to.index == index) &&
            !GalleryController.to.loading) {
          GalleryController.to.index = index;
          GalleryController.to.update();
        }
      },
      child: FutureBuilder(
          future: GalleryController.to.getItem(index),
          builder: (context, snapshot) {
            var item = snapshot?.data;
            if (item != null) {
              return Container(
                child: Image.memory(item.bytes, fit: BoxFit.cover),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
              );
            }

            return Container();
          }));
}
