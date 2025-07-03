class Alarm {
  final String id;
  final String taskId;
  final String userId;
  final DateTime reminderTime;
  final bool isActive;

  Alarm({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.reminderTime,
    this.isActive = true,
  });

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      taskId: map['task_id'],
      userId: map['user_id'],
      reminderTime: DateTime.parse(map['reminder_time']),
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'user_id': userId,
      'reminder_time': reminderTime.toIso8601String(),
      'is_active': isActive,
    };
  }
}