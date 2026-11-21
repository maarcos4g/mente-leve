import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/official_channels/models/official_channel.dart';
import 'package:mente_leve/modules/student/official_channels/official_channels_view.dart';
import 'package:mente_leve/shared/widgets/cvv_button/cvv_overlay.dart';

void main() {
  group('OfficialChannelsView (RF06 / SCRUM-34)', () {
    Widget createWidget({Future<bool> Function(String number)? onDial}) {
      return MaterialApp(
        home: OfficialChannelsView(onDial: onDial ?? (_) async => true),
      );
    }

    test('lista fixa tem os três canais do critério de aceite', () {
      expect(officialChannels.map((c) => c.name), [
        'Disque 100',
        'Conselho Tutelar',
        'Ouvidoria Escolar',
      ]);
      expect(officialChannels.first.phoneNumber, '100');
      // Conselho Tutelar e Ouvidoria variam por cidade/escola: sem número.
      expect(officialChannels[1].canDial, isFalse);
      expect(officialChannels[2].canDial, isFalse);
      for (final channel in officialChannels) {
        expect(channel.summary, isNotEmpty);
        expect(channel.whenToSeek, isNotEmpty);
        expect(channel.howToContact, isNotEmpty);
      }
    });

    testWidgets('mostra os três canais com guia de quando e como procurar', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Canais Oficiais'), findsOneWidget);
      for (final channel in officialChannels) {
        final card = find.byKey(Key('official_channel_${channel.id}'));
        await tester.scrollUntilVisible(card, 200);
        expect(
          find.descendant(of: card, matching: find.text(channel.name)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: card, matching: find.text('Quando procurar')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: card,
            matching: find.text(channel.howToContact),
          ),
          findsOneWidget,
        );
      }

      await tester.scrollUntilVisible(
        find.byKey(const Key('official_channels_emergency_note')),
        200,
      );
      expect(find.textContaining('Ligue 190'), findsOneWidget);
    });

    testWidgets('só o Disque 100 tem botão de ligar', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('official_channel_call_disque-100')),
        findsOneWidget,
      );
      expect(find.text('Ligar 100'), findsOneWidget);
      expect(
        find.byKey(const Key('official_channel_call_conselho-tutelar')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('official_channel_call_ouvidoria-escolar')),
        findsNothing,
      );
    });

    testWidgets('botão Ligar 100 disca o número 100', (tester) async {
      final dialed = <String>[];
      await tester.pumpWidget(
        createWidget(
          onDial: (number) async {
            dialed.add(number);
            return true;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('official_channel_call_disque-100')),
      );
      await tester.pump();

      expect(dialed, ['100']);
      expect(find.text('Não foi possível abrir o discador.'), findsNothing);
    });

    testWidgets('avisa quando o discador não abre', (tester) async {
      await tester.pumpWidget(createWidget(onDial: (_) async => false));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('official_channel_call_disque-100')),
      );
      await tester.pump();

      expect(find.text('Não foi possível abrir o discador.'), findsOneWidget);
    });

    testWidgets('controles têm área mínima de toque de 48x48dp', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final back = tester.getSize(
        find.byKey(const Key('official_channels_back_button')),
      );
      expect(back.width, greaterThanOrEqualTo(48));
      expect(back.height, greaterThanOrEqualTo(48));

      final call = tester.getSize(
        find.byKey(const Key('official_channel_call_disque-100')),
      );
      expect(call.height, greaterThanOrEqualTo(48));
    });

    testWidgets('botão de ligar tem rótulo para leitor de tela', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel('Ligar para Disque 100, número 100'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('renderiza sem overflow em tela estreita (320x640)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    test('rota fica sob /faq para o botão do CVV continuar visível', () {
      expect(
        defaultVisibleRoutePrefixes.any(
          OfficialChannelsView.routeName.startsWith,
        ),
        isTrue,
      );
    });
  });
}
