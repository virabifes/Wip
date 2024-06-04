import 'package:flutter/material.dart';
import 'package:wip/screens/add_event_screen.dart';
import 'package:wip/screens/add_post_screen.dart';

class NavigatorEP extends StatefulWidget {
  const NavigatorEP({super.key});

  @override
  _NavigatorEPState createState() => _NavigatorEPState();
}

class _NavigatorEPState extends State<NavigatorEP> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const AddPostScreen(),
    const AddEventScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: GradientBottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera),
            label: 'Criar Publicação',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Criar Eventos',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class GradientBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  const GradientBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 60,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 157, 33, 201),
                Colors.deepPurple,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().map((index, item) {
              return MapEntry(
                index,
                _buildNavItem(item, index == currentIndex, () => onTap(index)),
              );
            }).values.toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(BottomNavigationBarItem item, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTheme(
            data: IconThemeData(
              color: isSelected ? Colors.white : Colors.white54,
            ),
            child: item.icon,
          ),
          Text(
            item.label ?? '',
            style: TextStyle(color: isSelected ? Colors.white : Colors.white54),
          )
        ],
      ),
    );
  }
}
