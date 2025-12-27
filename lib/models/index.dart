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
}

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
}

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
}

class WorkoutLog {
  final String id;
  final String memberId;
  final String memberName;
  final String date;
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
}