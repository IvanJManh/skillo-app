import 'package:flutter/material.dart';
import 'package:newskilloapp/features/content/content.dart';

class SkillDetailsPage extends StatelessWidget {
  final String skillId;
  final String skillTitle;

  const SkillDetailsPage({
    super.key,
    required this.skillId,
    required this.skillTitle,
  });

  @override
  Widget build(BuildContext context) {
    final contentService = ContentService();

    return Scaffold(
      appBar: AppBar(title: Text(skillTitle)),
      body: StreamBuilder<List<Lesson>>(
        stream: contentService.watchLessons(skillId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final lessons = snapshot.data ?? [];
          if (lessons.isEmpty) {
            return const Center(child: Text("No lessons available"));
          }

          return ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, i) {
              final l = lessons[i];
              return ListTile(
                title: Text(l.title.isNotEmpty ? l.title : "Untitled lesson"),
                subtitle: Text("${l.durationMin} min"),
              );
            },
          );
        },
      ),
    );
  }
}