import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For using SystemUiOverlayStyle
import 'package:wip/utils/colors.dart';
import 'package:wip/utils/global_variable.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    // This line helps maintain the system UI overlay style, useful for dark/light themes
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent, // iOS style status bar color
    ));

    return Scaffold(
      body: SafeArea(  // Ensuring content is within the safe area
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: PageView(
            controller: pageController,
            onPageChanged: onPageChanged,
            children: homeScreenItems,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(  // Important for devices with a notch or home gesture bar
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            color: mobileBackgroundColor,
          ),
          child: CupertinoTabBar(
            backgroundColor: Colors.transparent,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.home,
                  color: (_page == 0) ? primaryColor : primaryColor1,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.search,
                  color: (_page == 1) ? primaryColor : primaryColor1,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.add_circled,
                  color: (_page == 2) ? primaryColor : primaryColor1,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.heart,
                  color: (_page == 3) ? primaryColor : primaryColor1,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.person,
                  color: (_page == 4) ? primaryColor : primaryColor1,
                ),
                label: '',
              ),
            ],
            onTap: navigationTapped,
            currentIndex: _page,
          ),
        ),
      ),
    );
  }
}
