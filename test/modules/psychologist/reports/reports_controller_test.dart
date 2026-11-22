import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/psychologist/reports/reports_controller.dart';
import 'package:mente_leve/shared/models/report_model.dart';
import 'package:mente_leve/shared/reports/report_repository.dart';

import 'reports_test_support.dart';

void main() {
  group('ReportsController (RF09)', () {
    late ReportsController controller;

    setUp(() async {
      controller = ReportsController(
        repository: LocalReportRepository(sampleReports()),
      );
      await controller.load();
    });

    test('ordena por gravidade e, na mesma gravidade, do mais antigo', () {
      expect(controller.visible.map((d) => d.id), ['d2', 'd4', 'd1', 'd3']);
    });

    test('filtra por gravidade', () {
      controller.filterBySeverity(ReportSeverity.high);
      expect(controller.visible.map((d) => d.id), ['d2', 'd4']);

      controller.filterBySeverity(ReportSeverity.low);
      expect(controller.visible.map((d) => d.id), ['d3']);
    });

    test('filtra por status de mediação', () {
      controller.filterByStatus(ReportStatus.pending);
      expect(controller.visible.map((d) => d.id), ['d4', 'd1']);

      controller.filterByStatus(ReportStatus.inMediation);
      expect(controller.visible.map((d) => d.id), ['d2']);
    });

    test('combina os dois filtros e limpa tudo', () {
      controller
        ..filterBySeverity(ReportSeverity.high)
        ..filterByStatus(ReportStatus.pending);
      expect(controller.visible.map((d) => d.id), ['d4']);
      expect(controller.hasActiveFilters, isTrue);

      controller.clearFilters();
      expect(controller.hasActiveFilters, isFalse);
      expect(controller.visible, hasLength(4));
    });

    test('filtro sem resultado devolve lista vazia, mas o total permanece', () {
      controller
        ..filterBySeverity(ReportSeverity.low)
        ..filterByStatus(ReportStatus.pending);
      expect(controller.visible, isEmpty);
      expect(controller.total, 4);
    });

    test('protocolo segue a ordem de chegada, independente do filtro', () {
      final byId = {for (final d in sampleReports()) d.id: d};
      expect(controller.protocol(byId['d1']!), '#001');
      expect(controller.protocol(byId['d4']!), '#004');
      controller.filterBySeverity(ReportSeverity.high);
      expect(controller.protocol(byId['d4']!), '#004');
    });

    test('conta pendentes e lista as mais urgentes para a Home', () {
      expect(controller.pendingCount, 2);
      expect(controller.pendingForTriage().map((d) => d.id), ['d4', 'd1']);
      expect(controller.pendingForTriage(limit: 1).map((d) => d.id), [
        'd4',
      ]);
    });

    test('falha ao carregar mostra mensagem e permite tentar de novo', () async {
      final repo = FailingReportRepository(sampleReports());
      final failing = ReportsController(repository: repo);

      await failing.load();
      expect(failing.errorMessage, isNotNull);
      expect(failing.hasLoaded, isTrue);
      expect(failing.isLoading, isFalse);

      repo.shouldFail = false;
      await failing.load();
      expect(failing.errorMessage, isNull);
      expect(failing.total, 4);
    });
  });
}
