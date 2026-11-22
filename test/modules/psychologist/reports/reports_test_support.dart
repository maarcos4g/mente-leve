import 'package:mente_leve/shared/models/report_model.dart';
import 'package:mente_leve/shared/reports/report_repository.dart';

Report buildReport(
  String id, {
  ReportType type = ReportType.bullying,
  String description = 'Relato sem detalhes',
  ReportStatus status = ReportStatus.pending,
  required DateTime createdAt,
  required ReportSeverity severity,
}) {
  return Report(
    id: id,
    type: type,
    description: description,
    status: status,
    createdAt: createdAt,
    severity: severity,
  );
}

/// Quatro denúncias de teste, da mais antiga (`d1`) à mais nova (`d4`).
List<Report> sampleReports() => [
  buildReport(
    'd1',
    description: 'Me chamam de apelido na sala',
    createdAt: DateTime(2026, 11, 10, 9),
    severity: ReportSeverity.medium,
  ),
  buildReport(
    'd2',
    type: ReportType.cyberbullying,
    description: 'Fizeram um grupo para me zoar',
    status: ReportStatus.inMediation,
    createdAt: DateTime(2026, 11, 12, 15, 30),
    severity: ReportSeverity.high,
  ),
  buildReport(
    'd3',
    type: ReportType.other,
    description: 'O bebedouro está quebrado',
    status: ReportStatus.answered,
    createdAt: DateTime(2026, 11, 15, 8),
    severity: ReportSeverity.low,
  ),
  buildReport(
    'd4',
    description: 'Ameaçaram me bater na saída',
    createdAt: DateTime(2026, 11, 18, 11, 5),
    severity: ReportSeverity.high,
  ),
];

class FailingReportRepository implements ReportRepository {
  FailingReportRepository(this.items);

  int calls = 0;
  bool shouldFail = true;
  final List<Report> items;

  @override
  Future<List<Report>> list() async {
    calls++;
    if (shouldFail) throw Exception('sem rede');
    return items;
  }
}
