import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/psychologist/guides/psychologist_guides_controller.dart';
import 'package:mente_leve/shared/auth/auth_notifier.dart';
import 'package:mente_leve/shared/models/guide_model.dart';
import 'package:mente_leve/shared/models/session_model.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/widgets/guides/guide_card.dart';
import 'package:provider/provider.dart';

/// Tela "Orientações" (`guias / edit`) do painel da psicóloga escolar para
/// publicar, editar e remover guias informativos acessados pelos responsáveis
/// (RF08 / coleção `guides`).
class PsychologistGuidesView extends StatefulWidget {
  const PsychologistGuidesView({super.key, this.controller, this.authorUid});

  static const routeName = '/psychologist/guides';

  final PsychologistGuidesController? controller;
  final String? authorUid;

  @override
  State<PsychologistGuidesView> createState() => _PsychologistGuidesViewState();
}

class _PsychologistGuidesViewState extends State<PsychologistGuidesView> {
  late final PsychologistGuidesController _controller;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController(
    text: GuideModel.defaultCategory,
  );
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? PsychologistGuidesController();
    _controller.addListener(_onChanged);
    _controller.load();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _resolveAuthorUid() {
    if (widget.authorUid != null && widget.authorUid!.isNotEmpty) {
      return widget.authorUid!;
    }
    try {
      final session = context.read<AuthNotifier>().session;
      if (session is InstitutionalSession) {
        return session.user.uid;
      }
    } catch (_) {
      // Provider pode não estar montado em testes isolados.
    }
    return 'psychologist';
  }

  void _resetForm() {
    _titleController.clear();
    _categoryController.text = GuideModel.defaultCategory;
    _descriptionController.clear();
    _textController.clear();
  }

  Future<void> _handleSave() async {
    final saved = await _controller.save(
      title: _titleController.text,
      description: _descriptionController.text,
      text: _textController.text,
      category: _categoryController.text,
      authorUid: _resolveAuthorUid(),
    );
    if (!mounted) return;
    if (saved) {
      _resetForm();
      FocusScope.of(context).unfocus();
      final feedback = _controller.successMessage;
      if (feedback != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(feedback)));
      }
    }
  }

  void _handleEdit(GuideModel item) {
    _controller.startEditing(item);
    _titleController.text = item.title;
    _categoryController.text = item.displayCategory;
    _descriptionController.text = item.description;
    _textController.text = item.text;
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleCancelEdit() {
    _controller.cancelEditing();
    _resetForm();
  }

  Future<void> _handleDelete(GuideModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(
              'Excluir guia',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Tem certeza que deseja excluir "${item.title}"? Os responsáveis '
              'deixarão de ver este conteúdo.',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                key: const Key('guide_confirm_delete_button'),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                ),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;
    final deleted = await _controller.delete(item.id);
    if (!mounted) return;
    if (deleted && _controller.successMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_controller.successMessage!)));
    }
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.slate600),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF9F9FA9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF9F9FA9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.sky700, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _controller.items;
    final currentCategory = _categoryController.text.trim();

    return Scaffold(
      backgroundColor: AppColors.zinc50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GuidesAppBar(onBack: () => Navigator.of(context).maybePop()),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE4E4E7)),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Guias e Orientações',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.zinc950,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Gerencie as informações acessadas pelos responsáveis',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              color: AppColors.slate600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FieldLabel('Título'),
                          const SizedBox(height: 8),
                          TextField(
                            key: const Key('guide_title_field'),
                            controller: _titleController,
                            textInputAction: TextInputAction.next,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.zinc950,
                            ),
                            decoration: _inputDecoration(
                              hintText:
                                  'Ex.: Como identificar sinais de ansiedade?',
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FieldLabel('Categoria (opcional)'),
                          const SizedBox(height: 8),
                          TextField(
                            key: const Key('guide_category_field'),
                            controller: _categoryController,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => setState(() {}),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.zinc950,
                            ),
                            decoration: _inputDecoration(
                              hintText: GuideModel.defaultCategory,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              for (final cat in GuideModel.suggestedCategories)
                                ChoiceChip(
                                  key: Key(
                                    'guide_category_chip_${cat.toLowerCase().replaceAll(' ', '_')}',
                                  ),
                                  label: Text(
                                    cat,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          currentCategory.toLowerCase() ==
                                                  cat.toLowerCase()
                                              ? Colors.white
                                              : AppColors.zinc950,
                                    ),
                                  ),
                                  selected:
                                      currentCategory.toLowerCase() ==
                                      cat.toLowerCase(),
                                  selectedColor: AppColors.sky700,
                                  backgroundColor: Colors.white,
                                  showCheckmark: false,
                                  side: BorderSide(
                                    color:
                                        currentCategory.toLowerCase() ==
                                                cat.toLowerCase()
                                            ? AppColors.sky700
                                            : const Color(0xFFD4D4D8),
                                  ),
                                  onSelected: (_) {
                                    setState(() {
                                      _categoryController.text = cat;
                                    });
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _FieldLabel('Descrição'),
                          const SizedBox(height: 8),
                          TextField(
                            key: const Key('guide_description_field'),
                            controller: _descriptionController,
                            minLines: 3,
                            maxLines: 5,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.zinc950,
                            ),
                            decoration: _inputDecoration(
                              hintText:
                                  'Resumo curto exibido no card da tela dos responsáveis...',
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FieldLabel('Texto Informativo'),
                          const SizedBox(height: 8),
                          TextField(
                            key: const Key('guide_text_field'),
                            controller: _textController,
                            minLines: 4,
                            maxLines: 8,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.zinc950,
                            ),
                            decoration: _inputDecoration(
                              hintText:
                                  'Escreva a orientação completa que será lida pelos responsáveis...',
                            ),
                          ),
                          if (_controller.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _controller.errorMessage!,
                              key: const Key('guide_error_text'),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFB91C1C),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    key: const Key('guide_submit_button'),
                                    onPressed:
                                        _controller.isSaving
                                            ? null
                                            : _handleSave,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.sky700,
                                      foregroundColor: AppColors.zinc50,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: Text(
                                      _controller.isSaving
                                          ? 'Salvando...'
                                          : _controller.isEditing
                                          ? 'Atualizar'
                                          : 'Salvar',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (_controller.isEditing) ...[
                                const SizedBox(width: 10),
                                SizedBox(
                                  height: 48,
                                  child: OutlinedButton(
                                    key: const Key('guide_cancel_edit_button'),
                                    onPressed:
                                        _controller.isSaving
                                            ? null
                                            : _handleCancelEdit,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.zinc950,
                                      side: const BorderSide(
                                        color: Color(0xFFD4D4D8),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancelar',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFD4D4D8),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Guias publicados (${items.length})',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.zinc950,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Arraste um card para a esquerda para editar ou excluir.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.slate600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_controller.isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (items.isEmpty)
                            Container(
                              key: const Key('psychologist_guides_empty'),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE4E4E7),
                                ),
                              ),
                              child: Text(
                                'Nenhum guia publicado até o momento. Use o '
                                'formulário acima para cadastrar o primeiro.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.slate600,
                                ),
                              ),
                            )
                          else
                            for (var i = 0; i < items.length; i++) ...[
                              _SwipeableGuideCard(
                                guide: items[i],
                                colorIndex: i,
                                actionsVisible: _controller.isActionsRevealed(
                                  items[i].id,
                                ),
                                onReveal:
                                    () =>
                                        _controller.revealActions(items[i].id),
                                onHide: _controller.hideActions,
                                onEdit: () => _handleEdit(items[i]),
                                onDelete: () => _handleDelete(items[i]),
                              ),
                              const SizedBox(height: 16),
                            ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.zinc950,
      ),
    );
  }
}

class _GuidesAppBar extends StatelessWidget {
  const _GuidesAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            key: const Key('psychologist_guides_back_button'),
            onPressed: onBack,
            tooltip: 'Voltar',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const Icon(
              LucideIcons.chevronLeft,
              size: 24,
              color: AppColors.zinc950,
            ),
          ),
          Expanded(
            child: Text(
              'Orientações',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.zinc950,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

/// Card de guia com revelação exclusiva das ações Editar/Excluir ao arrastar
/// para o lado esquerdo, seguindo o mesmo padrão UX da tela de FAQ da psicóloga.
class _SwipeableGuideCard extends StatefulWidget {
  const _SwipeableGuideCard({
    required this.guide,
    required this.colorIndex,
    required this.actionsVisible,
    required this.onReveal,
    required this.onHide,
    required this.onEdit,
    required this.onDelete,
  });

  final GuideModel guide;
  final int colorIndex;
  final bool actionsVisible;
  final VoidCallback onReveal;
  final VoidCallback onHide;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_SwipeableGuideCard> createState() => _SwipeableGuideCardState();
}

class _SwipeableGuideCardState extends State<_SwipeableGuideCard> {
  double _dragDelta = 0;

  void _handleDragUpdate(DragUpdateDetails details) {
    _dragDelta += details.primaryDelta ?? 0;
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_dragDelta < -24 || velocity < -150) {
      widget.onReveal();
    } else if (_dragDelta > 24 || velocity > 150) {
      widget.onHide();
    }
    _dragDelta = 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('guide_swipe_${widget.guide.id}'),
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => _dragDelta = 0,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GuideCard(
              guide: widget.guide,
              colorIndex: widget.colorIndex,
              onTap: widget.actionsVisible ? widget.onHide : null,
            ),
          ),
          if (widget.actionsVisible) ...[
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SwipeActionButton(
                  buttonKey: Key('guide_edit_${widget.guide.id}'),
                  tooltip: 'Editar guia',
                  backgroundColor: AppColors.sky700,
                  icon: LucideIcons.pencil,
                  onPressed: widget.onEdit,
                ),
                const SizedBox(height: 8),
                _SwipeActionButton(
                  buttonKey: Key('guide_delete_${widget.guide.id}'),
                  tooltip: 'Excluir guia',
                  backgroundColor: const Color(0xFFDC2626),
                  icon: LucideIcons.trash2,
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SwipeActionButton extends StatelessWidget {
  const _SwipeActionButton({
    required this.buttonKey,
    required this.tooltip,
    required this.backgroundColor,
    required this.icon,
    required this.onPressed,
  });

  final Key buttonKey;
  final String tooltip;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            key: buttonKey,
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
