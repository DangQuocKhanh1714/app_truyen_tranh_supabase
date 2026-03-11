import 'package:app_truyen_tranh/data/models/history_model.dart';
import 'package:app_truyen_tranh/data/models/manga_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseHelper {
  final _supabase = Supabase.instance.client;

  // --- AUTHENTICATION HELPERS ---

  // Kiểm tra trạng thái qua Firebase
  bool get isUserLoggedIn => fb.FirebaseAuth.instance.currentUser != null;

  // Lấy ID người dùng từ Firebase
  String? get currentUserId => fb.FirebaseAuth.instance.currentUser?.uid;

  // Stream lắng nghe Firebase thay vì Supabase
  Stream<fb.User?> get authStateStream =>
      fb.FirebaseAuth.instance.authStateChanges();

  // --- MANGA DATA ---

  // 1. Lấy danh sách truyện KÈM chương mới nhất
  Future<List<Map<String, dynamic>>> fetchMangas() async {
    try {
      final response = await _supabase
          .from('mangas')
          .select('''
            *,
            chapters(chapter_name, id) 
          ''')
          .order('id', ascending: true)
          .order('id', referencedTable: 'chapters', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Lỗi lấy dữ liệu: $e');
    }
  }

  // 2. Lấy danh sách chương
  Future<List<Map<String, dynamic>>> fetchChapters(int mangaId) async {
    try {
      return await _supabase
          .from('chapters')
          .select()
          .eq('manga_id', mangaId)
          .order('id', ascending: false);
    } catch (e) {
      return [];
    }
  }

  // 3. Lấy thể loại truyện
  Future<List<String>> fetchMangaCategories(int mangaId) async {
    try {
      final response = await _supabase
          .from('manga_categories')
          .select('categories!inner(name)')
          .eq('manga_id', mangaId);
      final List data = response as List;
      return data.map((item) => item['categories']['name'].toString()).toList();
    } catch (e) {
      return [];
    }
  }

  // 4. Lọc truyện theo thể loại
  Future<List<MangaModel>> fetchMangasByCategory(String categoryName) async {
    try {
      final response = await _supabase
          .from('mangas')
          .select(
            '*, chapters(chapter_name, id), manga_categories!inner(categories!inner(name))',
          )
          .eq('manga_categories.categories.name', categoryName)
          .order('id', referencedTable: 'chapters', ascending: false);
      final List data = response as List;
      return data.map((mangaMap) => MangaModel.fromMap(mangaMap)).toList();
    } catch (e) {
      return [];
    }
  }

  // --- HISTORY (LỊCH SỬ) ---

  // 5. Lưu lịch sử (Dùng currentUserId từ Firebase)
  Future<void> saveHistory(int mangaId, int chapterId) async {
    final userId = currentUserId;
    if (userId == null) return;
    try {
      // Sử dụng upsert với onConflict để cập nhật nếu đã tồn tại
      await _supabase.from('history').upsert(
        {
          'user_id': userId,
          'manga_id': mangaId,
          'last_chapter_id': chapterId,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict:
            'user_id, manga_id', // Phải đảm bảo trên Supabase cặp này là Unique
      );
    } catch (e) {
      print('Lỗi lưu lịch sử: $e');
    }
  }

  // 6. Lấy lịch sử (Dùng currentUserId từ Firebase)
  Future<List<HistoryModel>> fetchHistory() async {
    final userId = currentUserId;
    if (userId == null) return [];
    try {
      // Join bảng để lấy thông tin truyện và tên chương
      final response = await _supabase
          .from('history')
          .select('*, mangas(*), chapters(chapter_name)')
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      return (response as List)
          .map((item) => HistoryModel.fromMap(item))
          .toList();
    } catch (e) {
      print('Lỗi lấy lịch sử: $e');
      return [];
    }
  }

  // --- FAVORITES (YÊU THÍCH) ---

  // 7. Lấy danh sách truyện yêu thích (Đã sửa lỗi không hiện dữ liệu)
  Future<List<MangaModel>> fetchFavorites() async {
    final userId = currentUserId;
    if (userId == null) return [];
    try {
      final response = await _supabase
          .from('favorites')
          .select('''
            manga_id,
            mangas (
              *,
              chapters (chapter_name, id)
            )
          ''')
          .eq('user_id', userId)
          // QUAN TRỌNG: Sắp xếp chương theo ID giảm dần để chương mới nhất nằm ở vị trí [0]
          .order('id', referencedTable: 'mangas.chapters', ascending: false);

      if ((response as List).isEmpty) return [];

      final List data = response as List;
      List<MangaModel> favoriteList = [];

      for (var item in data) {
        if (item['mangas'] != null) {
          try {
            final mangaMap = item['mangas'] as Map<String, dynamic>;
            favoriteList.add(MangaModel.fromMap(mangaMap));
          } catch (e) {
            print("Lỗi map từng truyện: $e");
          }
        }
      }
      return favoriteList;
    } catch (e) {
      print('Lỗi fetchFavorites: $e');
      throw Exception("Lỗi kết nối dữ liệu yêu thích");
    }
  }

  // 8. Thêm hoặc xóa yêu thích (Để sửa lỗi image_fd0e57.png)
  Future<void> toggleFavorite(int mangaId) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      // Kiểm tra xem đã tồn tại bản ghi chưa
      final existing = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('manga_id', mangaId)
          .maybeSingle();

      if (existing != null) {
        // Nếu đã yêu thích rồi thì xóa đi
        await _supabase
            .from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('manga_id', mangaId);
      } else {
        // Nếu chưa thì thêm mới vào bảng favorites
        await _supabase.from('favorites').insert({
          'user_id': userId,
          'manga_id': mangaId,
        });
      }
    } catch (e) {
      print('Lỗi thực hiện toggleFavorite: $e');
    }
  }

  // 9. Kiểm tra xem 1 truyện cụ thể có đang được yêu thích không
  Future<bool> isFavorite(int mangaId) async {
    final userId = currentUserId;
    if (userId == null) return false;
    try {
      final res = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('manga_id', mangaId)
          .maybeSingle();
      return res != null;
    } catch (e) {
      return false;
    }
  }

  // Thêm vào DatabaseHelper để hết lỗi đỏ trong UserBloc
  Future<void> deleteHistory(int mangaId) async {
    final userId = currentUserId;
    if (userId == null) return;
    try {
      await _supabase
          .from('history')
          .delete()
          .eq('user_id', userId)
          .eq('manga_id', mangaId);
    } catch (e) {
      print('Lỗi xóa lịch sử: $e');
    }
  }

  final supabase = Supabase.instance.client;

  Future<List<String>> fetchCategories() async {
    try {
      // Sử dụng đúng tên biến 'supabase' vừa khai báo ở trên
      final response = await supabase.from('categories').select('name');
      return (response as List).map((item) => item['name'] as String).toList();
    } catch (e) {
      print("Lỗi fetchCategories: $e");
      return [];
    }
  }

  // Hàm tìm kiếm truyện
  Future<List<MangaModel>> searchMangas(String query) async {
    try {
      if (query.trim().isEmpty) return [];
      
      // Sử dụng ilike để tìm kiếm không phân biệt hoa thường
      final response = await _supabase
          .from('mangas')
          .select('*, chapters(chapter_name, id)')
          .ilike('title', '%$query%') 
          .order('id', ascending: true)
          .limit(15);

      final List data = response as List;
      return data.map((mangaMap) => MangaModel.fromMap(mangaMap)).toList();
    } catch (e) {
      print('Lỗi thực thi tìm kiếm: $e');
      return [];
    }
  }

  // Tìm chương tiếp theo hoặc trước đó
  Future<Map<String, dynamic>?> getAdjacentChapter(int mangaId, int currentChapterId, {required bool next}) async {
    try {
      final response = await _supabase
          .from('chapters')
          .select()
          .eq('manga_id', mangaId)
          .order('id', ascending: true); // Sắp xếp theo ID tăng dần

      final chapters = List<Map<String, dynamic>>.from(response);
      final currentIndex = chapters.indexWhere((ch) => ch['id'] == currentChapterId);

      if (next && currentIndex < chapters.length - 1) {
        return chapters[currentIndex + 1]; // Chương sau
      } else if (!next && currentIndex > 0) {
        return chapters[currentIndex - 1]; // Chương trước
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
