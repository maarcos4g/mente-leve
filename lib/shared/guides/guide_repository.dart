import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mente_leve/shared/models/guide_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guias iniciais curados a partir do protótipo de alta fidelidade (RF11),
/// usados como conteúdo inicial e fallback offline quando não há cache salvo.
final List<GuideModel> defaultGuideItems = List.unmodifiable([
  GuideModel(
    id: 'guide-sinais-ansiedade',
    title: 'Como identificar sinais de ansiedade?',
    description:
        'Aprenda a diferenciar o medo comum de um quadro de ansiedade que '
        'precisa de atenção.',
    text:
        'Sentir nervosismo antes de uma prova ou apresentação é natural. '
        'Porém, quando a preocupação se torna constante e passa a atrapalhar '
        'o sono, o apetite, o rendimento escolar ou o convívio social, pode '
        'indicar um quadro de ansiedade.\n\n'
        'Fique atento a sinais como isolamento repentino, queixas frequentes '
        'de dor de cabeça ou dor de barriga antes das aulas, irritabilidade '
        'excessiva e dificuldade para se concentrar.\n\n'
        'Ofereça escuta acolhedora sem minimizar o que o adolescente sente e, '
        'sempre que necessário, procure a equipe de psicologia da escola.',
    category: 'Saúde Mental Juvenil',
    createdAt: DateTime.utc(2026, 11, 1, 10, 0),
    updatedAt: DateTime.utc(2026, 11, 1, 10, 0),
    authorUid: 'system',
  ),
  GuideModel(
    id: 'guide-dialogo-bullying',
    title: 'Como conversar sobre bullying em casa?',
    description:
        'Estratégias de escuta ativa para apoiar seu filho sem julgamentos e '
        'fortalecer a confiança.',
    text:
        'Muitos adolescentes escondem situações de bullying ou cyberbullying '
        'por medo de represálias ou de serem culpabilizados. Criar um espaço '
        'seguro de conversa faz toda a diferença.\n\n'
        'Escolha um momento calmo, ouça até o fim sem interromper, valide os '
        'sentimentos do jovem e deixe claro que a responsabilidade nunca é da '
        'vítima.\n\n'
        'Guarde registros caso o episódio ocorra em redes sociais e alinhe os '
        'próximos passos em parceria com a coordenação pedagógica e a '
        'psicóloga escolar.',
    category: 'Prevenção ao Bullying',
    createdAt: DateTime.utc(2026, 11, 1, 10, 5),
    updatedAt: DateTime.utc(2026, 11, 1, 10, 5),
    authorUid: 'system',
  ),
]);

/// Contrato de persistência para leitura (pais) e gestão (psicóloga) dos guias
/// e orientações (RF08, RF11).
abstract class GuideRepository {
  Future<List<GuideModel>> list();

  Future<GuideModel> create({
    required String title,
    required String description,
    required String text,
    String? category,
    required String authorUid,
  });

  Future<GuideModel> update(GuideModel item);

  Future<void> delete(String id);
}

/// Repositório local (em memória + opcionalmente `SharedPreferences`) com
/// fallback para [defaultGuideItems]. Usado em testes e modo offline.
class LocalGuideRepository implements GuideRepository {
  LocalGuideRepository({this.storage, List<GuideModel>? initial})
    : _items = List<GuideModel>.from(initial ?? defaultGuideItems);

  static final LocalGuideRepository instance = LocalGuideRepository();

  static const cacheKey = 'guides_cache';

  final SharedPreferences? storage;
  final List<GuideModel> _items;
  int _counter = 0;

  void resetToDefaults() {
    _items
      ..clear()
      ..addAll(defaultGuideItems);
    _counter = 0;
  }

  void clear() {
    _items.clear();
    _counter = 0;
  }

  List<GuideModel>? _readCache() {
    final raw = storage?.getString(cacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((e) => GuideModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(List<GuideModel> items) async {
    await storage?.setString(
      cacheKey,
      jsonEncode(items.map((e) => e.toMap()).toList()),
    );
  }

  @override
  Future<List<GuideModel>> list() async {
    final cached = _readCache();
    if (cached != null) {
      _items
        ..clear()
        ..addAll(cached);
    }
    return List.unmodifiable(_items);
  }

  @override
  Future<GuideModel> create({
    required String title,
    required String description,
    required String text,
    String? category,
    required String authorUid,
  }) async {
    final now = DateTime.now();
    _counter++;
    final trimmedCategory = category?.trim();
    final created = GuideModel(
      id: 'guide-${now.microsecondsSinceEpoch}-$_counter',
      title: title.trim(),
      description: description.trim(),
      text: text.trim(),
      category:
          (trimmedCategory != null && trimmedCategory.isNotEmpty)
              ? trimmedCategory
              : null,
      createdAt: now,
      updatedAt: now,
      authorUid: authorUid,
    );
    _items.insert(0, created);
    await _writeCache(_items);
    return created;
  }

  @override
  Future<GuideModel> update(GuideModel item) async {
    final trimmedCategory = item.category?.trim();
    final updated = item.copyWith(
      title: item.title.trim(),
      description: item.description.trim(),
      text: item.text.trim(),
      category:
          (trimmedCategory != null && trimmedCategory.isNotEmpty)
              ? trimmedCategory
              : null,
      clearCategory: trimmedCategory == null || trimmedCategory.isEmpty,
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

/// Repositório integrado à coleção `guides` do Cloud Firestore com cache local
/// em `SharedPreferences` e resiliência offline (RF08, RF11, RNF02).
class FirestoreGuideRepository implements GuideRepository {
  FirestoreGuideRepository(
    this._firestore, {
    SharedPreferences? storage,
    this.writeWait = const Duration(seconds: 2),
    this.readWait = const Duration(seconds: 6),
    this.offlineReadWait = const Duration(seconds: 1),
  }) : _fallback = LocalGuideRepository(storage: storage);

  final FirebaseFirestore _firestore;
  final LocalGuideRepository _fallback;
  final Duration writeWait;
  final Duration readWait;
  final Duration offlineReadWait;

  bool _semRede = false;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('guides');

  Future<void> _write(Future<void> write) async {
    var respondeu = true;
    // Garante que uma rejeição tardia após o timeout não vire erro sem tratador.
    unawaited(write.catchError((_) {}));
    await write.timeout(writeWait, onTimeout: () => respondeu = false);
    _semRede = !respondeu;
  }

  @override
  Future<List<GuideModel>> list() async {
    try {
      final snap = await _collection
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(_semRede ? offlineReadWait : readWait);
      _semRede = false;
      if (snap.docs.isNotEmpty) {
        final items = <GuideModel>[];
        for (final doc in snap.docs) {
          try {
            items.add(GuideModel.fromFirestore(doc, null));
          } catch (_) {
            // Isola eventual documento malformado sem derrubar toda a lista.
          }
        }
        if (items.isNotEmpty) {
          await _fallback._writeCache(items);
          return List.unmodifiable(items);
        }
      }
    } catch (_) {
      // Sem internet ou falha do Firestore: usa cache local / guias padrão.
    }
    return _fallback.list();
  }

  @override
  Future<GuideModel> create({
    required String title,
    required String description,
    required String text,
    String? category,
    required String authorUid,
  }) async {
    final now = DateTime.now();
    final trimmedCategory = category?.trim();
    try {
      final docRef = _collection.doc();
      final item = GuideModel(
        id: docRef.id,
        title: title.trim(),
        description: description.trim(),
        text: text.trim(),
        category:
            (trimmedCategory != null && trimmedCategory.isNotEmpty)
                ? trimmedCategory
                : null,
        createdAt: now,
        updatedAt: now,
        authorUid: authorUid,
      );
      await _write(docRef.set(item.toFirestore()));
      final current = List<GuideModel>.from(await _fallback.list());
      current.insert(0, item);
      await _fallback._writeCache(current);
      return item;
    } catch (_) {
      return _fallback.create(
        title: title,
        description: description,
        text: text,
        category: category,
        authorUid: authorUid,
      );
    }
  }

  @override
  Future<GuideModel> update(GuideModel item) async {
    final trimmedCategory = item.category?.trim();
    final updated = item.copyWith(
      title: item.title.trim(),
      description: item.description.trim(),
      text: item.text.trim(),
      category:
          (trimmedCategory != null && trimmedCategory.isNotEmpty)
              ? trimmedCategory
              : null,
      clearCategory: trimmedCategory == null || trimmedCategory.isEmpty,
      updatedAt: DateTime.now(),
    );
    try {
      await _write(
        _collection
            .doc(item.id)
            .set(updated.toFirestore(), SetOptions(merge: true)),
      );
    } catch (_) {
      // Atualiza também o cache local mesmo se offline.
    }
    return _fallback.update(updated);
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _write(_collection.doc(id).delete());
    } catch (_) {
      // Remove também do cache local mesmo se offline.
    }
    await _fallback.delete(id);
  }
}
