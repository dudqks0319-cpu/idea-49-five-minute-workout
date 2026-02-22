class UserProfile {
  UserProfile({
    required this.userId,
    required this.defaultEnergyLevel,
    required this.dailyFocusMinutes,
    required this.notificationsEnabled,
  });

  final String userId;
  final int defaultEnergyLevel; // 1~5
  final int dailyFocusMinutes;
  final bool notificationsEnabled;

  UserProfile copyWith({
    String? userId,
    int? defaultEnergyLevel,
    int? dailyFocusMinutes,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      defaultEnergyLevel: defaultEnergyLevel ?? this.defaultEnergyLevel,
      dailyFocusMinutes: dailyFocusMinutes ?? this.dailyFocusMinutes,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'default_energy_level': defaultEnergyLevel,
      'daily_focus_minutes': dailyFocusMinutes,
      'notifications_enabled': notificationsEnabled,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String userId) {
    return UserProfile(
      userId: userId,
      defaultEnergyLevel: (map['default_energy_level'] as num?)?.toInt() ?? 3,
      dailyFocusMinutes: (map['daily_focus_minutes'] as num?)?.toInt() ?? 180,
      notificationsEnabled: (map['notifications_enabled'] as bool?) ?? true,
    );
  }

  static UserProfile defaults(String userId) {
    return UserProfile(
      userId: userId,
      defaultEnergyLevel: 3,
      dailyFocusMinutes: 180,
      notificationsEnabled: true,
    );
  }
}
