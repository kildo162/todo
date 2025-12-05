class HealthExercise {
  final String id;
  final String title;
  final String description;
  final List<String> steps;
  final int durationSeconds;
  final String category; // breathing, stretching, mindfulness

  const HealthExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    required this.durationSeconds,
    required this.category,
  });
}
