class WorkoutAPI {
  // This function mimics the previous async structure for easy reuse
  static Future<List<Map<String, String>>> fetchWorkoutPlans() async {
    // Simulate a tiny delay (so your UI doesn’t break expecting a Future)
    await Future.delayed(const Duration(milliseconds: 200));
    return _fallbackExercises;
  }

  // Local list of workout plans
  static final List<Map<String, String>> _fallbackExercises = [
    {
      'name': 'Push-Up',
      'description':
          'A classic upper-body exercise that targets the chest, shoulders, and triceps.\n\nCategory: Strength\nEquipment: Bodyweight'
    },
    {
      'name': 'Squat',
      'description':
          'A lower-body exercise that strengthens the legs and glutes.\n\nCategory: Strength\nEquipment: Bodyweight'
    },
    {
      'name': 'Bench Press',
      'description':
          'An upper-body exercise for the chest, shoulders, and triceps.\n\nCategory: Strength\nEquipment: Barbell or Dumbbells'
    },
    {
      'name': 'Deadlift',
      'description':
          'A compound lift that strengthens the back, glutes, and legs.\n\nCategory: Strength\nEquipment: Barbell'
    },
    {
      'name': 'Plank',
      'description':
          'An isometric core exercise that improves stability and posture.\n\nCategory: Core\nEquipment: Bodyweight'
    },
    {
      'name': 'Lunges',
      'description':
          'A unilateral leg exercise targeting the quads, hamstrings, and glutes.\n\nCategory: Strength\nEquipment: Bodyweight or Dumbbells'
    },
    {
      'name': 'Bicep Curl',
      'description':
          'An isolation exercise that strengthens the biceps.\n\nCategory: Strength\nEquipment: Dumbbells or Barbell'
    },
    {
      'name': 'Dips',
      'description':
          'A bodyweight movement that works the triceps, chest, and shoulders.\n\nCategory: Strength\nEquipment: Bodyweight or Bench'
    },
    {
      'name': 'Mountain Climbers',
      'description':
          'A cardio core exercise that improves endurance and stability.\n\nCategory: Cardio\nEquipment: Bodyweight'
    },
    {
      'name': 'Burpees',
      'description':
          'A full-body conditioning exercise combining a squat, push-up, and jump.\n\nCategory: Cardio\nEquipment: Bodyweight'
    },
  ];
}