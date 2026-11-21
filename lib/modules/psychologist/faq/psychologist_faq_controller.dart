import 'package:flutter/material.dart';
import 'package:mente_leve/modules/student/faq/student_faq_controller.dart';
import 'package:mente_leve/shared/faq/faq_repository.dart';
import 'package:mente_leve/shared/models/faq_model.dart';

/// Controlador do Painel de Publicação e Edição do FAQ da psicóloga
/// (RF08 / SCRUM-36).
class PsychologistFaqController extends ChangeNotifier {
  PsychologistFaqController({FaqRepository? repository})
    : _repository =
          repository ??
          StudentFaqController.defaultRepository ??
          LocalFaqRepository.instance;

  final FaqRepository _repository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<FaqModel> _items = const [];
  final Set<String> _expandedIds = {};
  String? _revealedId;
  FaqModel? _editingItem;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<FaqModel> get items => _items;
  FaqModel? get editingItem => _editingItem;
  String? get revealedId => _revealedId;
  bool get isEditing => _editingItem != null;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  bool isExpanded(String id) => _expandedIds.contains(id);
  bool isRevealed(String id) => _revealedId == id;

  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o título da pergunta';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe a descrição da resposta';
    }
    return null;
  }

  Future<void> carregar() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _repository.list();
      if (_expandedIds.isEmpty && _items.isNotEmpty) {
        final highlight = _items.firstWhere(
          (e) => e.id == 'faq-lidar-ansiedade',
          orElse: () => _items.first,
        );
        _expandedIds.add(highlight.id);
      }
    } catch (_) {
      _errorMessage = 'Não foi possível carregar as perguntas do FAQ.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleExpanded(String id) {
    if (_revealedId == id) {
      _revealedId = null;
      notifyListeners();
      return;
    }
    if (_expandedIds.contains(id)) {
      _expandedIds.remove(id);
    } else {
      _expandedIds.add(id);
    }
    notifyListeners();
  }

  void revealActions(String id) {
    if (_revealedId == id) return;
    _revealedId = id;
    notifyListeners();
  }

  void hideActions() {
    if (_revealedId == null) return;
    _revealedId = null;
    notifyListeners();
  }

  void iniciarEdicao(FaqModel item) {
    _editingItem = item;
    _revealedId = null;
    notifyListeners();
  }

  void cancelarEdicao() {
    if (_editingItem == null) return;
    _editingItem = null;
    notifyListeners();
  }

  Future<bool> salvar({
    required String question,
    required String answer,
    String updatedBy = 'psychologist',
  }) async {
    if (_isSaving) return false;
    final trimmedTitle = question.trim();
    final trimmedDesc = answer.trim();
    if (trimmedTitle.isEmpty || trimmedDesc.isEmpty) return false;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_editingItem != null) {
        final updated = await _repository.update(
          _editingItem!.copyWith(
            question: trimmedTitle,
            answer: trimmedDesc,
            updatedBy: updatedBy,
          ),
        );
        _editingItem = null;
        _items = await _repository.list();
        _expandedIds.add(updated.id);
      } else {
        final created = await _repository.create(
          question: trimmedTitle,
          answer: trimmedDesc,
          updatedBy: updatedBy,
        );
        _items = await _repository.list();
        _expandedIds.add(created.id);
      }
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível salvar a pergunta no momento.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> excluir(String id) async {
    try {
      await _repository.delete(id);
      if (_editingItem?.id == id) {
        _editingItem = null;
      }
      if (_revealedId == id) {
        _revealedId = null;
      }
      _expandedIds.remove(id);
      _items = await _repository.list();
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível excluir a pergunta.';
      notifyListeners();
      return false;
    }
  }
}
