import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mente_leve/shared/models/pergunta_faq.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Perguntas e respostas curadas do protótipo de alta fidelidade (RF04),
/// utilizadas como conteúdo inicial e fallback offline quando não há cache.
final List<PerguntaFaq> defaultFaqItems = List.unmodifiable([
  PerguntaFaq(
    id: 'faq-cyberbullying',
    pergunta: 'O que é cyberbullying',
    resposta:
        'Cyberbullying é a intimidação, humilhação ou agressão repetida '
        'feita por meio de redes sociais, aplicativos de mensagens ou jogos '
        'online. Você não tem culpa pelo que está acontecendo: guarde provas '
        '(prints) e procure um adulto de confiança ou a equipe da escola.',
    criadoEm: DateTime.utc(2026, 11, 1, 10, 0),
    atualizadoEm: DateTime.utc(2026, 11, 1, 10, 0),
    atualizadoPor: 'sistema',
  ),
  PerguntaFaq(
    id: 'faq-lidar-ansiedade',
    pergunta: 'Como lidar com a ansiedade?',
    resposta:
        'Respire fundo, foque no presente e lembre-se que sentimentos ruins '
        'passam. Se precisar, converse anonimamente no nosso canal ou '
        'registre no diário para clarear seus pensamentos.',
    criadoEm: DateTime.utc(2026, 11, 1, 10, 1),
    atualizadoEm: DateTime.utc(2026, 11, 1, 10, 1),
    atualizadoPor: 'sistema',
  ),
  PerguntaFaq(
    id: 'faq-pedir-ajuda',
    pergunta: 'Como pedir ajuda a um adulto?',
    resposta:
        'Escolha alguém em quem você confie — um familiar, professor, '
        'orientador ou a psicóloga da escola. Você pode começar dizendo que '
        'precisa conversar sobre algo que está te deixando desconfortável '
        'ou usar o canal anônimo do aplicativo.',
    criadoEm: DateTime.utc(2026, 11, 1, 10, 2),
    atualizadoEm: DateTime.utc(2026, 11, 1, 10, 2),
    atualizadoPor: 'sistema',
  ),
  PerguntaFaq(
    id: 'faq-saber-ansioso',
    pergunta: 'Como saber se estou ansioso?',
    resposta:
        'Coração acelerado, preocupação constante, dificuldade para se '
        'concentrar nas aulas ou alterações no sono são sinais comuns. '
        'Registrar como você se sente no diário ajuda a perceber quando '
        'esses sinais se repetem.',
    criadoEm: DateTime.utc(2026, 11, 1, 10, 3),
    atualizadoEm: DateTime.utc(2026, 11, 1, 10, 3),
    atualizadoPor: 'sistema',
  ),
]);

/// Contrato de persistência para leitura e gestão do FAQ (RF04, RF08).
abstract class FaqRepository {
  Future<List<PerguntaFaq>> listar();

  Future<PerguntaFaq> criar({
    required String pergunta,
    required String resposta,
    required String atualizadoPor,
  });

  Future<PerguntaFaq> atualizar(PerguntaFaq item);

  Future<void> excluir(String id);
}

/// Repositório local (em memória + opcionalmente `SharedPreferences`) com
/// fallback para [defaultFaqItems]. Usado nos testes e em modo offline.
class LocalFaqRepository implements FaqRepository {
  LocalFaqRepository({this.storage, List<PerguntaFaq>? initial})
    : _items = List<PerguntaFaq>.from(initial ?? defaultFaqItems);

  static final LocalFaqRepository instance = LocalFaqRepository();

  static const cacheKey = 'faq_cache';

  final SharedPreferences? storage;
  final List<PerguntaFaq> _items;
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

  List<PerguntaFaq>? _readCache() {
    final raw = storage?.getString(cacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => PerguntaFaq.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(List<PerguntaFaq> items) async {
    await storage?.setString(
      cacheKey,
      jsonEncode(items.map((e) => e.toMap()).toList()),
    );
  }

  @override
  Future<List<PerguntaFaq>> listar() async {
    final cached = _readCache();
    if (cached != null) {
      _items
        ..clear()
        ..addAll(cached);
    }
    return List.unmodifiable(_items);
  }

  @override
  Future<PerguntaFaq> criar({
    required String pergunta,
    required String resposta,
    required String atualizadoPor,
  }) async {
    final now = DateTime.now();
    _counter++;
    final novo = PerguntaFaq(
      id: 'faq-${now.microsecondsSinceEpoch}-$_counter',
      pergunta: pergunta.trim(),
      resposta: resposta.trim(),
      criadoEm: now,
      atualizadoEm: now,
      atualizadoPor: atualizadoPor,
    );
    _items.insert(0, novo);
    await _writeCache(_items);
    return novo;
  }

  @override
  Future<PerguntaFaq> atualizar(PerguntaFaq item) async {
    final atualizada = item.copyWith(
      pergunta: item.pergunta.trim(),
      resposta: item.resposta.trim(),
      atualizadoEm: DateTime.now(),
    );
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _items[index] = atualizada;
    } else {
      _items.insert(0, atualizada);
    }
    await _writeCache(_items);
    return atualizada;
  }

  @override
  Future<void> excluir(String id) async {
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
  Future<List<PerguntaFaq>> listar() async {
    try {
      final snap = await _collection.orderBy('criadoEm', descending: true).get();
      if (snap.docs.isNotEmpty) {
        final items = snap.docs
            .map((doc) => PerguntaFaq.fromFirestore(doc, null))
            .toList();
        await _fallback._writeCache(items);
        return List.unmodifiable(items);
      }
    } catch (_) {
      // Sem internet ou erro do Firestore: usa cache local / defaultFaqItems.
    }
    return _fallback.listar();
  }

  @override
  Future<PerguntaFaq> criar({
    required String pergunta,
    required String resposta,
    required String atualizadoPor,
  }) async {
    final now = DateTime.now();
    try {
      final docRef = _collection.doc();
      final item = PerguntaFaq(
        id: docRef.id,
        pergunta: pergunta.trim(),
        resposta: resposta.trim(),
        criadoEm: now,
        atualizadoEm: now,
        atualizadoPor: atualizadoPor,
      );
      await docRef.set(item.toFirestore());
      final current = List<PerguntaFaq>.from(await _fallback.listar());
      current.insert(0, item);
      await _fallback._writeCache(current);
      return item;
    } catch (_) {
      return _fallback.criar(
        pergunta: pergunta,
        resposta: resposta,
        atualizadoPor: atualizadoPor,
      );
    }
  }

  @override
  Future<PerguntaFaq> atualizar(PerguntaFaq item) async {
    final atualizada = item.copyWith(
      pergunta: item.pergunta.trim(),
      resposta: item.resposta.trim(),
      atualizadoEm: DateTime.now(),
    );
    try {
      await _collection.doc(item.id).set(
        atualizada.toFirestore(),
        SetOptions(merge: true),
      );
    } catch (_) {
      // Atualiza também o cache local mesmo se offline.
    }
    return _fallback.atualizar(atualizada);
  }

  @override
  Future<void> excluir(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (_) {
      // Remove também do cache local mesmo se offline.
    }
    await _fallback.excluir(id);
  }
}
