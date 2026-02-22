import 'package:flutter/material.dart';

import '../providers/task_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.taskProvider});

  final TaskProvider taskProvider;

  @override
  Widget build(BuildContext context) {
    final all = taskProvider.tasks;
    final done = all.where((t) => t.done).toList();
    final pending = all.where((t) => !t.done).toList();

    final totalMinutes = all.fold<int>(0, (s, t) => s + t.estimatedMinutes);
    final doneMinutes = done.fold<int>(0, (s, t) => s + t.estimatedMinutes);
    final completionRate = totalMinutes == 0 ? 0.0 : (doneMinutes / totalMinutes).clamp(0.0, 1.0);

    final energyBuckets = List<int>.filled(5, 0);
    for (final task in all) {
      final idx = task.requiredEnergy.clamp(1, 5) - 1;
      energyBuckets[idx] += 1;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(label: '총 작업', value: all.length.toString())),
            const SizedBox(width: 8),
            Expanded(child: _StatCard(label: '완료', value: done.length.toString())),
            const SizedBox(width: 8),
            Expanded(child: _StatCard(label: '미완료', value: pending.length.toString())),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('집중 시간 진행률', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('$doneMinutes분 / $totalMinutes분'),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: completionRate),
                const SizedBox(height: 4),
                Text('완료율 ${(completionRate * 100).toStringAsFixed(1)}%'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('우선순위 분포', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                for (var i = 0; i < 5; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(width: 50, child: Text('E${i + 1}')),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: all.isEmpty ? 0 : energyBuckets[i] / all.length,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${energyBuckets[i]}개'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
