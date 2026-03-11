import 'package:flutter/material.dart';

class AppState {
  // Quản lý index của BottomNavigationBar toàn ứng dụng
  static final ValueNotifier<int> navigationIndex = ValueNotifier<int>(0);

  // Hàm tiện ích: Đổi tab và quay về màn hình gốc (Home)
  static void changeTab(int index, BuildContext context) {
    navigationIndex.value = index;
    // Xóa tất cả các màn hình detail đang đè lên để về lại HomeScreen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}