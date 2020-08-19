import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagramimagepicker/screens/controller/gallery_controller.dart';

class ViewScrollController extends GetxController {
  var scrollController = ScrollController(keepScrollOffset: false);

  void onScroll() {
    if (Get.find<GalleryController>().isLoading) return;
    if (Get.find<GalleryController>().isEnd) return;

    if (scrollController.offset >
        scrollController.position.maxScrollExtent * 0.9) {
      print(scrollController.position.maxScrollExtent * 0.9);
      Get.find<GalleryController>().getMoreAlbumList();
    }
  }

  Future<void> reset() async {
    await scrollController.animateTo(0,
        duration: Duration(milliseconds: 500), curve: Curves.linear);
    scrollController.removeListener(onScroll);
    scrollController?.dispose();
    scrollController = ScrollController(keepScrollOffset: false);
    scrollController.addListener(onScroll);
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    scrollController.addListener(onScroll);
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    scrollController.removeListener(onScroll);
  }
}
