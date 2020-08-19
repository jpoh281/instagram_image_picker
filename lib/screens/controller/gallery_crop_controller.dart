import 'dart:io';

import 'package:get/state_manager.dart';

class GalleryCropController extends GetxController {
  Rx<Future<File>> _cropImage = Rx<Future<File>>();
  Future<File> get image => _cropImage.value;
  set image(Future<File> file) => _cropImage.value = file;
}
