class Task {
  final String id;
  final String userId;
  final String title;
  final DateTime deadline;
  final String? startTime;
  final String? endTime;
  final bool isCompleted;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.deadline,
    this.startTime,
    this.endTime,
    this.isCompleted = false,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      deadline: DateTime.parse(map['deadline']),
      startTime: map['start_time'],
      endTime: map['end_time'],
      isCompleted: map['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'deadline': deadline.toIso8601String().substring(0, 10), 
      'start_time': startTime,
      'end_time': endTime,
      'is_completed': isCompleted,
    };
  }
}
