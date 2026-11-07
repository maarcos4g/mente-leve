
import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums/user_role.dart';

class UserModel {
  final String uid;
  final String name;
  final Role role;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.role,
    required this.createdAt,
  });

  bool get isInstitutional => role != Role.student;
  bool get canGenerateContent => role == Role.psychologist;
  bool get canAccessReports => role == Role.psychologist;
  bool get canReadContent => isInstitutional;

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options
  ) {
    final data = snapshot.data()!;
    final role = Role.values.byName(data['role'] as String);
    if (role == Role.student) {
      throw StateError('O Aluno não deve ser registrado como usuário no sistema');
    }
    return UserModel(
      uid: snapshot.id,
      name: data['name'] as String,
      role: role,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}