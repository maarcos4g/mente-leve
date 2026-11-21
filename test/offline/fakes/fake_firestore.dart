// As classes do Firestore são marcadas como "sealed" para o app; num fake de
// teste implementá-las é o esperado (o pacote fake_cloud_firestore faz igual).
// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore simulado para a bateria offline (EPIC-09).
///
/// Imita o comportamento real sem internet: a escrita é guardada numa fila
/// local e o `Future` só termina quando a conexão volta ([reconnect]). A
/// leitura sem rede falha com `unavailable` ou, com [hangReads], demora sem
/// responder, como numa rede instável.
class FakeFirestore implements FirebaseFirestore {
  bool online = true;

  /// Leitura que nunca responde (rede instável), em vez de falhar.
  bool hangReads = false;

  /// Documentos que o "servidor" já tem.
  final Map<String, Map<String, dynamic>> server = {};

  /// Escritas feitas sem internet, esperando a conexão voltar.
  final List<PendingWrite> pending = [];

  int _ids = 0;

  /// Volta a conexão: aplica a fila no servidor e libera quem esperava.
  void reconnect() {
    online = true;
    for (final write in pending) {
      write.apply(server);
      write.completer.complete();
    }
    pending.clear();
  }

  Future<void> _write(PendingWrite write) {
    if (online) {
      write.apply(server);
      return Future.value();
    }
    pending.add(write);
    return write.completer.future;
  }

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _FakeCollection(this);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class PendingWrite {
  PendingWrite.set(this.id, this.data, {this.merge = false}) : delete = false;
  PendingWrite.delete(this.id) : data = null, merge = false, delete = true;

  final String id;
  final Map<String, dynamic>? data;
  final bool merge;
  final bool delete;
  final Completer<void> completer = Completer<void>();

  void apply(Map<String, Map<String, dynamic>> server) {
    if (delete) {
      server.remove(id);
      return;
    }
    // Como no servidor real, `FieldValue.serverTimestamp()` vira uma data.
    final resolved = data!.map(
      (key, value) =>
          MapEntry(key, value is FieldValue ? Timestamp.now() : value),
    );
    server[id] = merge && server[id] != null
        ? {...server[id]!, ...resolved}
        : resolved;
  }
}

class _FakeCollection implements CollectionReference<Map<String, dynamic>> {
  _FakeCollection(this._db);

  final FakeFirestore _db;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      _FakeDoc(_db, path ?? 'doc-${++_db._ids}');

  @override
  Query<Map<String, dynamic>> orderBy(
    Object field, {
    bool descending = false,
  }) => this;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) {
    if (_db.hangReads) return Completer<Never>().future;
    if (!_db.online) {
      return Future.error(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );
    }
    final docs = _db.server.entries
        .map((e) => _FakeQueryDoc(e.key, Map.of(e.value)))
        .toList();
    return Future.value(_FakeQuerySnapshot(docs));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDoc implements DocumentReference<Map<String, dynamic>> {
  _FakeDoc(this._db, this.id);

  final FakeFirestore _db;

  @override
  final String id;

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) =>
      _db._write(PendingWrite.set(id, data, merge: options?.merge ?? false));

  @override
  Future<void> delete() => _db._write(PendingWrite.delete(id));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeQuerySnapshot implements QuerySnapshot<Map<String, dynamic>> {
  _FakeQuerySnapshot(this.docs);

  @override
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeQueryDoc implements QueryDocumentSnapshot<Map<String, dynamic>> {
  _FakeQueryDoc(this.id, this._data);

  @override
  final String id;

  final Map<String, dynamic> _data;

  @override
  Map<String, dynamic> data() => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
