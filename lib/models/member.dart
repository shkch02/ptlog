// 회원 정보를 관리하는 Member 데이터 모델을 정의합니다.
class Member {
  final String id;
  final String name;
  final String phone;
  final String email;
  final int remainingSessions;
  final int totalSessions;
  final DateTime registrationDate;
  final String notes;
  final String? profileImage;
  final bool isArchived; // 보관(비활성) 상태 여부

  // --- 추가된 신체 정보 필드 (타입 변경) ---
  final double? height;        // 키
  final double? weight;        // 현재 체중
  final double? targetWeight;  // 목표 체중
  final int? age;           // 나이
  final double? bodyFat;       // 체지방률
  final double? skeletalMuscle;// 골격근량
  final double? targetMuscle;  // 목표 골격근량
  final String? activityLevel; // 활동량
  final String? sleepTime;     // 수면 시간

  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.remainingSessions,
    required this.totalSessions,
    required this.registrationDate,
    required this.notes,
    this.profileImage,
    this.isArchived = false, // 기본값: 활성 상태
    // --- 생성자 ---
    this.height,
    this.weight,
    this.targetWeight,
    this.age,
    this.bodyFat,
    this.skeletalMuscle,
    this.targetMuscle,
    this.activityLevel,
    this.sleepTime,
  });

  Member copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    int? remainingSessions,
    int? totalSessions,
    DateTime? registrationDate,
    String? notes,
    String? profileImage,
    bool? isArchived,
    // --- copyWith 타입 변경 ---
    double? height,
    double? weight,
    double? targetWeight,
    int? age,
    double? bodyFat,
    double? skeletalMuscle,
    double? targetMuscle,
    String? activityLevel,
    String? sleepTime,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      remainingSessions: remainingSessions ?? this.remainingSessions,
      totalSessions: totalSessions ?? this.totalSessions,
      registrationDate: registrationDate ?? this.registrationDate,
      notes: notes ?? this.notes,
      profileImage: profileImage ?? this.profileImage,
      isArchived: isArchived ?? this.isArchived,
      // --- copyWith 적용 ---
      height: height ?? this.height,
      weight: weight ?? this.weight,
      targetWeight: targetWeight ?? this.targetWeight,
      age: age ?? this.age,
      bodyFat: bodyFat ?? this.bodyFat,
      skeletalMuscle: skeletalMuscle ?? this.skeletalMuscle,
      targetMuscle: targetMuscle ?? this.targetMuscle,
      activityLevel: activityLevel ?? this.activityLevel,
      sleepTime: sleepTime ?? this.sleepTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'remainingSessions': remainingSessions,
      'totalSessions': totalSessions,
      'registrationDate': registrationDate.toIso8601String(),
      'notes': notes,
      'profileImage': profileImage,
      'isArchived': isArchived,
      // --- toJson 타입 변경 ---
      'height': height,
      'weight': weight,
      'targetWeight': targetWeight,
      'age': age,
      'bodyFat': bodyFat,
      'skeletalMuscle': skeletalMuscle,
      'targetMuscle': targetMuscle,
      'activityLevel': activityLevel,
      'sleepTime': sleepTime,
    };
  }

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      remainingSessions: json['remainingSessions'],
      totalSessions: json['totalSessions'],
      registrationDate: DateTime.parse(json['registrationDate']),
      notes: json['notes'],
      profileImage: json['profileImage'],
      isArchived: json['isArchived'] ?? false,
      // --- fromJson 타입 변환 ---
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      targetWeight: (json['targetWeight'] as num?)?.toDouble(),
      age: json['age'] as int?,
      bodyFat: (json['bodyFat'] as num?)?.toDouble(),
      skeletalMuscle: (json['skeletalMuscle'] as num?)?.toDouble(),
      targetMuscle: (json['targetMuscle'] as num?)?.toDouble(),
      activityLevel: json['activityLevel'],
      sleepTime: json['sleepTime'],
    );
  }
}