class EnergyTask {
  EnergyTask({
    required this.id,
    required this.title,
    required this.requiredEnergy,
    required this.estimatedMinutes,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final int requiredEnergy; // 1~5
  final int estimatedMinutes;
  final String status; // pending | done
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get done => status == 'done';

  EnergyTask copyWith({
    String? id,
    String? title,
    int? requiredEnergy,
    int? estimatedMinutes,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EnergyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      requiredEnergy: requiredEnergy ?? this.requiredEnergy,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toInsertMap(String userId) {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'required_energy': requiredEnergy,
      'estimated_minutes': estimatedMinutes,
      'status': status,
      'notes': notes,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory EnergyTask.fromMap(Map<String, dynamic> map) {
    return EnergyTask(
      id: map['id'] as String,
      title: (map['title'] ?? '') as String,
      requiredEnergy: (map['required_energy'] as num?)?.toInt() ?? 3,
      estimatedMinutes: (map['estimated_minutes'] as num?)?.toInt() ?? 30,
      status: (map['status'] ?? 'pending') as String,
      notes: (map['notes'] ?? '') as String,
      createdAt: DateTime.tryParse((map['created_at'] ?? '') as String) ?? DateTime.now(),
      updatedAt: DateTime.tryParse((map['updated_at'] ?? '') as String) ?? DateTime.now(),
    );
  }
}
