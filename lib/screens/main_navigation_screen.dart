import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../screens/calendar/calendar_screen.dart'; 
import '../../screens/home/home_screen.dart';       
import '../../screens/class/class_list_screen.dart';
import '../../screens/profile/profile_screen.dart'; 
import '../../utils/app_routes.dart';               

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CalendarScreen(),
    SizedBox.shrink(), 
    ClassListScreen(), 
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _showAddTaskPopup();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }
  void _showAddTaskPopup() {
    Get.bottomSheet(
      Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.back(); 
                Get.toNamed(AppRoutes.taskForm); 
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[100],
                  padding: const EdgeInsets.symmetric(vertical: 15)),
              child: const Text('Add Task', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                 Get.back(); 
                 Get.toNamed(AppRoutes.noteForm); 
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[100],
                  padding: const EdgeInsets.symmetric(vertical: 15)),
              child: const Text('Note', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Class',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple[400], 
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
