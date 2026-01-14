// 운동일지 정보를 관리하는 WorkoutLog 데이터 모델을 정의합니다.

/// 세트 데이터 입력 방식
enum ExerciseInputType { digital, handwriting }

class WorkoutExercise {
  final String id;
  final String name;
  final String targetPart;
  final ExerciseInputType inputType;
  final List<WorkoutSet>? sets; // null if handwriting mode
  final String? handwritingImagePath; // null if digital mode
  final List<String> photos;
  final String notes;

  WorkoutExercise({
    required this.id,
    required this.name,
    this.targetPart = '',
    this.inputType = ExerciseInputType.digital,
    this.sets,
    this.handwritingImagePath,
    this.photos = const [],
    required this.notes,
  });

  /// 디지털 입력 모드인지 확인
  bool get isDigitalInput => inputType == ExerciseInputType.digital;

  /// 필기 입력 모드인지 확인
  bool get isHandwritingInput => inputType == ExerciseInputType.handwriting;

  WorkoutExercise copyWith({
    String? id,
    String? name,
    String? targetPart,
    ExerciseInputType? inputType,
    List<WorkoutSet>? sets,
    String? handwritingImagePath,
    List<String>? photos,
    String? notes,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      targetPart: targetPart ?? this.targetPart,
      inputType: inputType ?? this.inputType,
      sets: sets ?? this.sets,
      handwritingImagePath: handwritingImagePath ?? this.handwritingImagePath,
      photos: photos ?? this.photos,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetPart': targetPart,
      'inputType': inputType.name,
      'sets': sets?.map((set) => set.toJson()).toList(),
      'handwritingImagePath': handwritingImagePath,
      'photos': photos,
      'notes': notes,
    };
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'],
      name: json['name'],
      targetPart: json['targetPart'] ?? '',
      inputType: ExerciseInputType.values.firstWhere(
        (e) => e.name == json['inputType'],
        orElse: () => ExerciseInputType.digital,
      ),
      sets: json['sets'] != null
          ? (json['sets'] as List).map((set) => WorkoutSet.fromJson(set)).toList()
          : null,
      handwritingImagePath: json['handwritingImagePath'],
      photos: json['photos'] != null ? List<String>.from(json['photos']) : [],
      notes: json['notes'],
    );
  }
}

class WorkoutSet {
  final int setNumber;
  final int reps;
  final int weight;

  WorkoutSet({
    required this.setNumber,
    required this.reps,
    required this.weight,
  });

  WorkoutSet copyWith({
    int? setNumber,
    int? reps,
    int? weight,
  }) {
    return WorkoutSet(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'reps': reps,
      'weight': weight,
    };
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      setNumber: json['setNumber'],
      reps: json['reps'],
      weight: json['weight'],
    );
  }
}

class WorkoutLog {
  final String id;
  final String memberId;
  final String memberName;
  final DateTime date;
  final int sessionNumber;
  final List<WorkoutExercise> exercises;
  final String overallNotes;
  final String reminderForNext;
  final List<String> photos;

  WorkoutLog({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.date,
    required this.sessionNumber,
    required this.exercises,
    required this.overallNotes,
    required this.reminderForNext,
    required this.photos,
  });

  WorkoutLog copyWith({
    String? id,
    String? memberId,
    String? memberName,
    DateTime? date,
    int? sessionNumber,
    List<WorkoutExercise>? exercises,
    String? overallNotes,
    String? reminderForNext,
    List<String>? photos,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      date: date ?? this.date,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      exercises: exercises ?? this.exercises,
      overallNotes: overallNotes ?? this.overallNotes,
      reminderForNext: reminderForNext ?? this.reminderForNext,
      photos: photos ?? this.photos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'date': date.toIso8601String(),
      'sessionNumber': sessionNumber,
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      'overallNotes': overallNotes,
      'reminderForNext': reminderForNext,
      'photos': photos,
    };
  }

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id: json['id'],
      memberId: json['memberId'],
      memberName: json['memberName'],
      date: DateTime.parse(json['date']),
      sessionNumber: json['sessionNumber'],
      exercises: (json['exercises'] as List).map((exercise) => WorkoutExercise.fromJson(exercise)).toList(),
      overallNotes: json['overallNotes'],
      reminderForNext: json['reminderForNext'],
      photos: List<String>.from(json['photos']),
    );
  }
}
