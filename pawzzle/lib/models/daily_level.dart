class DailyLevel {
  final String id;
  final String title;
  final String imagePath;
  final int gridSize;
  final int shuffleMoves;
  final int rewardCoins;

  DailyLevel({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.gridSize,
    required this.shuffleMoves,
    required this.rewardCoins,
  });

  factory DailyLevel.fromMap(Map<String, dynamic> map) {
    return DailyLevel(
      id: map['id'],
      title: map['title'],
      imagePath: map['image_path'],
      gridSize: map['grid_size'],
      shuffleMoves: map['shuffle_moves'],
      rewardCoins: map['reward_coins'],
    );
  }
}
