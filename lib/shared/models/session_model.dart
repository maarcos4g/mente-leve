import 'package:mente_leve/shared/models/enums/user_role.dart';
import 'package:mente_leve/shared/models/local_user_model.dart';
import 'package:mente_leve/shared/models/user_model.dart';

sealed class SessionModel {
  const SessionModel();
  String get uid;
  Role get role;
}

class StudentSessionModel extends SessionModel {
  @override
  final String uid;
  final LocalUserModel user;
  
  StudentSessionModel ({
    required this.uid,
    required this.user,
  });

  @override
  Role get role => Role.student;
}

class InstitutionalSession extends SessionModel {
  final UserModel user;
  InstitutionalSession(this.user);

  @override
  String get uid => user.uid;

  @override
  Role get role => user.role;
}