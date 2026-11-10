import 'package:flutter/material.dart';
import 'package:mente_leve/app_widget.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/repositories/hive_diary_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _openDiaryStorage();
  runApp(const MyApp());
}

/// Abre o diário criptografado no aparelho. Se falhar, o app continua
/// funcionando com o diário em memória: o botão do CVV e o restante das
/// telas não podem ficar indisponíveis por causa do armazenamento.
Future<void> _openDiaryStorage() async {
  try {
    DiaryController.defaultRepository = await HiveDiaryRepository.open();
  } catch (error) {
    debugPrint('Não foi possível abrir o diário local: $error');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppWidget();
  }
}
