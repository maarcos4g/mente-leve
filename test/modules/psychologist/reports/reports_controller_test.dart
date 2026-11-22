import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/psychologist/reports/reports_controller.dart';
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
      expect(controller.sorted.map((d) => d.id), ['d2', 'd4', 'd1', 'd3']);
    });

    test('protocolo segue a ordem de chegada, não a de triagem', () {
      final byId = {for (final d in sampleReports()) d.id: d};
      expect(controller.protocol(byId['d1']!), '#001');
      expect(controller.protocol(byId['d4']!), '#004');
      expect(controller.protocol(byId['d2']!), '#002');
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
