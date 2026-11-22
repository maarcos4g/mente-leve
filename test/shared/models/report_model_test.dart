import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/shared/models/report_model.dart';

void main() {
  group('ReportSeverity.infer', () {
    test('sinais de risco no texto elevam para alta, com ou sem acento', () {
      expect(
        ReportSeverity.infer(ReportType.other, 'Ele me AMEAÇOU hoje'),
        ReportSeverity.high,
      );
      expect(
        ReportSeverity.infer(ReportType.bullying, 'quero me matar'),
        ReportSeverity.high,
      );
      expect(
        ReportSeverity.infer(ReportType.cyberbullying, 'sofro violência'),
        ReportSeverity.high,
      );
    });

    test('bullying e cyberbullying sem sinal de risco são média', () {
      expect(
        ReportSeverity.infer(ReportType.bullying, 'me chamam de apelido'),
        ReportSeverity.medium,
      );
      expect(
        ReportSeverity.infer(ReportType.cyberbullying, 'zoam no grupo'),
        ReportSeverity.medium,
      );
    });

    test('outros sem sinal de risco são baixa', () {
      expect(
        ReportSeverity.infer(ReportType.other, 'o banheiro está sujo'),
        ReportSeverity.low,
      );
    });
  });

  group('Report.fromMap', () {
    test('lê todos os campos e ignora o studentUid', () {
      final criado = DateTime.utc(2026, 11, 20, 14, 30);
      final report = Report.fromMap('d1', {
        'studentUid': 'secret-uid',
        'type': 'cyberbullying',
        'description': 'Prints no grupo da turma',
        'status': 'inMediation',
        'createdAt': Timestamp.fromDate(criado),
        'severity': 'low',
      });

      expect(report.id, 'd1');
      expect(report.type, ReportType.cyberbullying);
      expect(report.status, ReportStatus.inMediation);
      expect(report.severity, ReportSeverity.low);
      expect(report.createdAt.toUtc(), criado);
      expect(report.isPending, isFalse);
    });

    test('gravidade ausente é inferida do tipo e do texto', () {
      final report = Report.fromMap('d2', {
        'type': 'bullying',
        'description': 'Fui agredido no recreio',
        'status': 'pending',
        'createdAt': Timestamp.fromDate(DateTime.utc(2026, 11, 1)),
      });
      expect(report.severity, ReportSeverity.high);
    });

    test('campos ausentes ou inválidos usam valores seguros', () {
      final report = Report.fromMap('d3', {
        'type': 'unknown',
        'status': 'anything',
      });
      expect(report.type, ReportType.other);
      expect(report.status, ReportStatus.pending);
      expect(report.description, '');
      expect(report.severity, ReportSeverity.low);
      expect(report.isPending, isTrue);
    });
  });
}
