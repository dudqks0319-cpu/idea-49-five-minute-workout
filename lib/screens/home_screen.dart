import 'package:flutter/material.dart';

import '../models/energy_task.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/task_editor_screen.dart';
import '../widgets/energy_summary_card.dart';
import '../widgets/energy_task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.authProvider,
    required this.taskProvider,
  });

  final AuthProvider authProvider;
  final TaskProvider taskProvider;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.taskProvider.refresh();
  }

  Future<void> _openEditor({EnergyTask? existing}) async {
    final task = await Navigator.of(context).push<EnergyTask>(
      MaterialPageRoute(
        builder: (_) => TaskEditorScreen(
          taskId: existing?.id ?? widget.taskProvider.service.newTaskId(),
          existing: existing,
        ),
      ),
    );

    if (task == null) return;
    await widget.taskProvider.save(task);
  }

  Widget _buildRecommendTab() {
    final provider = widget.taskProvider;
    final recommended = provider.recommendedTasks;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('5분 홈트 루틴', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('현재 에너지 수준에 맞춰 실행 가능한 작업을 우선 추천합니다.'),
                SizedBox(height: 4),
                Text('실동작: 로그인/DB 저장/조회/수정/삭제/에러처리'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        EnergySummaryCard(
          currentEnergyLevel: provider.currentEnergyLevel,
          totalFocusMinutes: provider.totalFocusMinutes,
          completedFocusMinutes: provider.completedFocusMinutes,
          onEnergyChanged: provider.setCurrentEnergyLevel,
        ),
        const SizedBox(height: 8),
        if (provider.loading)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (provider.error != null)
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text('오류: ${provider.error}'),
            ),
          )
        else if (recommended.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text('현재 에너지 수준에 맞는 추천 작업이 없습니다. 새 작업을 추가해 보세요.'),
            ),
          )
        else
          ...recommended.map(
            (task) => EnergyTaskTile(
              task: task,
              onToggleDone: (done) => provider.toggleDone(task, done),
              onEdit: () => _openEditor(existing: task),
              onDelete: () => provider.delete(task.id),
            ),
          ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        HistoryScreen(
          taskProvider: widget.taskProvider,
          onEdit: (task) => _openEditor(existing: task),
        ),
      ],
    );
  }

  Widget _buildStatsTab() {
    return StatsScreen(taskProvider: widget.taskProvider);
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SettingsScreen(
          authProvider: widget.authProvider,
          taskProvider: widget.taskProvider,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.taskProvider, widget.authProvider]),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('5분 홈트 루틴')),
          body: IndexedStack(
            index: _tabIndex,
            children: [
              _buildRecommendTab(),
              _buildHistoryTab(),
              _buildStatsTab(),
              _buildSettingsTab(),
            ],
          ),
          floatingActionButton: _tabIndex == 0
              ? FloatingActionButton.extended(
                  key: const Key('addTaskFab'),
                  onPressed: () => _openEditor(),
                  icon: const Icon(Icons.add),
                  label: const Text('할 일 추가'),
                )
              : null,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tabIndex,
            onDestinationSelected: (i) => setState(() => _tabIndex = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.bolt), label: '추천'),
              NavigationDestination(icon: Icon(Icons.history), label: '히스토리'),
              NavigationDestination(icon: Icon(Icons.bar_chart), label: '통계'),
              NavigationDestination(icon: Icon(Icons.settings), label: '설정'),
            ],
          ),
        );
      },
    );
  }
}
