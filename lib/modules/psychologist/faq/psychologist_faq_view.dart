import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/psychologist/faq/psychologist_faq_controller.dart';
import 'package:mente_leve/shared/auth/auth_notifier.dart';
import 'package:mente_leve/shared/models/pergunta_faq.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/widgets/faq/faq_expandable_card.dart';
import 'package:provider/provider.dart';

/// Painel administrativo de publicação, edição e exclusão de conteúdos do FAQ
/// pela psicóloga escolar (RF08 / SCRUM-36), fiel ao protótipo do Figma.
class PsychologistFaqView extends StatefulWidget {
  const PsychologistFaqView({super.key, this.controller, this.authorUid});

  final PsychologistFaqController? controller;
  final String? authorUid;

  static const routeName = '/psychologist/faq';

  @override
  State<PsychologistFaqView> createState() => _PsychologistFaqViewState();
}

class _PsychologistFaqViewState extends State<PsychologistFaqView> {
  late final PsychologistFaqController _controller;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? PsychologistFaqController();
    _controller.addListener(_onChanged);
    _controller.carregar();
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
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _resolveAuthorUid() {
    if (widget.authorUid != null) return widget.authorUid!;
    try {
      final session = context.read<AuthNotifier>().session;
      if (session != null) return session.uid;
    } catch (_) {
      // Provider não presente em testes isolados.
    }
    return 'psicologa';
  }

  void _selectForEdit(PerguntaFaq item) {
    _controller.iniciarEdicao(item);
    _titleController.text = item.pergunta;
    _descriptionController.text = item.resposta;
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _cancelEdit() {
    _controller.cancelarEdicao();
    _titleController.clear();
    _descriptionController.clear();
  }

  Future<void> _submit() async {
    if (!(_controller.formKey.currentState?.validate() ?? false)) return;
    final wasEditing = _controller.isEditing;
    final success = await _controller.salvar(
      pergunta: _titleController.text,
      resposta: _descriptionController.text,
      atualizadoPor: _resolveAuthorUid(),
    );
    if (!mounted) return;
    if (success) {
      _titleController.clear();
      _descriptionController.clear();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              wasEditing
                  ? 'Pergunta atualizada com sucesso!'
                  : 'Pergunta publicada no FAQ!',
            ),
          ),
        );
    } else if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_controller.errorMessage!)));
    }
  }

  Future<void> _deleteItem(PerguntaFaq item) async {
    final removed = await _controller.excluir(item.id);
    if (!mounted) return;
    if (removed) {
      if (_titleController.text == item.pergunta && !_controller.isEditing) {
        _titleController.clear();
        _descriptionController.clear();
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Pergunta removida do FAQ.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _controller.items;

    return Scaffold(
      backgroundColor: AppColors.zinc50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PsychologistFaqAppBar(
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Perguntas frequentes',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.zinc950,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gerencie as perguntas acessadas pelo aluno no aplicativo',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.slate600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Título',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.zinc950,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            key: const Key('faq_title_input'),
                            controller: _titleController,
                            validator: _controller.validateTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.zinc950,
                            ),
                            decoration: _inputDecoration(
                              hintText: 'Ex.: O que é bullying',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Descrição',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.zinc950,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            key: const Key('faq_description_input'),
                            controller: _descriptionController,
                            validator: _controller.validateDescription,
                            minLines: 4,
                            maxLines: 6,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.zinc950,
                            ),
                            decoration: _inputDecoration(
                              hintText:
                                  'Escreva uma orientação acolhedora e clara...',
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              key: const Key('faq_submit_button'),
                              onPressed: _controller.isSaving ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.sky700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                _controller.isSaving
                                    ? 'Salvando...'
                                    : (_controller.isEditing
                                        ? 'Atualizar'
                                        : 'Salvar'),
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          if (_controller.isEditing) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 48,
                              child: TextButton(
                                key: const Key('faq_cancel_edit_button'),
                                onPressed: _cancelEdit,
                                child: Text(
                                  'Cancelar edição',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.slate600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (_controller.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Nenhuma pergunta cadastrada ainda.',
                          key: const Key('psychologist_faq_empty'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.slate600,
                          ),
                        ),
                      )
                    else
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        FaqExpandableCard(
                          item: items[i],
                          isExpanded: _controller.isExpanded(items[i].id),
                          onToggle:
                              () => _controller.toggleExpanded(items[i].id),
                          trailingActions: [
                            _ActionIconButton(
                              buttonKey: Key('faq_edit_${items[i].id}'),
                              tooltip: 'Editar pergunta',
                              backgroundColor: Colors.white,
                              borderColor: AppColors.sky700,
                              iconColor: AppColors.sky700,
                              icon: LucideIcons.squarePen,
                              onPressed: () => _selectForEdit(items[i]),
                            ),
                            const SizedBox(width: 6),
                            _ActionIconButton(
                              buttonKey: Key('faq_delete_${items[i].id}'),
                              tooltip: 'Excluir pergunta',
                              backgroundColor: const Color(0xFFEF4444),
                              borderColor: const Color(0xFFEF4444),
                              iconColor: Colors.white,
                              icon: LucideIcons.trash2,
                              onPressed: () => _deleteItem(items[i]),
                            ),
                          ],
                        ),
                      ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.slate600),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD4D4D8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD4D4D8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.sky700, width: 1.5),
      ),
    );
  }
}

class _PsychologistFaqAppBar extends StatelessWidget {
  const _PsychologistFaqAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            key: const Key('psychologist_faq_back_button'),
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
              'FAQ',
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

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.buttonKey,
    required this.tooltip,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
    required this.onPressed,
  });

  final Key buttonKey;
  final String tooltip;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: buttonKey,
          onTap: onPressed,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, size: 20, color: iconColor),
          ),
        ),
      ),
    );
  }
}
