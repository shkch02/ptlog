class Schedule {
  final String id;
  final String relationId; // 어떤 계약 관계에 속한 스케줄인지
  final String? memberId;   // 편의를 위한 필드 (JOIN된 데이터)
  final String? memberName; // 편의를 위한 필드 (JOIN된 데이터)
  final DateTime date;
  final String startTime;
  final String endTime;
  final String notes;
  final String reminder;

  Schedule({
    required this.id,
    required this.relationId,
    this.memberId,
    this.memberName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.notes,
    required this.reminder,
  });

  Schedule copyWith({
    String? id,
    String? relationId,
    String? memberId,
    String? memberName,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? notes,
    String? reminder,
  }) {
    return Schedule(
      id: id ?? this.id,
      relationId: relationId ?? this.relationId,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      reminder: reminder ?? this.reminder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'relationId': relationId,
      'memberId': memberId,
      'memberName': memberName,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'notes': notes,
      'reminder': reminder,
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      relationId: json['relationId'],
      memberId: json['memberId'],
      memberName: json['memberName'],
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      notes: json['notes'],
      reminder: json['reminder'],
    );
  }
}
