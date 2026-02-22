import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newskilloapp/features/content/models/skill_model.dart';
import 'package:newskilloapp/features/content/models/lesson_model.dart';

class ContentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Skill>> watchSkills() {
    return _db
        .collection('skills')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Skill.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Lesson>> watchLessons(String skillId) {
    return _db
        .collection('skills')
        .doc(skillId)
        .collection('lessons')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Lesson.fromMap(d.id, d.data())).toList());
  }
}