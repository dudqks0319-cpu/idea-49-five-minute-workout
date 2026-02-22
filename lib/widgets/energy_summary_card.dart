import 'package:flutter/material.dart';

class EnergySummaryCard extends StatelessWidget {
  const EnergySummaryCard({
    super.key,
    required this.currentEnergyLevel,
    required this.totalFocusMinutes,
    required this.completedFocusMinutes,
    required this.onEnergyChanged,
  });

  final int currentEnergyLevel;
  final int totalFocusMinutes;
  final int completedFocusMinutes;
  final ValueChanged<int> onEnergyChanged;

  @override
  Widget build(BuildContext context) {
    final progress = totalFocusMinutes == 0
        ? 0.0
        : (completedFocusMinutes / totalFocusMinutes).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('현재 작업 상태', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('우선순위 레벨: $currentEnergyLevel / 5')),
                SizedBox(
                  width: 180,
                  child: Slider(
                    value: currentEnergyLevel.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '$currentEnergyLevel',
                    onChanged: (v) => onEnergyChanged(v.round()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('집중 시간: $completedFocusMinutes분 / $totalFocusMinutes분'),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 4),
            Text('완료율 ${(progress * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }
}
