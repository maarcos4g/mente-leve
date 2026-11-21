import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/student/official_channels/models/official_channel.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/utils/phone_dialer.dart';

/// Guia e lista de canais oficiais de denúncia e apoio (RF06 / SCRUM-34).
///
/// Mostra Disque 100, Conselho Tutelar e Ouvidoria Escolar: o que cada um
/// faz, quando procurar e como entrar em contato. Funciona offline; só o
/// Disque 100 tem botão de ligar, porque os outros não têm número nacional.
class OfficialChannelsView extends StatelessWidget {
  const OfficialChannelsView({
    super.key,
    this.channels = officialChannels,
    this.onDial,
  });

  /// Rota sob `/faq` para o botão "Ajuda (CVV)" continuar visível aqui.
  static const routeName = '/faq/canais-oficiais';

  final List<OfficialChannel> channels;

  /// Troca a discagem (testes). Por padrão abre o discador nativo.
  final Future<bool> Function(String number)? onDial;

  Future<void> _dial(BuildContext context, String number) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await (onDial ?? dialPhoneNumber)(number);
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o discador.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.zinc50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ChannelsAppBar(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: ListView(
                // Espaço inferior para o botão "Ajuda (CVV)" sobreposto.
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 108),
                children: [
                  Text(
                    'Você tem direito a pedir ajuda. Se sofre ou presencia '
                    'violência, abuso ou bullying, procure um destes canais. '
                    'Contar para alguém não é exagero.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.45,
                      color: AppColors.slate600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final channel in channels) ...[
                    _OfficialChannelCard(
                      channel: channel,
                      onDial:
                          channel.canDial
                              ? () => _dial(context, channel.phoneNumber!)
                              : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  const _EmergencyNote(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelsAppBar extends StatelessWidget {
  const _ChannelsAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            key: const Key('official_channels_back_button'),
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
            child: Semantics(
              header: true,
              child: Text(
                'Canais Oficiais',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.zinc950,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

/// Visual de cada canal: cor de fundo do ícone e ícone.
class _ChannelStyle {
  const _ChannelStyle(this.background, this.iconColor, this.icon);

  final Color background;
  final Color iconColor;
  final IconData icon;

  static const _fallback = _ChannelStyle(
    AppColors.zinc100,
    AppColors.slate600,
    LucideIcons.info,
  );

  static const _byId = <String, _ChannelStyle>{
    'disque-100': _ChannelStyle(
      Color(0xFFFFE2E2),
      Color(0xFFFB2C36),
      LucideIcons.phoneCall,
    ),
    'conselho-tutelar': _ChannelStyle(
      Color(0xFFDFF2FE),
      AppColors.sky700,
      LucideIcons.shieldCheck,
    ),
    'ouvidoria-escolar': _ChannelStyle(
      Color(0xFFFEF3C7),
      Color(0xFFB45309),
      LucideIcons.school,
    ),
  };

  static _ChannelStyle of(String id) => _byId[id] ?? _fallback;
}

class _OfficialChannelCard extends StatelessWidget {
  const _OfficialChannelCard({required this.channel, this.onDial});

  final OfficialChannel channel;
  final VoidCallback? onDial;

  @override
  Widget build(BuildContext context) {
    final style = _ChannelStyle.of(channel.id);
    final labelStyle = GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.zinc950,
    );
    final bodyStyle = GoogleFonts.poppins(
      fontSize: 13,
      height: 1.4,
      color: AppColors.slate600,
    );

    return Container(
      key: Key('official_channel_${channel.id}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: style.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(style.icon, size: 22, color: style.iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    channel.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.zinc950,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(channel.summary, style: bodyStyle),
          const SizedBox(height: 12),
          Text('Quando procurar', style: labelStyle),
          const SizedBox(height: 4),
          for (final item in channel.whenToSeek)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(child: Text('•  ', style: bodyStyle)),
                  Expanded(child: Text(item, style: bodyStyle)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Text('Como entrar em contato', style: labelStyle),
          const SizedBox(height: 4),
          Text(channel.howToContact, style: bodyStyle),
          if (onDial != null) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              key: Key('official_channel_call_${channel.id}'),
              onPressed: onDial,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sky700,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(LucideIcons.phone, size: 18),
              label: Text(
                'Ligar ${channel.phoneNumber}',
                semanticsLabel:
                    'Ligar para ${channel.name}, número ${channel.phoneNumber}',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmergencyNote extends StatelessWidget {
  const _EmergencyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('official_channels_emergency_note'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.zinc100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.siren, size: 18, color: AppColors.zinc950),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Em perigo agora? Ligue 190 (Polícia Militar). Se estiver '
              'triste ou pensando em se machucar, o CVV atende no 188.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.4,
                color: AppColors.zinc950,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
