//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:get/get.dart';
//import 'package:instagramimagepicker/model/gallery_image.dart';
//import 'package:simple_image_crop/simple_image_crop.dart';
//
//class OldGalleryController extends GetxController {
//  static OldGalleryController get to => Get.find();
//  final cropKey = GlobalKey<ImgCropState>();
//
//  final _channel = MethodChannel("/gallery");
//
//  bool loading = false;
//
//  int _index = 0;
//  int get index => _index;
//  set index(int index) {
//    _index = index;
//  }
//
//  String _indexFilePath;
//  String get indexFilePath => _indexFilePath;
//  set indexFilePath(String indexFilePath) {
//    _indexFilePath = indexFilePath;
//  }
//
//  int _maxIndex;
//  int get maxIndex => _maxIndex;
//  set maxIndex(int maxIndex) {
//    _maxIndex = maxIndex;
//  }
//
//  Map<int, GalleryImage> _itemCache = Map<int, GalleryImage>();
//
//  Future<int> getMaxIndex() async {
//    Future<int> maxIndex = _channel.invokeMethod<int>("getItemCount");
//    return maxIndex;
//  }
//
//  Future<String> getBigItem(int index) async {
//    loading = true;
//    Future<String> url =
//        _channel.invokeMethod("getThumbnail", maxIndex - (index));
//    loading = false;
//    return url;
//  }
//
//  Future<GalleryImage> getItem(int index) async {
//    // TODO: fetch gallery content here
//    // 1
//
//    if (_itemCache[index] != null) {
//      return _itemCache[index];
//    } else {
//      var channelResponse = await _channel.invokeMethod(
//          "getMiniThumbnail", maxIndex - (1 + index));
//
//      // 3
//      var item = Map<String, dynamic>.from(channelResponse);
//      // 4
//      var galleryImage = GalleryImage(
//          bytes: item['data'],
//          id: item['id'],
//          dateCreated: item['created'],
//          location: item['location'],
//          path: item['path']);
//      //5
//
//      _itemCache[index] = galleryImage;
//      //6
//      return galleryImage;
//    }
//  }
//}
