import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  // Mặc định ban đầu là Dark Mode (Tối)
  ThemeBloc() : super(ThemeMode.dark) {
    on<ToggleThemeEvent>((event, emit) {
      // Nếu đang tối thì đổi sang sáng, và ngược lại
      if (state == ThemeMode.dark) {
        emit(ThemeMode.light);
      } else {
        emit(ThemeMode.dark);
      }
    });
  }
}