import 'package:flutter/material.dart';

import '../models/energy_task.dart';
import '../providers/task_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    required this.taskProvider,
    required this.onEdit,
  });

  final TaskProvider taskProvider;
  final ValueChanged<EnergyTask> onEdit;

  @override
  Widget build(BuildContext context) {
    final items = taskProvider.completedTasks;

    if (items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('완료된 작업 이력이 없습니다.'),
        ),
      );
    }

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '완료 작업 ${items.length}개 · 총 ${taskProvider.completedFocusMinutes}분',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: taskProvider.refresh,
                  child: const Text('새로고침'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (task) => Dismissible(
            key: ValueKey('done-${task.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => taskProvider.delete(task.id),
            child: Card(
              child: ListTile(
                title: Text(task.title),
                subtitle: Text('에너지 ${task.requiredEnergy}/5 · ${task.estimatedMinutes}분'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => onEdit(task),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
