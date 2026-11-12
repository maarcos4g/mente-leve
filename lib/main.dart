import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mente_leve/app_widget.dart';
import 'package:mente_leve/modules/student/support_trigger/repositories/prefs_mood_record_repository.dart';
import 'package:mente_leve/modules/student/support_trigger/repositories/support_trigger_state_store.dart';
import 'package:mente_leve/modules/student/support_trigger/support_trigger_controller.dart';
import 'package:mente_leve/shared/auth/auth_notifier.dart';
import 'package:mente_leve/shared/auth/auth_repository.dart';
import 'package:mente_leve/shared/auth/profile_store.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<AuthNotifier> _initialization = _bootstrap();

  /// Gatilho de apoio (RN11): lê o diário e guarda seu estado só no aparelho.
  late final SupportTriggerController _supportTrigger;

  Future<AuthNotifier> _bootstrap() async {
    await Firebase.initializeApp();
    final storage = await SharedPreferences.getInstance();
    _supportTrigger = SupportTriggerController(
      records: PrefsMoodRecordRepository(storage),
      stateStore: SupportTriggerStateStore(storage),
    );
    return AuthNotifier(
      AuthRepository(
        FirebaseAuth.instance,
        FirebaseFirestore.instance,
        ProfileStore(storage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Material(
            child: Center(
              child: Text(
                'Não foi possível inicializar o Firebase',
                textDirection: TextDirection.ltr,
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return ColoredBox(color: Colors.white);
        }

        return Provider.value(
          value: _supportTrigger,
          child: ChangeNotifierProvider.value(
            value: snapshot.data!,
            child: AppWidget(),
          ),
        );
      },
    );
  }
}
