import 'package:flutter/material.dart';

class ChapterNavigator extends StatelessWidget {
  final bool show;
  final String chapterName;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTitleTap; // Thêm callback để mở danh sách chương
  final bool isFavorite;

  const ChapterNavigator({
    super.key,
    required this.show,
    required this.chapterName,
    required this.onPrev,
    required this.onNext,
    required this.onFavoriteTap,
    required this.onTitleTap, // Thêm vào constructor
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart, // Đã sửa lỗi blockless
      bottom: show ? 20 : -100,
      left: 15,
      right: 85, // Chừa chỗ cho nút đỏ cách vài pixel
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withOpacity(0.95),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: onPrev,
            ),
            Expanded(
              child: InkWell(
                onTap: onTitleTap, // Bấm vào vùng tên chương
                borderRadius: BorderRadius.circular(10),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        chapterName,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        "Chạm để đổi chương",
                        style: TextStyle(color: Colors.white38, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
              onPressed: onNext,
            ),
            const VerticalDivider(color: Colors.white10, indent: 15, endIndent: 15),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.redAccent : Colors.white70,
              ),
              onPressed: onFavoriteTap,
            ),
          ],
        ),
      ),
    );
  }
}