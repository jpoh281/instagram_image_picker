import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:instagramimagepicker/controller/gallery_controller.dart';
import 'package:simple_image_crop/simple_image_crop.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GalleryController gc = Get.put(GalleryController());
  final GlobalKey<ImgCropState> cropKey = GlobalKey<ImgCropState>();
  PageController _pageController;
  Drag _drag;
  final containerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    if (_pageController.hasClients &&
        _pageController.position.context.storageContext != null) {
      if (!containerKey.globalPaintBounds.contains(details.globalPosition)) {
        _drag = _pageController.position.drag(details, _disposeDrag);
      }
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta < 0 &&
        _pageController.position.pixels ==
            _pageController.position.maxScrollExtent) {
      _drag?.cancel();
      _drag = _pageController.position.drag(
          DragStartDetails(
              globalPosition: details.globalPosition,
              localPosition: details.localPosition),
          _disposeDrag);
    }
    _drag?.update(details);
  }

  void _handleDragEnd(DragEndDetails details) {
    _drag?.end(details);
  }

  void _handleDragCancel() {
    _drag?.cancel();
  }

  void _disposeDrag() {
    _drag = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
              HorizontalDragGestureRecognizer>(
            () => HorizontalDragGestureRecognizer(),
            (HorizontalDragGestureRecognizer instance) {
              instance
                ..onStart = _handleDragStart
                ..onUpdate = _handleDragUpdate
                ..onEnd = _handleDragEnd
                ..onCancel = _handleDragCancel;
            },
          ),
        },
        child: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              GetBuilder<GalleryController>(
                  init: GalleryController(),
                  builder: (_) {
                    return FutureBuilder(
                        future: _.getMaxIndex(),
                        builder: (context, snapshot) {
                          _.maxIndex = snapshot.data;
                          if (snapshot.hasData) {
                            return Column(
                              children: <Widget>[
                                PictureCropper(
                                  key: containerKey,
                                  cropKey: cropKey,
                                ),
                                Expanded(child: ThumbnailList()),
                              ],
                            );
                          }
                          return Container();
                        });
                  }),
              CameraScreen(),
            ],
          ),
        ),
      ),
    );
  }
}

class PictureCropper extends StatelessWidget {
  final cropKey;
  const PictureCropper({Key key, this.cropKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      height: Get.width,
      child: FutureBuilder(
        future: GalleryController.to.getBigItem(GalleryController.to.index),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print(snapshot.data);
            return ImgCrop.file(File(snapshot.data),
                key: cropKey, chipShape: 'rect');
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class ThumbnailList extends StatelessWidget {
  const ThumbnailList({
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
        GalleryController.to.index = index;
        GalleryController.to.update();
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

class CameraScreen extends StatelessWidget {
  const CameraScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text('camera'),
        ),
      ),
    );
  }
}

extension GlobalKeyEx on GlobalKey {
  Rect get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    var translation = renderObject?.getTransformTo(null)?.getTranslation();
    if (translation != null && renderObject.paintBounds != null) {
      return renderObject.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}
