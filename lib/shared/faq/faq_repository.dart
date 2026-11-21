import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mente_leve/shared/models/faq_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Perguntas e respostas curadas do protótipo de alta fidelidade (RF04),
/// utilizadas como conteúdo inicial e fallback offline quando não há cache.
final List<FaqModel> defaultFaqItems = List.unmodifiable([
  FaqModel(
    id: 'faq-cyberbullying',
    question: 'O que é cyberbullying',
    answer:
        'Cyberbullying é a intimidação, humilhação ou agressão repetida '
        'feita por meio de redes sociais, aplicativos de mensagens ou jogos '
        'online. Você não tem culpa pelo que está acontecendo: guarde provas '
        '(prints) e procure um adulto de confiança ou a equipe da escola.',
    createdAt: DateTime.utc(2026, 11, 1, 10, 0),
    updatedAt: DateTime.utc(2026, 11, 1, 10, 0),
    updatedBy: 'system',
  ),
  FaqModel(
    id: 'faq-lidar-ansiedade',
    question: 'Como lidar com a ansiedade?',
    answer:
        'Respire fundo, foque no presente e lembre-se que sentimentos ruins '
        'passam. Se precisar, converse anonimamente no nosso canal ou '
        'registre no diário para clarear seus pensamentos.',
    createdAt: DateTime.utc(2026, 11, 1, 10, 1),
    updatedAt: DateTime.utc(2026, 11, 1, 10, 1),
    updatedBy: 'system',
  ),
  FaqModel(
    id: 'faq-pedir-ajuda',
    question: 'Como pedir ajuda a um adulto?',
    answer:
        'Escolha alguém em quem você confie — um familiar, professor, '
        'orientador ou a psicóloga da escola. Você pode começar dizendo que '
        'precisa conversar sobre algo que está te deixando desconfortável '
        'ou usar o canal anônimo do aplicativo.',
    createdAt: DateTime.utc(2026, 11, 1, 10, 2),
    updatedAt: DateTime.utc(2026, 11, 1, 10, 2),
    updatedBy: 'system',
  ),
  FaqModel(
    id: 'faq-saber-ansioso',
    question: 'Como saber se estou ansioso?',
    answer:
        'Coração acelerado, preocupação constante, dificuldade para se '
        'concentrar nas aulas ou alterações no sono são sinais comuns. '
        'Registrar como você se sente no diário ajuda a perceber quando '
        'esses sinais se repetem.',
    createdAt: DateTime.utc(2026, 11, 1, 10, 3),
    updatedAt: DateTime.utc(2026, 11, 1, 10, 3),
    updatedBy: 'system',
  ),
]);

/// Contrato de persistência para leitura e gestão do FAQ (RF04, RF08).
abstract class FaqRepository {
  Future<List<FaqModel>> list();

  Future<FaqModel> create({
    required String question,
    required String answer,
    required String updatedBy,
  });

  Future<FaqModel> update(FaqModel item);

  Future<void> delete(String id);
}

/// Repositório local (em memória + opcionalmente `SharedPreferences`) com
/// fallback para [defaultFaqItems]. Usado nos testes e em modo offline.
class LocalFaqRepository implements FaqRepository {
  LocalFaqRepository({this.storage, List<FaqModel>? initial})
    : _items = List<FaqModel>.from(initial ?? defaultFaqItems);

  static final LocalFaqRepository instance = LocalFaqRepository();

  static const cacheKey = 'faq_cache';

  final SharedPreferences? storage;
  final List<FaqModel> _items;
  int _counter = 0;

  void resetToDefaults() {
    _items
      ..clear()
      ..addAll(defaultFaqItems);
    _counter = 0;
  }

  void clear() {
    _items.clear();
    _counter = 0;
  }

  List<FaqModel>? _readCache() {
    final raw = storage?.getString(cacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => FaqModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(List<FaqModel> items) async {
    await storage?.setString(
      cacheKey,
      jsonEncode(items.map((e) => e.toMap()).toList()),
    );
  }

  @override
  Future<List<FaqModel>> list() async {
    final cached = _readCache();
    if (cached != null) {
      _items
        ..clear()
        ..addAll(cached);
    }
    return List.unmodifiable(_items);
  }

  @override
  Future<FaqModel> create({
    required String question,
    required String answer,
    required String updatedBy,
  }) async {
    final now = DateTime.now();
    _counter++;
    final created = FaqModel(
      id: 'faq-${now.microsecondsSinceEpoch}-$_counter',
      question: question.trim(),
      answer: answer.trim(),
      createdAt: now,
      updatedAt: now,
      updatedBy: updatedBy,
    );
    _items.insert(0, created);
    await _writeCache(_items);
    return created;
  }

  @override
  Future<FaqModel> update(FaqModel item) async {
    final updated = item.copyWith(
      question: item.question.trim(),
      answer: item.answer.trim(),
      updatedAt: DateTime.now(),
    );
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _items[index] = updated;
    } else {
      _items.insert(0, updated);
    }
    await _writeCache(_items);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _writeCache(_items);
  }
}

/// Repositório integrado à coleção `faq` do Cloud Firestore com cache local
/// em `SharedPreferences` e fallback offline automático (RF04, RF08, RNF02).
class FirestoreFaqRepository implements FaqRepository {
  FirestoreFaqRepository(this._firestore, {SharedPreferences? storage})
    : _fallback = LocalFaqRepository(storage: storage);

  final FirebaseFirestore _firestore;
  final LocalFaqRepository _fallback;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('faq');

  @override
  Future<List<FaqModel>> list() async {
    try {
      final snap = await _collection.orderBy('createdAt', descending: true).get();
      if (snap.docs.isNotEmpty) {
        final items = snap.docs
            .map((doc) => FaqModel.fromFirestore(doc, null))
            .toList();
        await _fallback._writeCache(items);
        return List.unmodifiable(items);
      }
    } catch (_) {
      // Sem internet ou erro do Firestore: usa cache local / defaultFaqItems.
    }
    return _fallback.list();
  }

  @override
  Future<FaqModel> create({
    required String question,
    required String answer,
    required String updatedBy,
  }) async {
    final now = DateTime.now();
    try {
      final docRef = _collection.doc();
      final item = FaqModel(
        id: docRef.id,
        question: question.trim(),
        answer: answer.trim(),
        createdAt: now,
        updatedAt: now,
        updatedBy: updatedBy,
      );
      await docRef.set(item.toFirestore());
      final current = List<FaqModel>.from(await _fallback.list());
      current.insert(0, item);
      await _fallback._writeCache(current);
      return item;
    } catch (_) {
      return _fallback.create(
        question: question,
        answer: answer,
        updatedBy: updatedBy,
      );
    }
  }

  @override
  Future<FaqModel> update(FaqModel item) async {
    final updated = item.copyWith(
      question: item.question.trim(),
      answer: item.answer.trim(),
      updatedAt: DateTime.now(),
    );
    try {
      await _collection.doc(item.id).set(
        updated.toFirestore(),
        SetOptions(merge: true),
      );
    } catch (_) {
      // Atualiza também o cache local mesmo se offline.
    }
    return _fallback.update(updated);
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (_) {
      // Remove também do cache local mesmo se offline.
    }
    await _fallback.delete(id);
  }
}
