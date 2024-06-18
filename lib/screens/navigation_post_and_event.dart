import 'package:flutter/material.dart';
import 'package:wip/screens/add_event_screen.dart';
import 'package:wip/screens/add_post_screen.dart';

class NavigatorEP extends StatefulWidget {
  const NavigatorEP({Key? key});

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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _pages.elementAt(_selectedIndex),
        ),
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
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 55,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 157, 33, 201), // Cor base do gradiente
                Color.fromARGB(255, 187, 53, 221), // Tom mais claro
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, -3),
                blurRadius: 8,
              ),
            ],
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
              color: isSelected ? Colors.white : Colors.white70,
              size: 25,
            ),
            child: item.icon,
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          Text(
            item.label ?? '',
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

