// lib/models/session_form.dart

class ExerciseForm {
  String name = '';
  String targetPart = '';
  List<SetForm> sets = [SetForm()];
}

class SetForm {
  String weight = '';
  String reps = '';
  String rest = '';
}