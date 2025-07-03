class ClassModel {
  final String id;
  final String userId;
  final String name;
  final String? programStudy;
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  ClassModel({
    required this.id,
    required this.userId,
    required this.name,
    this.programStudy,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'],
      userId: map['user_id'],
      name: map['class_name'],
      programStudy: map['program_study'],
      dayOfWeek: map['day_of_week'],
      startTime: map['start_time'],
      endTime: map['end_time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'class_name': name,
      'program_study': programStudy,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}
