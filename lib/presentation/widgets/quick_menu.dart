// lib/presentation/widgets/quick_menu.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class QuickMenu extends StatelessWidget {
  final bool show;
  final VoidCallback onHomeTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onProfileTap;
  final VoidCallback onCloseTap; // Nút đóng để ẩn menu

  const QuickMenu({
    super.key,
    required this.show,
    required this.onHomeTap,
    required this.onFavoriteTap,
    required this.onHistoryTap,
    required this.onProfileTap,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      bottom: show ? 0 : -110,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 105,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.92),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Expanded(child: _buildItem(Icons.home_rounded, "Trang chủ", onHomeTap)),
                Expanded(child: _buildItem(Icons.favorite_rounded, "Yêu thích", onFavoriteTap)),
                Expanded(child: _buildItem(Icons.history_rounded, "Lịch sử", onHistoryTap)),
                Expanded(child: _buildItem(Icons.person_rounded, "Tài khoản", onProfileTap)),
                
                // NÚT X NẰM TRONG MÀU XÁM (image_11ac17.png)
                Container(
                  width: 70,
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 28),
                    onPressed: onCloseTap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}