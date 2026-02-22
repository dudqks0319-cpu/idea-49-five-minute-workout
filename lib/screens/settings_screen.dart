import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.authProvider,
    required this.taskProvider,
  });

  final AuthProvider authProvider;
  final TaskProvider taskProvider;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _defaultEnergy;
  late int _dailyFocus;
  late bool _notifications;

  @override
  void initState() {
    super.initState();
    final profile = widget.taskProvider.profile;
    _defaultEnergy = profile?.defaultEnergyLevel ?? 3;
    _dailyFocus = profile?.dailyFocusMinutes ?? 180;
    _notifications = profile?.notificationsEnabled ?? true;
  }

  Future<void> _save() async {
    await widget.taskProvider.updateSettings(
      defaultEnergyLevel: _defaultEnergy,
      dailyFocusMinutes: _dailyFocus,
      notificationsEnabled: _notifications,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('설정이 저장되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('설정', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('기본 우선순위 레벨: $_defaultEnergy / 5'),
            Slider(
              value: _defaultEnergy.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (v) => setState(() => _defaultEnergy = v.round()),
            ),
            const SizedBox(height: 8),
            Text('일일 집중 목표: $_dailyFocus 분'),
            Slider(
              value: _dailyFocus.toDouble(),
              min: 30,
              max: 480,
              divisions: 15,
              onChanged: (v) => setState(() => _dailyFocus = v.round()),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
              title: const Text('알림 사용'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    key: const Key('saveSettingsButton'),
                    onPressed: _save,
                    child: const Text('설정 저장'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    key: const Key('logoutButton'),
                    onPressed: widget.authProvider.signOut,
                    child: const Text('로그아웃'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
