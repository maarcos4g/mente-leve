import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';

/// Contrato para persistência e recuperação dos registros do diário do aluno.
///
/// Atende às diretrizes:
/// - RNF02: Arquitetura Offline First (funciona 100% sem internet).
/// - RNF03: Armazenamento Local de Dados Sensíveis (nunca vai para nuvem).
abstract class DiaryRepository {
  /// Salva ou atualiza um registro de humor no diário local.
  Future<void> save(RegistroDiario registro);

  /// Retorna todos os registros do diário, ordenados do mais recente ao mais antigo.
  Future<List<RegistroDiario>> getAll();

  /// Retorna o registro mais recente ou nulo caso não haja entradas.
  Future<RegistroDiario?> getLatest();

  /// Exclui um registro pelo identificador.
  Future<void> delete(String id);

  /// Remove todos os registros (útil para testes ou redefinição).
  Future<void> clear();
}

/// Implementação padrão em memória / local com ordenação cronológica decrescente.
///
/// Projetada para operação local imediata, totalmente offline e compatível
/// com a camada de persistência definitiva (Hive/SQLite) de RNF03.
class LocalDiaryRepository implements DiaryRepository {
  /// Construtor público permitindo instâncias isoladas (útil para testes unitários).
  LocalDiaryRepository([Map<String, RegistroDiario>? initialStorage]) {
    if (initialStorage != null) {
      _storage.addAll(initialStorage);
    }
  }

  static final LocalDiaryRepository _instance = LocalDiaryRepository();

  /// Instância singleton compartilhada na aplicação.
  static LocalDiaryRepository get instance => _instance;

  /// Armazena os registros em cache local ordenado.
  final Map<String, RegistroDiario> _storage = {};

  @override
  Future<void> save(RegistroDiario registro) async {
    _storage[registro.id] = registro;
  }

  @override
  Future<List<RegistroDiario>> getAll() async {
    final list = _storage.values.toList();
    list.sort((a, b) => b.dataHora.compareTo(a.dataHora));
    return List.unmodifiable(list);
  }

  @override
  Future<RegistroDiario?> getLatest() async {
    final list = await getAll();
    if (list.isEmpty) return null;
    return list.first;
  }

  @override
  Future<void> delete(String id) async {
    _storage.remove(id);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }

  /// Retorna o total de registros salvos.
  int get count => _storage.length;
}
