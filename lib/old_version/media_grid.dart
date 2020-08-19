//import 'package:flutter/material.dart';
//import 'package:photo_manager/photo_manager.dart';
//
//class MediaGrid extends StatefulWidget {
//  @override
//  _MediaGridState createState() => _MediaGridState();
//}
//
//class _MediaGridState extends State<MediaGrid> {
//  int currentAlbum = 0;
//  int currentPage = 0;
//  int lastPage;
//  bool isFirst = true;
//  List<Widget> _mediaList = [];
//  List<AssetPathEntity> albums;
//  List<AssetEntity> images;
//  @override
//  void initState() {
//    super.initState();
//    fetchNewMedia();
//  }
//
//  _handleScrollEvent(ScrollNotification scroll) {
//    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.60) {
//      if (currentPage != lastPage) {
//        if (currentAlbum < albums.length) fetchNewMedia();
//      }
//    }
//  }
//
//  fetchNewMedia() async {
//    lastPage = currentPage;
//
//    if (isFirst) {
//      albums = await PhotoManager.getAssetPathList(
//          hasAll: true, type: RequestType.image);
//      isFirst = false;
//    }
//    images = await albums[currentAlbum].getAssetListPaged(currentPage, 60);
//    print(albums[currentAlbum].name);
//    List<Widget> temp = [];
//    for (var asset in images) {
//      temp.add(
//        FutureBuilder(
//          future: asset.thumbDataWithSize(200, 200),
//          builder: (BuildContext context, snapshot) {
//            if (snapshot.connectionState == ConnectionState.done)
//              return GestureDetector(
//                onTap: () {
//                  print("이이이잉");
//                },
//                child: Container(
//                    decoration: BoxDecoration(
//                  border: Border.all(color: Colors.black, width: 1),
//                  image: DecorationImage(
//                      image: MemoryImage(snapshot.data), fit: BoxFit.cover),
//                )),
//              );
//            return Container();
//          },
//        ),
//      );
//    }
//    setState(() {
//      _mediaList.addAll(temp);
//
//      if (currentPage * 60 < albums[currentAlbum].assetCount)
//        currentPage++;
//      else {
//        currentAlbum++;
//        currentPage = 0;
//      }
//      print(_mediaList.length);
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return NotificationListener<ScrollNotification>(
//      onNotification: (ScrollNotification scroll) {
//        _handleScrollEvent(scroll);
//        return;
//      },
//      child: GridView.builder(
//          itemCount: _mediaList.length,
//          gridDelegate:
//              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
//          itemBuilder: (BuildContext context, int index) {
//            return _mediaList[index];
//          }),
//    );
//  }
//
//  List<DropdownMenuItem> getItems() {
//    return albums
//            .map((e) => DropdownMenuItem(
//                  child: Text(
//                    e.name,
//                    style: TextStyle(color: Colors.black),
//                    overflow: TextOverflow.clip,
//                  ),
//                  value: e,
//                ))
//            .toList() ??
//        [];
//  }
//}
