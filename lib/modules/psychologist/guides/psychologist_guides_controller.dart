import 'package:flutter/foundation.dart';
import 'package:mente_leve/shared/guides/guide_repository.dart';
import 'package:mente_leve/shared/models/guide_model.dart';

/// Controlador da tela de gestão de Guias e Orientações da psicóloga
/// (`guias / edit` — RF08).
class PsychologistGuidesController extends ChangeNotifier {
  PsychologistGuidesController({GuideRepository? repository})
    : _repository =
          repository ?? defaultRepository ?? LocalGuideRepository.instance;

  /// Repositório padrão injetado no bootstrap (`main.dart`).
  static GuideRepository? defaultRepository;

  final GuideRepository _repository;

  List<GuideModel> _items = const [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _disposed = false;
  GuideModel? _editingItem;
  String? _revealedId;
  String? _errorMessage;
  String? _successMessage;

  List<GuideModel> get items => _items;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  GuideModel? get editingItem => _editingItem;
  bool get isEditing => _editingItem != null;
  String? get revealedId => _revealedId;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool isActionsRevealed(String id) => _revealedId == id;

  void revealActions(String id) {
    if (_revealedId == id) return;
    _revealedId = id;
    _notify();
  }

  void hideActions() {
    if (_revealedId == null) return;
    _revealedId = null;
    _notify();
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      _items = await _repository.list();
    } catch (_) {
      _errorMessage = 'Não foi possível carregar os guias publicados.';
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  void startEditing(GuideModel item) {
    _editingItem = item;
    _revealedId = null;
    _errorMessage = null;
    _successMessage = null;
    _notify();
  }

  void cancelEditing() {
    _editingItem = null;
    _errorMessage = null;
    _notify();
  }

  void clearFeedback() {
    _errorMessage = null;
    _successMessage = null;
    _notify();
  }

  Future<bool> save({
    required String title,
    required String description,
    required String text,
    String? category,
    required String authorUid,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedDescription = description.trim();
    final trimmedText = text.trim();
    final trimmedCategory = category?.trim();

    if (trimmedTitle.isEmpty) {
      _errorMessage = 'Informe o título do guia.';
      _notify();
      return false;
    }
    if (trimmedDescription.isEmpty) {
      _errorMessage = 'Informe a descrição resumida do guia.';
      _notify();
      return false;
    }
    if (trimmedText.isEmpty) {
      _errorMessage = 'Informe o texto informativo completo.';
      _notify();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    _notify();

    try {
      final resolvedCategory =
          (trimmedCategory != null && trimmedCategory.isNotEmpty)
              ? trimmedCategory
              : GuideModel.defaultCategory;

      if (_editingItem != null) {
        await _repository.update(
          _editingItem!.copyWith(
            title: trimmedTitle,
            description: trimmedDescription,
            text: trimmedText,
            category: resolvedCategory,
            authorUid: authorUid,
          ),
        );
        _editingItem = null;
        _successMessage = 'Guia atualizado com sucesso.';
      } else {
        await _repository.create(
          title: trimmedTitle,
          description: trimmedDescription,
          text: trimmedText,
          category: resolvedCategory,
          authorUid: authorUid,
        );
        _successMessage = 'Guia publicado com sucesso.';
      }
      _items = await _repository.list();
      return true;
    } catch (_) {
      _errorMessage =
          'Não foi possível publicar o guia. Verifique sua conexão e tente novamente.';
      return false;
    } finally {
      _isSaving = false;
      _notify();
    }
  }

  Future<bool> delete(String id) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    _notify();

    try {
      await _repository.delete(id);
      if (_editingItem?.id == id) {
        _editingItem = null;
      }
      if (_revealedId == id) {
        _revealedId = null;
      }
      _items = await _repository.list();
      _successMessage = 'Guia excluído com sucesso.';
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível excluir o guia. Tente novamente.';
      return false;
    } finally {
      _isSaving = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
