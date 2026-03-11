import 'package:app_truyen_tranh/logic/category_bloc/category_bloc.dart';
import 'package:app_truyen_tranh/logic/favorite_bloc/favorite_bloc.dart';
import 'package:app_truyen_tranh/logic/history_bloc/history_bloc.dart';
import 'package:app_truyen_tranh/logic/search_bloc/search_bloc.dart';
import 'package:app_truyen_tranh/logic/user_bloc/user_bloc.dart'; // Import thêm UserBloc nếu bạn có
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import Core (Theme & State)
import 'core/app_theme.dart';

// Import Data Layer
import 'data/services/database_helper.dart';
import 'data/services/auth_service.dart';

// Import Logic Layer
import 'logic/manga_bloc/manga_bloc.dart';
import 'logic/auth_bloc/auth_bloc.dart';
import 'logic/auth_bloc/auth_event.dart';
import 'logic/theme_bloc/theme_bloc.dart'; // Bloc mới

// Import Presentation Layer
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. KẾT NỐI FIREBASE
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. KẾT NỐI SUPABASE
  await Supabase.initialize(
    url: 'https://qrglfjigwloawrxjkfei.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFyZ2xmamlnd2xvYXdyeGprZmVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA0MDE1MzUsImV4cCI6MjA4NTk3NzUzNX0.ioQkBSAEqixzb7dr_5_80yQ5FhtxzWqDqbchN3BmBog',
  );

  // 3. KHỞI TẠO SERVICES
  final authService = AuthService();
  final dbHelper = DatabaseHelper();

  runApp(MyApp(authService: authService, dbHelper: dbHelper));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final DatabaseHelper dbHelper;

  const MyApp({super.key, required this.authService, required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ThemeBloc: Quản lý chế độ Sáng/Tối toàn App
        BlocProvider<ThemeBloc>(create: (context) => ThemeBloc()),

        // AuthBloc: Quản lý trạng thái đăng nhập
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authService)..add(AuthCheckRequested()),
        ),

        // MangaBloc: Quản lý danh sách truyện trang chủ
        BlocProvider<MangaBloc>(
          create: (context) => MangaBloc(dbHelper)..add(LoadMangaEvent()),
        ),

        // Các Bloc hỗ trợ dữ liệu người dùng
        BlocProvider<HistoryBloc>(create: (context) => HistoryBloc(dbHelper)),

        BlocProvider<FavoriteBloc>(create: (context) => FavoriteBloc(dbHelper)),

        // Bloc quản lý Profile và các dữ liệu tổng hợp của User
        BlocProvider<UserBloc>(create: (context) => UserBloc(dbHelper)),
        BlocProvider(create: (context) => CategoryBloc(DatabaseHelper())),

        BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(dbHelper),
        ),
      ],
      // Sử dụng BlocBuilder để bọc MaterialApp, giúp App đổi màu ngay khi nhấn nút bóng đèn
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, mode) {
          return MaterialApp(
            title: 'Manga App',
            debugShowCheckedModeBanner: false,
            themeMode: mode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,

            // THÊM 2 DÒNG NÀY:
            themeAnimationDuration: const Duration(
              milliseconds: 50,
            ), // Gần như lập tức
            themeAnimationCurve: Curves.linear, // Chạy đường thẳng cho nhanh

            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
