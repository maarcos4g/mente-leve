import 'package:flutter/foundation.dart';
import 'package:mente_leve/shared/faq/faq_repository.dart';
import 'package:mente_leve/shared/models/pergunta_faq.dart';

/// Controlador da tela de Canais de Apoio & FAQ do estudante (RF04 / SCRUM-33).
class StudentFaqController extends ChangeNotifier {
  StudentFaqController({FaqRepository? repository})
    : _repository =
          repository ?? defaultRepository ?? LocalFaqRepository.instance;

  /// Repositório padrão injetado no bootstrap (`main.dart`).
  static FaqRepository? defaultRepository;

  final FaqRepository _repository;

  List<PerguntaFaq> _allItems = const [];
  final Set<String> _expandedIds = {};
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<PerguntaFaq> get items {
    if (_searchQuery.trim().isEmpty) return _allItems;
    return _allItems
        .where((item) => item.corresponde(_searchQuery))
        .toList(growable: false);
  }

  bool isExpanded(String id) => _expandedIds.contains(id);

  Future<void> carregar() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _allItems = await _repository.listar();
      // Expande por padrão a pergunta de destaque do protótipo se nenhuma
      // estiver aberta ainda.
      if (_expandedIds.isEmpty && _allItems.isNotEmpty) {
        final highlight = _allItems.firstWhere(
          (e) => e.id == 'faq-lidar-ansiedade',
          orElse: () => _allItems.first,
        );
        _expandedIds.add(highlight.id);
      }
    } catch (_) {
      _errorMessage = 'Não foi possível carregar as dúvidas no momento.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleExpanded(String id) {
    if (_expandedIds.contains(id)) {
      _expandedIds.remove(id);
    } else {
      _expandedIds.add(id);
    }
    notifyListeners();
  }

  void filtrar(String termo) {
    if (_searchQuery == termo) return;
    _searchQuery = termo;
    notifyListeners();
  }
}
