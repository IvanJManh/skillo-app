class Skill {
  final String id;
  final String title;
  final String description;
  final String level;
  final int order;
  final bool isActive;
  final String? thumbnailUrl;

  Skill({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.order,
    required this.isActive,
    this.thumbnailUrl,
  });

  factory Skill.fromMap(String id, Map<String, dynamic> data) {
    int _asInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return Skill(
      id: id,
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      level: (data['level'] ?? 'Beginner').toString(),
      order: _asInt(data['order']),
      isActive: (data['isActive'] ?? true) as bool,
      thumbnailUrl: data['thumbnailUrl']?.toString(),
    );
  }
}