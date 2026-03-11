import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import 'home_screen.dart'; 
import 'favorite_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Khai báo danh sách các màn hình dưới dạng hằng số
  final List<Widget> _screens = const [
    HomeScreen(),      
    FavoriteScreen(),  
    HistoryScreen(),   
    ProfileScreen(),   
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack giúp chuyển tab mà không hủy (dispose) màn hình cũ
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}