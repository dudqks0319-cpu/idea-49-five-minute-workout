import 'dart:async';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/energy_task.dart';
import '../models/user_profile.dart';

class SupabaseService {
  SupabaseService._({required this.useSupabase});

  final bool useSupabase;

  final _localAuthController = StreamController<void>.broadcast();
  final Map<String, String> _localPasswords = {};
  final Map<String, String> _localUserIds = {};
  final Map<String, UserProfile> _localProfiles = {};
  final Map<String, List<EnergyTask>> _localTasks = {};
  String? _localCurrentUserId;

  static Future<SupabaseService> bootstrapFromEnvironment() async {
    const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    if (url.isEmpty || anonKey.isEmpty) {
      return SupabaseService._(useSupabase: false);
    }

    try {
      await Supabase.initialize(url: url, anonKey: anonKey);
      return SupabaseService._(useSupabase: true);
    } catch (_) {
      return SupabaseService._(useSupabase: false);
    }
  }

  String? get currentUserId {
    if (useSupabase) return Supabase.instance.client.auth.currentUser?.id;
    return _localCurrentUserId;
  }

  bool get isLoggedIn => currentUserId != null;

  Stream<void> get authChanges {
    if (useSupabase) {
      return Supabase.instance.client.auth.onAuthStateChange.map((_) {});
    }
    return _localAuthController.stream;
  }

  Future<void> signIn({required String email, required String password}) async {
    if (useSupabase) {
      await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      final uid = currentUserId;
      if (uid == null) {
        throw Exception('로그인에 실패했습니다.');
      }
      await ensureProfile(uid);
      return;
    }

    final normalized = email.trim().toLowerCase();
    final saved = _localPasswords[normalized];
    if (saved == null || saved != password) {
      throw Exception('로컬 로그인 실패: 계정 또는 비밀번호를 확인해 주세요.');
    }

    _localCurrentUserId = _localUserIds[normalized];
    _localAuthController.add(null);
  }

  Future<void> signUp({required String email, required String password}) async {
    if (useSupabase) {
      final result = await Supabase.instance.client.auth.signUp(email: email, password: password);

      if (Supabase.instance.client.auth.currentUser == null) {
        try {
          await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
        } catch (_) {}
      }

      final uid = currentUserId ?? result.user?.id;
      if (uid == null) {
        throw Exception('회원가입 후 이메일 인증이 필요합니다.');
      }
      await ensureProfile(uid);
      return;
    }

    final normalized = email.trim().toLowerCase();
    if (_localPasswords.containsKey(normalized)) {
      throw Exception('이미 존재하는 계정입니다.');
    }

    final userId = _newLocalId();
    _localPasswords[normalized] = password;
    _localUserIds[normalized] = userId;
    _localCurrentUserId = userId;
    _localProfiles[userId] = UserProfile.defaults(userId);
    _localTasks[userId] = [];
    _localAuthController.add(null);
  }

  Future<void> signOut() async {
    if (useSupabase) {
      await Supabase.instance.client.auth.signOut();
      return;
    }
    _localCurrentUserId = null;
    _localAuthController.add(null);
  }

  Future<void> ensureProfile(String userId) async {
    if (useSupabase) {
      await Supabase.instance.client.from('profiles').upsert({
        'id': userId,
        'default_energy_level': 3,
        'daily_focus_minutes': 180,
        'notifications_enabled': true,
      });
      return;
    }

    _localProfiles.putIfAbsent(userId, () => UserProfile.defaults(userId));
    _localTasks.putIfAbsent(userId, () => []);
  }

  Future<UserProfile> fetchProfile(String userId) async {
    if (useSupabase) {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('id, default_energy_level, daily_focus_minutes, notifications_enabled')
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        await ensureProfile(userId);
        return UserProfile.defaults(userId);
      }
      return UserProfile.fromMap(data, userId);
    }

    await ensureProfile(userId);
    return _localProfiles[userId] ?? UserProfile.defaults(userId);
  }

  Future<void> updateProfile(UserProfile profile) async {
    if (useSupabase) {
      await Supabase.instance.client.from('profiles').update({
        'default_energy_level': profile.defaultEnergyLevel,
        'daily_focus_minutes': profile.dailyFocusMinutes,
        'notifications_enabled': profile.notificationsEnabled,
      }).eq('id', profile.userId);
      return;
    }

    _localProfiles[profile.userId] = profile;
  }

  Future<List<EnergyTask>> fetchTasks(String userId) async {
    if (useSupabase) {
      final rows = await Supabase.instance.client
          .from('five_minute_workout_items')
          .select('id, title, required_energy, estimated_minutes, status, notes, created_at, updated_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (rows as List)
          .map((row) => EnergyTask.fromMap(Map<String, dynamic>.from(row as Map)))
          .toList();
    }

    await ensureProfile(userId);
    return List<EnergyTask>.from(_localTasks[userId] ?? []);
  }

  Future<void> saveTask({required String userId, required EnergyTask task}) async {
    if (useSupabase) {
      await Supabase.instance.client.from('five_minute_workout_items').upsert(task.toInsertMap(userId), onConflict: 'id');
      return;
    }

    await ensureProfile(userId);
    final list = _localTasks[userId]!;
    final idx = list.indexWhere((e) => e.id == task.id);
    if (idx >= 0) {
      list[idx] = task;
    } else {
      list.insert(0, task);
    }
  }

  Future<void> deleteTask({required String userId, required String taskId}) async {
    if (useSupabase) {
      await Supabase.instance.client.from('five_minute_workout_items').delete().eq('id', taskId).eq('user_id', userId);
      return;
    }

    _localTasks[userId]?.removeWhere((e) => e.id == taskId);
  }

  String newTaskId() {
    return 'local-task-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}';
  }

  String _newLocalId() {
    return 'local-user-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}';
  }

  void dispose() {
    if (!useSupabase) {
      _localAuthController.close();
    }
  }
}
