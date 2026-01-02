class WorkoutExercise {
  final String id;
  final String name;
  final List<WorkoutSet> sets;
  final String notes;

  WorkoutExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.notes,
  });

  WorkoutExercise copyWith({
    String? id,
    String? name,
    List<WorkoutSet>? sets,
    String? notes,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sets': sets.map((set) => set.toJson()).toList(),
      'notes': notes,
    };
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'],
      name: json['name'],
      sets: (json['sets'] as List).map((set) => WorkoutSet.fromJson(set)).toList(),
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