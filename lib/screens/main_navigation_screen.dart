import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../screens/calendar/calendar_screen.dart'; // Ganti 'myapp'
import '../../screens/home/home_screen.dart';       // Ganti 'myapp'
import '../../screens/class/class_list_screen.dart';// Ganti 'myapp'
import '../../screens/profile/profile_screen.dart'; // Ganti 'myapp'
import '../../utils/app_routes.dart';               // Ganti 'myapp'

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // State untuk melacak indeks halaman yang sedang aktif
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CalendarScreen(),
    // Indeks 2 untuk tombol '+' akan ditangani secara khusus
    SizedBox.shrink(), // Placeholder kosong
    ClassListScreen(), // DIGANTI: dari NotesListScreen ke ClassListScreen
    ProfileScreen(),
  ];

  // Fungsi untuk menangani saat item navigasi ditekan
  void _onItemTapped(int index) {
    // Tombol '+' (indeks 2) akan ditangani secara khusus
    if (index == 2) {
      _showAddTaskPopup();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi untuk menampilkan pop-up "Add Task" atau "Note"
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
                Get.back(); // Tutup bottom sheet
                Get.toNamed(AppRoutes.taskForm); // Navigasi ke halaman form tugas
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[100],
                  padding: const EdgeInsets.symmetric(vertical: 15)),
              child: const Text('Add Task', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                 Get.back(); // Tutup bottom sheet
                 Get.toNamed(AppRoutes.noteForm); // Navigasi ke halaman form catatan
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
      // Tampilkan halaman yang sesuai dengan indeks yang dipilih
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // Definisikan Bottom Navigation Bar
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
          // PERUBAHAN DI SINI
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
        // Kustomisasi warna
        selectedItemColor: Colors.deepPurple[400], // Warna ikon & label saat aktif
        unselectedItemColor: Colors.grey[600],   // Warna ikon & label saat tidak aktif
        onTap: _onItemTapped,
        // Konfigurasi tambahan agar label selalu terlihat dan tidak ada efek geser
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
