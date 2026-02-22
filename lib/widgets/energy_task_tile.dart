import 'package:flutter/material.dart';

import '../models/energy_task.dart';

class EnergyTaskTile extends StatelessWidget {
  const EnergyTaskTile({
    super.key,
    required this.task,
    required this.onToggleDone,
    required this.onEdit,
    required this.onDelete,
  });

  final EnergyTask task;
  final ValueChanged<bool> onToggleDone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _energyColor(int energy) {
    if (energy >= 5) return Colors.red;
    if (energy >= 4) return Colors.orange;
    if (energy >= 3) return Colors.amber.shade700;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: task.done,
          onChanged: (v) => onToggleDone(v ?? false),
        ),
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('우선순위 ${task.requiredEnergy}/5 · 예상 ${task.estimatedMinutes}분'),
            if (task.notes.isNotEmpty) Text(task.notes),
          ],
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            Chip(
              label: Text('E${task.requiredEnergy}'),
              backgroundColor: _energyColor(task.requiredEnergy).withValues(alpha: 0.15),
            ),
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
          ],
        ),
      ),
    );
  }
}
