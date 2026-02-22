import 'package:flutter/material.dart';

import '../models/energy_task.dart';

class TaskEditorScreen extends StatefulWidget {
  const TaskEditorScreen({
    super.key,
    required this.taskId,
    this.existing,
  });

  final String taskId;
  final EnergyTask? existing;

  @override
  State<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends State<TaskEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _minutesController;
  late final TextEditingController _notesController;

  late int _requiredEnergy;
  String _status = 'pending';

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _titleController = TextEditingController(text: t?.title ?? '');
    _minutesController = TextEditingController(text: t == null ? '' : t.estimatedMinutes.toString());
    _notesController = TextEditingController(text: t?.notes ?? '');
    _requiredEnergy = t?.requiredEnergy ?? 3;
    _status = t?.status ?? 'pending';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _minutesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final minutes = int.tryParse(_minutesController.text.trim());
    if (title.isEmpty || minutes == null) return;

    final task = EnergyTask(
      id: widget.existing?.id ?? widget.taskId,
      title: title,
      requiredEnergy: _requiredEnergy,
      estimatedMinutes: minutes,
      status: _status,
      notes: _notesController.text.trim(),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? '할 일 추가' : '할 일 수정')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('taskTitleField'),
            controller: _titleController,
            decoration: const InputDecoration(labelText: '할 일 제목'),
          ),
          const SizedBox(height: 8),
          Text('우선순위: $_requiredEnergy / 5'),
          Slider(
            value: _requiredEnergy.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (v) => setState(() => _requiredEnergy = v.round()),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('taskMinutesField'),
            controller: _minutesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '예상 소요 시간(분)'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: '상태'),
            items: const [
              DropdownMenuItem(value: 'pending', child: Text('미완료')),
              DropdownMenuItem(value: 'done', child: Text('완료')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'pending'),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('taskNotesField'),
            controller: _notesController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: '메모'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('saveTaskButton'),
            onPressed: _save,
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
