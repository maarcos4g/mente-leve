import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/shared/utils/phone_dialer.dart';
import 'package:mente_leve/shared/widgets/cvv_button/cvv_button.dart';

void main() {
  test('phoneUri monta o endereço tel: do discador', () {
    expect(phoneUri('100').toString(), 'tel:100');
    expect(phoneUri('188').toString(), 'tel:188');
  });

  test('CvvButton continua discando 188', () {
    expect(CvvButton.cvvUri, phoneUri('188'));
  });
}
