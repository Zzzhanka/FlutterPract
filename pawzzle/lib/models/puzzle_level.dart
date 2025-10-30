class PuzzleLevel {
  final int id;
  final String title;
  final String imagePath;
  final int grid;
  final int shuffleMoves;
  final int page;
  bool isLocked;
  int? bestTime;
  int? bestStars;

  int get stars => bestStars ?? 0;

  PuzzleLevel({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.grid,
    required this.shuffleMoves,
    required this.page,
    required this.isLocked,
    this.bestTime,
    this.bestStars,
  });
}
