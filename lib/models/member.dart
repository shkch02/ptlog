class Member {
  final String id;
  final String name;
  final String phone;
  final String email;
  final int remainingSessions;
  final int totalSessions;
  final String registrationDate;
  final String notes;
  final String? profileImage;

  // --- 추가된 신체 정보 필드 (Null 허용) ---
  final String? height;        // 키
  final String? weight;        // 현재 체중
  final String? targetWeight;  // 목표 체중
  final String? age;           // 나이
  final String? bodyFat;       // 체지방률
  final String? skeletalMuscle;// 골격근량
  final String? targetMuscle;  // 목표 골격근량
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
    // --- 생성자 추가 ---
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
    String? registrationDate,
    String? notes,
    String? profileImage,
    // --- copyWith 추가 ---
    String? height,
    String? weight,
    String? targetWeight,
    String? age,
    String? bodyFat,
    String? skeletalMuscle,
    String? targetMuscle,
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
      'registrationDate': registrationDate,
      'notes': notes,
      'profileImage': profileImage,
      // --- toJson 추가 ---
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
      registrationDate: json['registrationDate'],
      notes: json['notes'],
      profileImage: json['profileImage'],
      // --- fromJson 추가 ---
      height: json['height'],
      weight: json['weight'],
      targetWeight: json['targetWeight'],
      age: json['age'],
      bodyFat: json['bodyFat'],
      skeletalMuscle: json['skeletalMuscle'],
      targetMuscle: json['targetMuscle'],
      activityLevel: json['activityLevel'],
      sleepTime: json['sleepTime'],
    );
  }
}