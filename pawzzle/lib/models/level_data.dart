class PuzzleLevel {
  final int id;
  final String imagePath;
  final int gridSize;
  final int shuffleMoves;

  bool isLocked;
  int stars;

  PuzzleLevel({
    required this.id,
    required this.imagePath,
    required this.gridSize,
    required this.shuffleMoves,
    this.isLocked = true,
    this.stars = 0,
  });

  factory PuzzleLevel.fromDb(
    Map<String, dynamic> data,
    Map<String, dynamic>? progress,
  ) {
    return PuzzleLevel(
      id: data['id'],
      imagePath: data['image_path'],
      gridSize: data['grid_size'],
      shuffleMoves: data['shuffle_moves'],
      isLocked: progress?['unlocked'] ?? false,
      stars: progress?['best_stars'] ?? 0,
    );
  }
}
