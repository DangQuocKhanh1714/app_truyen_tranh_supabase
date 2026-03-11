import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/database_helper.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final DatabaseHelper dbHelper;

  HistoryBloc(this.dbHelper) : super(HistoryInitial()) {
    on<LoadHistoryEvent>((event, emit) async {
      emit(HistoryLoading());
      try {
        final history = await dbHelper.fetchHistory();
        emit(HistoryLoaded(history));
      } catch (e) {
        emit(HistoryError(e.toString()));
      }
    });
  }
}