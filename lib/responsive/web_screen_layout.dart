import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wip/utils/colors.dart';
import 'package:wip/utils/global_variable.dart';

class WebScreenLayout extends StatefulWidget {
  const WebScreenLayout({super.key});

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
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
    // Using animateToPage for smoother transitions
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300), // Faster animation for a snappier feel
      curve: Curves.easeInOut, // Smooth in/out for better visual effect
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: SvgPicture.asset(
          'assets/logoWip.svg',
          // ignore: deprecated_member_use
          color: Color.fromARGB(255, 0, 0, 0),
          height: 32,
        ),
        actions: _buildAppBarActions(),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(), // Prevents horizontal scrolling
        controller: pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),
    );
  }

  // Extracting AppBar actions to a method for cleaner code
  List<Widget> _buildAppBarActions() {
    List<IconData> icons = [
      Icons.home,
      Icons.search,
      Icons.add_a_photo,
      Icons.favorite,
      Icons.person,
    ];

    return List<Widget>.generate(icons.length, (index) => IconButton(
      icon: Icon(
        icons[index],
        color: _page == index ? primaryColor : primaryColor1,
      ),
      onPressed: () => navigationTapped(index),
      tooltip: _tooltipText(index), // Adding tooltips for better UX
    ));
  }

  // Helper function to provide tooltips
  String _tooltipText(int index) {
    switch (index) {
      case 0: return 'Home';
      case 1: return 'Search';
      case 2: return 'Add Photo';
      case 3: return 'Favorites';
      case 4: return 'Profile';
      default: return '';
    }
  }
}
