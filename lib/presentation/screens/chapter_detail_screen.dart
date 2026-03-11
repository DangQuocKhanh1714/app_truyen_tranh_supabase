import 'package:app_truyen_tranh/core/app_state.dart';
import 'package:app_truyen_tranh/core/constants.dart'; // Đảm bảo đã khai báo maxContentWidth = 600
import 'package:app_truyen_tranh/data/services/database_helper.dart';
import 'package:app_truyen_tranh/logic/favorite_bloc/favorite_bloc.dart';
import 'package:app_truyen_tranh/logic/favorite_bloc/favorite_event.dart';
import 'package:app_truyen_tranh/logic/history_bloc/history_bloc.dart';
import 'package:app_truyen_tranh/logic/history_bloc/history_event.dart';
import 'package:app_truyen_tranh/presentation/widgets/chapter_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/chapter_model.dart';
import '../widgets/quick_menu.dart';

class ChapterDetailScreen extends StatefulWidget {
  final ChapterModel chapter;
  const ChapterDetailScreen({super.key, required this.chapter});

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final supabase = Supabase.instance.client;

  bool _showUI = false;         
  bool _showQuickMenu = false;   
  bool _showBackToTop = false;
  bool _isFavorite = false;      
  List<ChapterModel> _allChapters = []; 

  @override
  void initState() {
    super.initState();
    _loadAllChapters();
    _checkFavoriteStatus();
    
    _scrollController.addListener(() {
      if (_scrollController.offset > 1000 && !_showBackToTop) {
        setState(() => _showBackToTop = true);
      } else if (_scrollController.offset <= 1000 && _showBackToTop) {
        setState(() => _showBackToTop = false);
      }
    });
  }

  Future<void> _checkFavoriteStatus() async {
    bool status = await _dbHelper.isFavorite(widget.chapter.mangaId);
    if (mounted) {
      setState(() => _isFavorite = status);
    }
  }

  Future<void> _loadAllChapters() async {
    try {
      final response = await supabase
          .from('chapters')
          .select()
          .eq('manga_id', widget.chapter.mangaId)
          .order('id', ascending: true);

      if (mounted) {
        setState(() {
          _allChapters = (response as List)
              .map((map) => ChapterModel.fromMap(map))
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải danh sách chương: $e");
    }
  }

  void _navigateToChapter(int direction) {
    int currentIndex = _allChapters.indexWhere((ch) => ch.id == widget.chapter.id);
    int nextIndex = currentIndex + direction;

    if (nextIndex >= 0 && nextIndex < _allChapters.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChapterDetailScreen(chapter: _allChapters[nextIndex]),
        ),
      );
    } else {
      _showSimpleSnackBar(direction > 0 ? "Đây đã là chương cuối" : "Đây là chương đầu tiên");
    }
  }

  void _showSimpleSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  void _showChapterList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Danh sách chương", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const Divider(color: Colors.white10, height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _allChapters.length,
                    itemBuilder: (context, index) {
                      final chapter = _allChapters[index];
                      bool isCurrent = chapter.id == widget.chapter.id;
                      return ListTile(
                        leading: Text("${index + 1}", style: TextStyle(color: isCurrent ? Colors.redAccent : Colors.white38)),
                        title: Text(chapter.chapterName, style: TextStyle(color: isCurrent ? Colors.redAccent : Colors.white70)),
                        trailing: isCurrent ? const Icon(Icons.import_contacts, color: Colors.redAccent, size: 18) : null,
                        onTap: () {
                          Navigator.pop(context);
                          if (!isCurrent) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => ChapterDetailScreen(chapter: chapter)),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, true);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        // DÙNG CENTER VÀ CONSTRAINEDBOX ĐỂ KHÓA ĐỘ RỘNG MÀN HÌNH WEB
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
            child: Stack(
              children: [
                // NỘI DUNG TRUYỆN
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showUI = !_showUI;
                      if (!_showUI) _showQuickMenu = false; 
                    });
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    itemCount: widget.chapter.contentImages.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.chapter.contentImages[index],
                        fit: BoxFit.contain, // Đảm bảo ảnh không bị méo tỷ lệ
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 600,
                            color: Colors.white.withOpacity(0.02),
                            child: const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
                          );
                        },
                      );
                    },
                  ),
                ),

                // NÚT QUAY LẠI (BACK)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ),
                ),

                // THANH ĐIỀU HƯỚNG CHƯƠNG (BOTTOM BAR)
                ChapterNavigator(
                  show: _showUI,
                  chapterName: widget.chapter.chapterName,
                  isFavorite: _isFavorite,
                  onPrev: () => _navigateToChapter(-1),
                  onNext: () => _navigateToChapter(1),
                  onTitleTap: _showChapterList,
                  onFavoriteTap: () async {
                    HapticFeedback.lightImpact();
                    await _dbHelper.toggleFavorite(widget.chapter.mangaId);
                    setState(() => _isFavorite = !_isFavorite);
                    if (mounted) {
                      _showSimpleSnackBar(_isFavorite ? "Đã thêm vào yêu thích!" : "Đã xóa khỏi yêu thích");
                    }
                  },
                ),

                // QUICK MENU (MENU NHANH)
                QuickMenu(
                  show: _showQuickMenu,
                  onHomeTap: () {
                    Navigator.pop(context, true); 
                    AppState.changeTab(0, context);
                  },
                  onFavoriteTap: () {
                    context.read<FavoriteBloc>().add(LoadFavoritesEvent());
                    Navigator.pop(context, true);
                    AppState.changeTab(1, context);
                  },
                  onHistoryTap: () {
                    context.read<HistoryBloc>().add(LoadHistoryEvent());
                    Navigator.pop(context, true);
                    AppState.changeTab(2, context);
                  },
                  onProfileTap: () {
                    Navigator.pop(context, true);
                    AppState.changeTab(3, context);
                  },
                  onCloseTap: () => setState(() => _showQuickMenu = false),
                ),

                // NÚT MỞ QUICK MENU (FAB)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutQuart,
                  // Tự động nhảy lên trên khi ChapterNavigator xuất hiện
                  bottom: _showQuickMenu ? -100 : (_showUI ? 110 : -100),
                  right: 20,
                  child: FloatingActionButton(
                    heroTag: "chapter_menu",
                    backgroundColor: Colors.redAccent,
                    mini: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    onPressed: () => setState(() => _showQuickMenu = true),
                    child: const Icon(Icons.menu_open_rounded, color: Colors.white),
                  ),
                ),

                // NÚT CUỘN LÊN ĐẦU (BACK TO TOP)
                if (_showBackToTop && !_showUI)
                  Positioned(
                    bottom: 30,
                    right: 20,
                    child: FloatingActionButton(
                      mini: true,
                      heroTag: "btnTop",
                      backgroundColor: Colors.redAccent.withOpacity(0.8),
                      onPressed: () => _scrollController.animateTo(0, 
                        duration: const Duration(milliseconds: 500), 
                        curve: Curves.easeOut),
                      child: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}