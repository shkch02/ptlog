class Schedule {
  final String id;
  final String memberId;
  final String memberName;
  final String date;
  final String startTime;
  final String endTime;
  final String notes;
  final String reminder;

  Schedule({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.notes,
    required this.reminder,
  });

  Schedule copyWith({
    String? id,
    String? memberId,
    String? memberName,
    String? date,
    String? startTime,
    String? endTime,
    String? notes,
    String? reminder,
  }) {
    return Schedule(
      id: id ?? this.id,
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
      'memberId': memberId,
      'memberName': memberName,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'notes': notes,
      'reminder': reminder,
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      memberId: json['memberId'],
      memberName: json['memberName'],
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      notes: json['notes'],
      reminder: json['reminder'],
    );
  }
}