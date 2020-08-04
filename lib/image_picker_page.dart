import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagramimagepicker/widget/profile_camera.dart';
import 'package:instagramimagepicker/widget/profile_gallery.dart';

class ImagePickerPage extends StatefulWidget {
  @override
  _ImagePickerPageState createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  // 페이지 관련
  int _selectedIndex = 0;
  var _pageController = PageController(initialPage: 0);
  // 갤러리 관련
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: <Widget>[
            ProfileGallery(),
            ProfileCamera(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          iconSize: 0,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedItemColor: Colors.grey[400],
          selectedItemColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.crop_original), title: Text('갤러리')),
            BottomNavigationBarItem(
                icon: Icon(Icons.photo_camera), title: Text('카메라')),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _pageController.animateToPage(index,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut);
              _selectedIndex = index;
            });
          }),
    );
  }
}
