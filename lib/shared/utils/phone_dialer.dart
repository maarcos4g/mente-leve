import 'package:url_launcher/url_launcher.dart';

/// Monta o endereço `tel:` usado pelo discador nativo.
Uri phoneUri(String number) => Uri(scheme: 'tel', path: number);

/// Abre o discador nativo com [number] já preenchido.
///
/// Não liga sozinho: o aluno confirma a chamada no discador. Devolve `false`
/// quando o aparelho não tem discador (ou ele não abre), sem lançar erro.
/// Não depende de internet.
Future<bool> dialPhoneNumber(String number) async {
  try {
    return await launchUrl(phoneUri(number));
  } catch (_) {
    return false;
  }
}
