// 트레이너와 회원 간의 관계(계약) 정보를 관리하는 데이터 모델을 정의합니다.
class TrainerMemberRelation {
  final String id;
  final String trainerId;
  final String memberId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  // 편의를 위해 JOIN된 데이터를 포함할 수 있습니다. (백엔드에서 채워줘야 함)
  final String? memberName;
  final String? trainerName;

  TrainerMemberRelation({
    required this.id,
    required this.trainerId,
    required this.memberId,
    required this.startDate,
    this.endDate,
    required this.isActive,
    this.memberName,
    this.trainerName,
  });

  TrainerMemberRelation copyWith({
    String? id,
    String? trainerId,
    String? memberId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? memberName,
    String? trainerName,
  }) {
    return TrainerMemberRelation(
      id: id ?? this.id,
      trainerId: trainerId ?? this.trainerId,
      memberId: memberId ?? this.memberId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      memberName: memberName ?? this.memberName,
      trainerName: trainerName ?? this.trainerName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainerId': trainerId,
      'memberId': memberId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'memberName': memberName,
      'trainerName': trainerName,
    };
  }

  factory TrainerMemberRelation.fromJson(Map<String, dynamic> json) {
    return TrainerMemberRelation(
      id: json['id'],
      trainerId: json['trainerId'],
      memberId: json['memberId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'],
      memberName: json['memberName'],
      trainerName: json['trainerName'],
    );
  }
}
