import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:instagramimagepicker/screens/controller/gallery_crop_controller.dart';
import 'package:instagramimagepicker/screens/controller/gallery_grid_controller.dart';
import 'package:instagramimagepicker/screens/controller/view_scroll_controller.dart';

import 'package:photo_manager/photo_manager.dart';

class GalleryCategoryController extends GetxController {
  static GalleryCategoryController get to => Get.find();
  List<AssetPathEntity> albums;
  Future<void> initalizeControllerFuture;
  AssetPathEntity value;
  int currentPage = 0;
  int lastPage;
  bool isLoading = false;
  bool isEnd = false;

  Function onChanged = (value) async {
    if (Get.find<GalleryCategoryController>().value == value) return;
    await Get.find<ViewScrollController>().reset();

    Get.find<GalleryCategoryController>().currentPage = 0;
    Get.find<GalleryCategoryController>().isEnd = false;
    Get.find<GalleryCategoryController>().value = value;
    List<AssetEntity> images =
        await value.getAssetListPaged(0, 60); // firstPage = 0, indexCount = 60;
    Get.find<GalleryGridController>().onReBuild(images);
    Get.find<GalleryCropController>().image = images[0].originFile;

    if (value.assetCount >
        Get.find<GalleryCategoryController>().currentPage * 60) {
      Get.find<GalleryCategoryController>().lastPage =
          Get.find<GalleryCategoryController>().currentPage + 1;
    } else {
      Get.find<GalleryCategoryController>().isEnd = true;
    }

    Get.find<GalleryCategoryController>().update();
  };

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initalizeControllerFuture = getAlbumList();
  }

  Future<void> getAlbumList() async {
    if (isLoading) return;
    isLoading = true;
    albums = await PhotoManager.getAssetPathList(
        hasAll: true, type: RequestType.image);
    value = albums[0];
    List<AssetEntity> images = await value.getAssetListPaged(0, 60);
    Get.find<GalleryGridController>().onBuild(images);
    Get.find<GalleryCropController>().image = images[0].originFile;
    if (value.assetCount > currentPage * 60) {
      lastPage = currentPage + 1;
    } else {
      isEnd = true;
    }
    isLoading = false;
  }

  Future<void> getMoreAlbumList() async {
    if (isLoading) return;
    if (isEnd) return;
    isLoading = true;
    currentPage = lastPage;
    List<AssetEntity> images = await value.getAssetListPaged(currentPage, 60);
    Get.find<GalleryGridController>().onBuild(images);
    if (value.assetCount > currentPage * 60) {
      lastPage = currentPage + 1;
    } else {
      isEnd = true;
    }
    isLoading = false;
  }

  List<DropdownMenuItem<AssetPathEntity>> getItems() {
    return albums
            .map((e) => DropdownMenuItem(
                child: Text(
                  e.name,
                  overflow: TextOverflow.clip,
                ),
                value: e))
            .toList() ??
        [];
  }
}