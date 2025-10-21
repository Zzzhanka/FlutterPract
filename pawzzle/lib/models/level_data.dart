class LevelData {
  final int id;
  final String image;
  final int grid;
  final int shuffle;
  double? bestTime; // лучшее время (в секундах)
  int stars; // 0–3 звезды
  bool unlocked; // открыт ли уровень

  LevelData({
    required this.id,
    required this.image,
    required this.grid,
    required this.shuffle,
    this.bestTime,
    this.stars = 0,
    this.unlocked = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'bestTime': bestTime,
    'stars': stars,
    'unlocked': unlocked,
  };

  factory LevelData.fromJson(Map<String, dynamic> json, LevelData base) {
    return LevelData(
      id: base.id,
      image: base.image,
      grid: base.grid,
      shuffle: base.shuffle,
      bestTime: json['bestTime']?.toDouble(),
      stars: json['stars'] ?? 0,
      unlocked: json['unlocked'] ?? false,
    );
  }

  LevelData copyWith({double? bestTime, int? stars, bool? unlocked}) {
    return LevelData(
      id: id,
      image: image,
      grid: grid,
      shuffle: shuffle,
      bestTime: bestTime ?? this.bestTime,
      stars: stars ?? this.stars,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}
