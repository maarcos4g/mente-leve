import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mente_leve/app_widget.dart';
import 'package:mente_leve/shared/auth/auth_notifier.dart';
import 'package:mente_leve/shared/auth/auth_repository.dart';
import 'package:mente_leve/shared/auth/profile_store.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<AuthNotifier> _initialization = _bootstrap();

  Future<AuthNotifier> _bootstrap() async {
    await Firebase.initializeApp();
    final storage = await SharedPreferences.getInstance();
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
        
        return ChangeNotifierProvider.value(
          value: snapshot.data!,
          child: AppWidget(),
        );
      },
    );
  }
}
