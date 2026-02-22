class Lesson {
  final String id;
  final String title;
  final String description;
  final String? videoUrl;
  final int order;
  final int durationMin;
  final bool isFree;
  final bool isActive;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.durationMin,
    required this.isFree,
    required this.isActive,
    this.videoUrl,
  });

  factory Lesson.fromMap(String id, Map<String, dynamic> data) {
    int _asInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    // 🔥 Accept either durationMin or durationMin (if you used different name)
    final duration = data.containsKey('durationMin')
        ? data['durationMin']
        : data['durationMin'];

    return Lesson(
      id: id,
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      videoUrl: data['videoUrl']?.toString(),
      order: _asInt(data['order']),
      durationMin: _asInt(duration),
      isFree: (data['isFree'] ?? true) as bool,
      isActive: (data['isActive'] ?? true) as bool,
    );
  }
}