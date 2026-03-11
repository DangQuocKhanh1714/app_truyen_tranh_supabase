abstract class UserEvent {}

// Gọi khi vào màn hình Lịch sử hoặc Yêu thích
class LoadUserDataEvent extends UserEvent {}

// Gọi khi người dùng nhấn nút xóa lịch sử
class RemoveHistoryEvent extends UserEvent {
  final int mangaId;
  RemoveHistoryEvent(this.mangaId);
}