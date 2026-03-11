import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth_bloc/auth_bloc.dart';
import '../../logic/auth_bloc/auth_state.dart';
import '../../logic/history_bloc/history_bloc.dart';
import '../../logic/history_bloc/history_event.dart';
import '../../logic/history_bloc/history_state.dart';
import '../../presentation/widgets/manga_card.dart';
import '../../core/app_state.dart';
import '../widgets/custom_app_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<HistoryBloc>().add(LoadHistoryEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            return BlocConsumer<HistoryBloc, HistoryState>(
              listener: (context, historyState) {
                if (historyState is HistoryError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi: ${historyState.message}")),
                  );
                }
              },
              builder: (context, historyState) {
                if (historyState is HistoryLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                }

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      backgroundColor: const Color(0xFFFF5252),
                      expandedHeight: 65,
                      flexibleSpace: const CustomAppBar(),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 20)),

                    if (historyState is HistoryLoaded) ...[
                      if (historyState.historyList.isEmpty)
                        const SliverFillRemaining(
                          child: Center(child: Text("Chưa có lịch sử đọc", style: TextStyle(color: Colors.grey))),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 20,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final history = historyState.historyList[index];
                                if (history.manga == null) return const SizedBox.shrink();
                                return MangaCard(
                                  manga: history.manga!,
                                  customSubtitle: history.lastChapterName ?? "Đang đọc...",
                                );
                              },
                              childCount: historyState.historyList.length,
                            ),
                          ),
                        ),
                    ],
                  ],
                );
              },
            );
          }
          return _buildLoginNotice(context, "Lịch sử");
        },
      ),
    );
  }

  Widget _buildLoginNotice(BuildContext context, String feature) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text("Vui lòng đăng nhập để sử dụng\nchức năng $feature", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => AppState.changeTab(3, context),
            child: const Text("Đăng nhập ngay"),
          ),
        ],
      ),
    );
  }
}