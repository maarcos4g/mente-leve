import 'package:flutter/material.dart';
import 'package:mente_leve/modules/student/faq/student_faq_controller.dart';
import 'package:mente_leve/shared/faq/faq_repository.dart';
import 'package:mente_leve/shared/models/pergunta_faq.dart';

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

  List<PerguntaFaq> _items = const [];
  final Set<String> _expandedIds = {};
  PerguntaFaq? _editingItem;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<PerguntaFaq> get items => _items;
  PerguntaFaq? get editingItem => _editingItem;
  bool get isEditing => _editingItem != null;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  bool isExpanded(String id) => _expandedIds.contains(id);

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
      _items = await _repository.listar();
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
    if (_expandedIds.contains(id)) {
      _expandedIds.remove(id);
    } else {
      _expandedIds.add(id);
    }
    notifyListeners();
  }

  void iniciarEdicao(PerguntaFaq item) {
    _editingItem = item;
    notifyListeners();
  }

  void cancelarEdicao() {
    if (_editingItem == null) return;
    _editingItem = null;
    notifyListeners();
  }

  Future<bool> salvar({
    required String pergunta,
    required String resposta,
    String atualizadoPor = 'psicologa',
  }) async {
    if (_isSaving) return false;
    final trimmedTitle = pergunta.trim();
    final trimmedDesc = resposta.trim();
    if (trimmedTitle.isEmpty || trimmedDesc.isEmpty) return false;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_editingItem != null) {
        final atualizado = await _repository.atualizar(
          _editingItem!.copyWith(
            pergunta: trimmedTitle,
            resposta: trimmedDesc,
            atualizadoPor: atualizadoPor,
          ),
        );
        _editingItem = null;
        _items = await _repository.listar();
        _expandedIds.add(atualizado.id);
      } else {
        final criado = await _repository.criar(
          pergunta: trimmedTitle,
          resposta: trimmedDesc,
          atualizadoPor: atualizadoPor,
        );
        _items = await _repository.listar();
        _expandedIds.add(criado.id);
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
      await _repository.excluir(id);
      if (_editingItem?.id == id) {
        _editingItem = null;
      }
      _expandedIds.remove(id);
      _items = await _repository.listar();
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível excluir a pergunta.';
      notifyListeners();
      return false;
    }
  }
}
