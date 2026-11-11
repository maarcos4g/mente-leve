import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_reflection_controller.dart';
import 'package:mente_leve/modules/student/diary/diary_feelings_view.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';

// Cores do Figma ("personal diary"), equivalentes à paleta Tailwind.
const _zinc50 = Color(0xFFFAFAFA);
const _zinc100 = Color(0xFFF4F4F5);
const _zinc200 = Color(0xFFE4E4E7);
const _zinc400 = Color(0xFF9F9FA9);
const _zinc900 = Color(0xFF18181B);
const _sky600 = Color(0xFF0084D1);
const _sky700 = Color(0xFF0069A8);
const _red500 = Color(0xFFFB2C36);

TextStyle _poppins(double size, FontWeight weight, Color color,
        {double? height}) =>
    GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );

/// Diário Pessoal (Figma: "personal diary" e "personal diary / add").
///
/// Atende o RF02: área de texto livre e checklist de pontos positivos do dia,
/// salvos só no aparelho. Retorna `true` via `Navigator.pop` se algo mudou,
/// para a Home atualizar o resumo da semana.
class DiaryReflectionView extends StatefulWidget {
  const DiaryReflectionView({super.key, this.repository});

  /// Repositório do diário. Nulo usa o padrão do app (shared_preferences).
  final DiaryRepository? repository;

  @override
  State<DiaryReflectionView> createState() => _DiaryReflectionViewState();
}

class _DiaryReflectionViewState extends State<DiaryReflectionView> {
  late final DiaryReflectionController _controller;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _controller = DiaryReflectionController(repository: widget.repository)
      ..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openSheet([RegistroDiario? registro]) async {
    _controller.abrir(registro);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: _zinc50.withValues(alpha: 0.6),
      builder: (_) => _DiaryEntrySheet(controller: _controller),
    );
    if (saved == true && mounted) {
      _changed = true;
      _showMessage('Registro salvo no seu diário.');
    }
  }

  Future<void> _delete(RegistroDiario registro) async {
    await _controller.delete(registro);
    _changed = true;
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Registro excluído.'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => _controller.restore(registro),
          ),
        ),
      );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: _zinc50,
        body: SafeArea(
          child: Column(
            children: [
              _AppBar(onBack: () => Navigator.maybePop(context)),
              Expanded(
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) => ListView(
                    padding: const EdgeInsets.fromLTRB(24, 42, 24, 32),
                    children: [
                      _WeekCalendar(controller: _controller),
                      const SizedBox(height: 42),
                      _AnotarButton(onPressed: () => _openSheet()),
                      const SizedBox(height: 42),
                      Text(
                        'Registros recentes',
                        style: _poppins(16, FontWeight.w600, Colors.black,
                            height: 36 / 16),
                      ),
                      const SizedBox(height: 24),
                      ..._buildEntries(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEntries() {
    if (_controller.isLoading) {
      return const [Center(child: CircularProgressIndicator())];
    }
    if (_controller.entries.isEmpty) {
      return [
        Text(
          'Nenhum registro ainda. Toque em "Anotar no Diário" para começar.',
          style: _poppins(14, FontWeight.w400, _zinc400, height: 20 / 14),
        ),
      ];
    }
    return [
      for (final registro in _controller.entries)
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _EntryItem(
            registro: registro,
            onTap: () => _openSheet(registro),
            onDelete: () => _delete(registro),
          ),
        ),
    ];
  }
}

/// App Bar: voltar, título e cadeado (dados só no aparelho).
class _AppBar extends StatelessWidget {
  const _AppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: const BoxDecoration(
        color: _zinc50,
        border: Border(bottom: BorderSide(color: _zinc200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            key: const Key('diario_voltar'),
            onPressed: onBack,
            tooltip: 'Voltar',
            icon: const Icon(LucideIcons.chevronLeft, size: 24),
          ),
          Expanded(
            child: Text(
              'Diário Pessoal',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: _poppins(18, FontWeight.w600, Colors.black, height: 2),
            ),
          ),
          const Tooltip(
            message: 'Seu diário fica salvo só neste aparelho',
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Icon(LucideIcons.lockKeyhole, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

/// Semana atual (D S T Q Q S S) com o dia de hoje destacado.
class _WeekCalendar extends StatelessWidget {
  const _WeekCalendar({required this.controller});

  final DiaryReflectionController controller;

  static const _letras = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final domingo = DateTime(hoje.year, hoje.month, hoje.day)
        .subtract(Duration(days: hoje.weekday % 7));
    final dias = List.generate(7, (i) => domingo.add(Duration(days: i)));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final letra in _letras)
              SizedBox(
                width: 32,
                child: Text(
                  letra,
                  textAlign: TextAlign.center,
                  style: _poppins(18, FontWeight.w600, _zinc400, height: 2),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final dia in dias) _buildDia(dia, dia.day == hoje.day),
          ],
        ),
      ],
    );
  }

  Widget _buildDia(DateTime dia, bool isHoje) {
    final temRegistro = controller.temRegistroEm(dia);
    return SizedBox(
      width: 32,
      height: 40,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: isHoje
                ? const BoxDecoration(color: _sky700, shape: BoxShape.circle)
                : null,
            child: Text(
              '${dia.day}',
              style: isHoje
                  ? _poppins(16, FontWeight.w600, _zinc50)
                  : _poppins(18, FontWeight.w600, Colors.black),
            ),
          ),
          const SizedBox(height: 2),
          // Pontinho nos dias com registro (o Figma não mostra, mas ajuda o
          // aluno a ver os dias em que escreveu).
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: temRegistro ? _sky600 : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnotarButton extends StatelessWidget {
  const _AnotarButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x406155F5),
            offset: Offset(0, 4),
            blurRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: _sky700,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: const Key('botao_anotar_diario'),
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: SizedBox(
            height: 52,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.circlePlus, color: _zinc50, size: 24),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'Anotar no Diário',
                    overflow: TextOverflow.ellipsis,
                    style: _poppins(16, FontWeight.w600, _zinc50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Item de "Registros recentes". Arrastar para a esquerda revela a lixeira.
class _EntryItem extends StatelessWidget {
  const _EntryItem({
    required this.registro,
    required this.onTap,
    required this.onDelete,
  });

  final RegistroDiario registro;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('registro_${registro.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 38),
        decoration: BoxDecoration(
          color: _red500,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(LucideIcons.trash, color: _zinc50, size: 24),
      ),
      child: Material(
        color: _zinc100,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _sky600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    DiaryReflectionController.tituloDe(registro),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _poppins(14, FontWeight.w600, Colors.black),
                  ),
                ),
                const SizedBox(width: 12),
                _EmotionAvatar(humor: registro.humor, size: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rostinho da emoção, o mesmo da tela de humor (RF01).
class _EmotionAvatar extends StatelessWidget {
  const _EmotionAvatar({required this.humor, required this.size});

  final Humor humor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: humor.wheelColor,
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        size: Size.square(size),
        painter: EmotionFacePainter(humor: humor),
      ),
    );
  }
}

/// Folha "Anotar no Diário" (Figma: "personal diary / add") com o checklist
/// de pontos positivos do protótipo "diario-reflexivo".
class _DiaryEntrySheet extends StatefulWidget {
  const _DiaryEntrySheet({required this.controller});

  final DiaryReflectionController controller;

  @override
  State<_DiaryEntrySheet> createState() => _DiaryEntrySheetState();
}

class _DiaryEntrySheetState extends State<_DiaryEntrySheet> {
  late final TextEditingController _texto =
      TextEditingController(text: widget.controller.texto);

  DiaryReflectionController get _controller => widget.controller;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _pickHumor() async {
    final humor = await showModalBottomSheet<Humor>(
      context: context,
      backgroundColor: _zinc50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Como você está se sentindo?',
                style: _poppins(16, FontWeight.w600, _zinc900),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  for (final humor in Humor.values)
                    InkWell(
                      key: Key('humor_${humor.name}'),
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pop(context, humor),
                      child: SizedBox(
                        width: 80,
                        child: Column(
                          children: [
                            _EmotionAvatar(humor: humor, size: 52),
                            const SizedBox(height: 6),
                            Text(
                              humor.label,
                              style: _poppins(12, FontWeight.w500, _zinc900),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (humor != null) _controller.selectHumor(humor);
  }

  Future<void> _addPonto() async {
    final ponto = await showDialog<String>(
      context: context,
      builder: (_) => const _NovoPontoDialog(),
    );
    if (ponto == null || ponto.trim().isEmpty || !mounted) return;
    if (!_controller.addPonto(ponto)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esse ponto positivo já está na lista.')),
      );
    }
  }

  Future<void> _registrar() async {
    if (_controller.humor == null) {
      await _pickHumor();
      if (!mounted || _controller.humor == null) return;
    }
    if (!_controller.canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escreva algo ou marque um ponto positivo do dia.'),
        ),
      );
      return;
    }
    final ok = await _controller.save();
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar. Tente novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        // No Figma a folha começa abaixo do calendário (top 195 de 844).
        height: media.size.height * 0.77,
        decoration: const BoxDecoration(
          color: _zinc50,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 16)],
        ),
        padding: const EdgeInsets.all(24),
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(LucideIcons.chevronLeft, size: 24),
                  ),
                  _buildHumorButton(),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  key: const Key('campo_texto_reflexivo'),
                  controller: _texto,
                  onChanged: _controller.setTexto,
                  maxLines: null,
                  expands: true,
                  maxLength: DiaryReflectionController.maxTextoLength,
                  textAlignVertical: TextAlignVertical.top,
                  textCapitalization: TextCapitalization.sentences,
                  style: _poppins(14, FontWeight.w400, Colors.black,
                      height: 20 / 14),
                  decoration: InputDecoration(
                    hintText: 'Conte um pouco do que está pensando no momento...',
                    hintStyle: _poppins(14, FontWeight.w400, Colors.black,
                        height: 20 / 14),
                    border: InputBorder.none,
                    isCollapsed: true,
                    counterStyle: _poppins(11, FontWeight.w400, _zinc400),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildPontosPositivos(),
              const SizedBox(height: 16),
              _buildRegistrarButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Botão redondo do canto (lucide face-slightly-smiling-plus). Depois de
  /// escolhido, mostra o rostinho do humor.
  Widget _buildHumorButton() {
    final humor = _controller.humor;
    return Tooltip(
      message: 'Como você está se sentindo?',
      child: InkWell(
        key: const Key('botao_humor'),
        customBorder: const CircleBorder(),
        onTap: _pickHumor,
        child: humor != null
            ? _EmotionAvatar(humor: humor, size: 30)
            : Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _zinc900),
                ),
                child: const Icon(LucideIcons.smilePlus, size: 16),
              ),
      ),
    );
  }

  Widget _buildPontosPositivos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Pontos Positivos do Dia',
                style: _poppins(16, FontWeight.w600, _zinc900),
              ),
            ),
            Material(
              color: _sky600,
              shape: const CircleBorder(),
              child: InkWell(
                key: const Key('botao_adicionar_ponto'),
                customBorder: const CircleBorder(),
                onTap: _addPonto,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(LucideIcons.plus, color: _zinc50, size: 20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 132),
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ponto in _controller.pontos) _buildChip(ponto),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String ponto) {
    final marcado = _controller.isMarcado(ponto);
    return Semantics(
      checked: marcado,
      child: Material(
        color: marcado ? _sky600.withValues(alpha: 0.12) : Colors.white,
        shape: StadiumBorder(
          side: BorderSide(color: marcado ? _sky600 : _zinc200),
        ),
        child: InkWell(
          key: Key('ponto_$ponto'),
          customBorder: const StadiumBorder(),
          onTap: () => _controller.togglePonto(ponto),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(DiaryReflectionController.emojiDe(ponto),
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    ponto,
                    overflow: TextOverflow.ellipsis,
                    style: _poppins(
                      13,
                      marcado ? FontWeight.w600 : FontWeight.w400,
                      marcado ? _sky700 : _zinc900,
                    ),
                  ),
                ),
                if (marcado) ...[
                  const SizedBox(width: 4),
                  const Icon(LucideIcons.check, size: 14, color: _sky700),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrarButton() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: Material(
        color: _sky600,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          key: const Key('botao_registrar'),
          borderRadius: BorderRadius.circular(8),
          onTap: _controller.isSaving ? null : _registrar,
          child: Center(
            child: _controller.isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _zinc50,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.check, color: _zinc50, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Registrar',
                        style: _poppins(14, FontWeight.w600, _zinc50,
                            height: 20 / 14),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Diálogo para o aluno escrever um ponto positivo próprio. É um widget com
/// estado para o campo de texto viver até o fim da animação de fechamento.
class _NovoPontoDialog extends StatefulWidget {
  const _NovoPontoDialog();

  @override
  State<_NovoPontoDialog> createState() => _NovoPontoDialogState();
}

class _NovoPontoDialogState extends State<_NovoPontoDialog> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _zinc50,
      title: Text(
        'Novo ponto positivo',
        style: _poppins(16, FontWeight.w600, _zinc900),
      ),
      content: TextField(
        key: const Key('campo_novo_ponto'),
        controller: _input,
        autofocus: true,
        maxLength: DiaryReflectionController.maxPontoLength,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (value) => Navigator.pop(context, value),
        decoration: const InputDecoration(hintText: 'Ex.: Joguei bola'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          key: const Key('confirmar_novo_ponto'),
          onPressed: () => Navigator.pop(context, _input.text),
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
