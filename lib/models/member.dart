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
    );
  }
}