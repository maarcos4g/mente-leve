import 'package:flutter/foundation.dart';
import 'package:mente_leve/shared/guides/guide_repository.dart';
import 'package:mente_leve/shared/models/guide_model.dart';

/// Controlador da Home dos pais e responsáveis (`home / parents` — RF11).
///
/// Carrega os guias informativos publicados pela psicóloga na coleção `guides`
/// do Cloud Firestore com fallback em cache local.
class ParentsHomeController extends ChangeNotifier {
  ParentsHomeController({GuideRepository? repository})
    : _repository =
          repository ?? defaultRepository ?? LocalGuideRepository.instance;

  /// Repositório padrão injetado no bootstrap (`main.dart`).
  static GuideRepository? defaultRepository;

  final GuideRepository _repository;

  List<GuideModel> _guides = const [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  bool _disposed = false;
  String? _errorMessage;

  List<GuideModel> get guides => _guides;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      _guides = await _repository.list();
    } catch (_) {
      _errorMessage =
          'Não foi possível carregar os guias agora. Verifique sua conexão e '
          'tente novamente.';
    } finally {
      _isLoading = false;
      _hasLoaded = true;
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
