import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/shared/models/chat_message.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';

/// Cores do chat (valores do Figma). Todos os pares texto/fundo têm contraste
/// mínimo de 4,5:1 (WCAG AA).
class ChatColors {
  static const Color ownBubble = Color(0xFF615FFF);
  static const Color ownText = Colors.white;
  static const Color otherBubble = Color(0xFFEEF2FF);
  static const Color otherText = Color(0xFF432DD7);
  static const Color otherMeta = AppColors.slate600;
}

/// Limite de caracteres de uma mensagem (regra do Firestore).
const int chatMaxMessageLength = 2000;

/// Texto do separador de dia: "Hoje", "Ontem" ou `dd/mm/aaaa`.
String chatDayLabel(DateTime day, DateTime now) {
  final today = DateUtils.dateOnly(now);
  if (day == today) return 'Hoje';
  if (day == today.subtract(const Duration(days: 1))) return 'Ontem';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(day.day)}/${two(day.month)}/${day.year}';
}

/// Balões da conversa com separador por dia. [isOwn] diz de que lado cada
/// mensagem fica e [otherLabel] é o nome mostrado nas mensagens da outra
/// pessoa ("Psicóloga" para o aluno, "Aluno anônimo" para a psicóloga).
List<Widget> chatMessageItems({
  required List<ChatMessage> messages,
  required DateTime now,
  required bool Function(ChatMessage) isOwn,
  required String otherLabel,
}) {
  final items = <Widget>[];
  DateTime? currentDay;
  for (final message in messages) {
    final day = DateUtils.dateOnly(message.createdAt);
    if (currentDay != day) {
      currentDay = day;
      items.add(ChatDayLabel(label: chatDayLabel(day, now)));
    }
    items.add(
      ChatMessageBubble(
        message: message,
        isOwn: isOwn(message),
        otherLabel: otherLabel,
      ),
    );
  }
  return items;
}

class ChatDayLabel extends StatelessWidget {
  const ChatDayLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.zinc950,
          ),
        ),
      ),
    );
  }
}

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isOwn,
    required this.otherLabel,
  });

  final ChatMessage message;
  final bool isOwn;
  final String otherLabel;

  @override
  Widget build(BuildContext context) {
    final textColor = isOwn ? ChatColors.ownText : ChatColors.otherText;
    final metaColor = isOwn ? ChatColors.ownText : ChatColors.otherMeta;
    String two(int n) => n.toString().padLeft(2, '0');
    final time =
        message.isPending
            ? 'Enviando…'
            : '${two(message.createdAt.hour)}:${two(message.createdAt.minute)}';

    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Semantics(
        label:
            '${isOwn ? 'Você' : otherLabel}: ${message.text}. '
            '${message.isPending ? 'Enviando' : 'Enviada às $time'}',
        excludeSemantics: true,
        child: Container(
          key: Key('chat_message_${message.id}'),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          decoration: BoxDecoration(
            color: isOwn ? ChatColors.ownBubble : ChatColors.otherBubble,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isOwn)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    otherLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              Text(
                message.text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.4,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  time,
                  key: Key('chat_message_time_${message.id}'),
                  style: GoogleFonts.poppins(fontSize: 11, color: metaColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Campo de mensagem com o botão de enviar (48x48).
class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.textController,
    required this.enabled,
    required this.isSending,
    required this.onSend,
    this.bottomInset = 0,
    this.banner,
  });

  final TextEditingController textController;
  final bool enabled;
  final bool isSending;
  final VoidCallback onSend;

  /// Espaço extra embaixo (o botão CVV do aluno fica nesse canto).
  final double bottomInset;

  /// Aviso acima do campo (por exemplo, "sem conexão").
  final String? banner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4E4E7))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (banner != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                banner!,
                key: const Key('chat_unavailable_banner'),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.slate600,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('chat_message_input'),
                  controller: textController,
                  enabled: enabled,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: chatMaxMessageLength,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.zinc950,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Digite sua mensagem',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.slate600,
                    ),
                    counterText: '',
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFFD4D4D8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFFD4D4D8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: ChatColors.ownBubble,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                button: true,
                label: 'Enviar mensagem',
                excludeSemantics: true,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Material(
                    color:
                        enabled
                            ? ChatColors.ownBubble
                            : const Color(0xFFA1A1AA),
                    shape: const CircleBorder(),
                    child: InkWell(
                      key: const Key('chat_send_button'),
                      customBorder: const CircleBorder(),
                      onTap: enabled && !isSending ? onSend : null,
                      child: const Icon(
                        LucideIcons.send,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Mensagem centralizada com botão (erro de carga).
class ChatCenteredMessage extends StatelessWidget {
  const ChatCenteredMessage({
    super.key,
    required this.icon,
    required this.message,
    required this.actionKey,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final Key actionKey;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: AppColors.slate600),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.slate600,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              key: actionKey,
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
                foregroundColor: AppColors.sky700,
              ),
              child: Text(
                actionLabel,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barra superior do chat: voltar, título e (opcional) ação à direita.
class ChatAppBar extends StatelessWidget {
  const ChatAppBar({
    super.key,
    required this.title,
    required this.onBack,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            key: const Key('chat_back_button'),
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
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.zinc950,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.slate600,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
