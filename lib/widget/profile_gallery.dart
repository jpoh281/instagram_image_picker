import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:instagramimagepicker/model/gallery_image.dart';

class ProfileGallery extends StatefulWidget {
  @override
  _ProfileGalleryState createState() => _ProfileGalleryState();
}

class _ProfileGalleryState extends State<ProfileGallery> {
  final _channel = MethodChannel("/gallery");
  Future<int> number;
  int _numberOfItems;
  var _itemCache = Map<int, GalleryImage>();
  int _nowIndex = 0;
  String _nowFilePath;
  Future<String> nowImage;

  //스크롤 컨트롤러
  final _scrollController = ScrollController(
    keepScrollOffset: true,
  );

  GlobalKey _globalKey = new GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    number = _channel.invokeMethod<int>("getItemCount");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("갤러리"),
        actions: [FlatButton(onPressed: () {}, child: Text("선택"))],
      ),
      body: FutureBuilder(
        future: number,
        builder: (context, snapshot) {
          _numberOfItems = snapshot.data;
          if (snapshot.hasData) {
            return Column(
              children: <Widget>[
                SizedBox(
                    width: Get.width,
                    height: Get.width,
                    child: FutureBuilder(
                        future: nowImage = _getBigItem(_nowIndex),
                        builder: (context, snapshot) {
                          print(snapshot.data);
                          if (snapshot.hasData)
                            return Image.file(
                              File(snapshot.data),
                              fit: BoxFit.cover,
                            );
                          return Center(child: CircularProgressIndicator());
                        })),
                Expanded(
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4),
                        itemCount: _numberOfItems,
                        itemBuilder: (context, index) {
                          return _buildItem(index);
                        }))
              ],
            );
          }
          return Center(child: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }

  _buildItem(int index) => GestureDetector(
      onTap: () {
        setState(() {
          _nowIndex = index;
          _nowFilePath = _itemCache[_nowIndex].path;
        });
      },
      child: FutureBuilder(
          future: _getItem(index),
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
  Future<String> _getBigItem(int index) async {
    var url =
        await _channel.invokeMethod("getThumbnail", _numberOfItems - (index));
    print(url);
    return url;
  }

  Future<GalleryImage> _getItem(int index) async {
    // TODO: fetch gallery content here
    // 1
    if (_itemCache[index] != null) {
      return _itemCache[index];
    } else {
      // 2
      var channelResponse = await _channel.invokeMethod(
          "getMiniThumbnail", _numberOfItems - (1 + index));

      // 3
      var item = Map<String, dynamic>.from(channelResponse);

      // 4
      var galleryImage = GalleryImage(
          bytes: item['data'],
          id: item['id'],
          dateCreated: item['created'],
          location: item['location'],
          path: item['path']);

      // 5
      _itemCache[index] = galleryImage;

      // 6
      return galleryImage;
    }
  }
}
