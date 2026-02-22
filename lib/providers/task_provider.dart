import 'package:flutter/foundation.dart';

import '../models/energy_task.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider({required this.service, required this.authProvider});

  final SupabaseService service;
  final AuthProvider authProvider;

  bool _loading = false;
  String? _error;
  UserProfile? _profile;
  final List<EnergyTask> _tasks = [];
  int _currentEnergyLevel = 3;

  bool get loading => _loading;
  String? get error => _error;
  UserProfile? get profile => _profile;
  List<EnergyTask> get tasks => List.unmodifiable(_tasks);
  int get currentEnergyLevel => _currentEnergyLevel;

  List<EnergyTask> get recommendedTasks {
    final candidates = _tasks
        .where((t) => !t.done && t.requiredEnergy <= _currentEnergyLevel)
        .toList();
    candidates.sort((a, b) {
      final e = a.requiredEnergy.compareTo(b.requiredEnergy);
      if (e != 0) return e;
      return a.estimatedMinutes.compareTo(b.estimatedMinutes);
    });
    return candidates;
  }

  List<EnergyTask> get completedTasks => _tasks.where((t) => t.done).toList();

  int get totalFocusMinutes => _tasks.fold<int>(0, (sum, task) => sum + task.estimatedMinutes);
  int get completedFocusMinutes => _tasks.where((t) => t.done).fold<int>(0, (sum, task) => sum + task.estimatedMinutes);

  void setCurrentEnergyLevel(int value) {
    _currentEnergyLevel = value.clamp(1, 5);
    notifyListeners();
  }

  Future<void> refresh() async {
    final userId = authProvider.userId;
    if (userId == null) {
      clear();
      return;
    }

    _setLoading(true);
    _error = null;
    notifyListeners();

    try {
      await service.ensureProfile(userId);
      _profile = await service.fetchProfile(userId);
      _currentEnergyLevel = _profile?.defaultEnergyLevel ?? 3;

      final loaded = await service.fetchTasks(userId);
      loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _tasks
        ..clear()
        ..addAll(loaded);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> save(EnergyTask task) async {
    final userId = authProvider.userId;
    if (userId == null) {
      _error = '로그인이 필요합니다.';
      notifyListeners();
      return;
    }

    _error = null;
    notifyListeners();

    try {
      await service.saveTask(userId: userId, task: task);
      await refresh();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> delete(String taskId) async {
    final userId = authProvider.userId;
    if (userId == null) return;

    _error = null;
    notifyListeners();

    try {
      await service.deleteTask(userId: userId, taskId: taskId);
      await refresh();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> toggleDone(EnergyTask task, bool done) async {
    final updated = task.copyWith(
      status: done ? 'done' : 'pending',
      updatedAt: DateTime.now(),
    );
    await save(updated);
  }

  Future<void> updateSettings({
    required int defaultEnergyLevel,
    required int dailyFocusMinutes,
    required bool notificationsEnabled,
  }) async {
    final current = _profile;
    if (current == null) return;

    final updated = current.copyWith(
      defaultEnergyLevel: defaultEnergyLevel,
      dailyFocusMinutes: dailyFocusMinutes,
      notificationsEnabled: notificationsEnabled,
    );

    _error = null;
    notifyListeners();

    try {
      await service.updateProfile(updated);
      _profile = updated;
      _currentEnergyLevel = updated.defaultEnergyLevel;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void clear() {
    _error = null;
    _tasks.clear();
    _profile = null;
    _currentEnergyLevel = 3;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
