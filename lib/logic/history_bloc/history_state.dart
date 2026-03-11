import 'package:equatable/equatable.dart';
import '../../data/models/history_model.dart';

abstract class HistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}
class HistoryLoading extends HistoryState {}
class HistoryLoaded extends HistoryState {
  final List<HistoryModel> historyList;
  HistoryLoaded(this.historyList);
  @override
  List<Object?> get props => [historyList];
}
class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}