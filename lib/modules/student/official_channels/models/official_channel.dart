/// Canal oficial de denúncia e apoio (RF06 / SCRUM-34).
///
/// A lista é fixa no app para funcionar sem internet (RNF02). Só o Disque 100
/// tem número nacional; Conselho Tutelar e Ouvidoria Escolar variam por cidade
/// e por escola, então aparecem como guia de como encontrá-los, sem número.
class OfficialChannel {
  const OfficialChannel({
    required this.id,
    required this.name,
    required this.summary,
    required this.whenToSeek,
    required this.howToContact,
    this.phoneNumber,
  });

  /// Identificador estável, usado nas chaves dos widgets e nos testes.
  final String id;

  final String name;

  /// O que o canal faz, em uma frase.
  final String summary;

  /// Situações em que o aluno pode procurar o canal.
  final List<String> whenToSeek;

  /// Como entrar em contato.
  final String howToContact;

  /// Número para o discador nativo. `null` quando não há número nacional.
  final String? phoneNumber;

  bool get canDial => phoneNumber != null;
}

/// Canais exigidos pelo critério de aceite da SCRUM-34, na ordem de exibição.
const officialChannels = <OfficialChannel>[
  OfficialChannel(
    id: 'disque-100',
    name: 'Disque 100',
    summary:
        'Disque Direitos Humanos: recebe denúncias de violência contra '
        'crianças e adolescentes em todo o Brasil.',
    whenToSeek: [
      'Você sofre ou vê alguém sofrer agressão, abuso ou ameaça.',
      'Alguém te obriga a fazer algo que você não quer.',
      'Você sofre discriminação ou humilhação.',
    ],
    howToContact:
        'Ligue 100. É gratuito, funciona 24 horas, todos os dias, e você '
        'não precisa dizer seu nome.',
    phoneNumber: '100',
  ),
  OfficialChannel(
    id: 'conselho-tutelar',
    name: 'Conselho Tutelar',
    summary:
        'Órgão da sua cidade que protege os direitos de crianças e '
        'adolescentes, garantidos pelo ECA.',
    whenToSeek: [
      'Você sofre violência, abandono ou maus-tratos em casa.',
      'Seus direitos não estão sendo respeitados, inclusive na escola.',
      'Você precisa de proteção e não sabe a quem recorrer.',
    ],
    howToContact:
        'Cada cidade tem o seu. Peça o telefone e o endereço à escola ou à '
        'prefeitura. Se não souber, ligue para o Disque 100: eles '
        'encaminham o caso ao Conselho Tutelar da sua região.',
  ),
  OfficialChannel(
    id: 'ouvidoria-escolar',
    name: 'Ouvidoria Escolar',
    summary:
        'Canal da escola ou da Secretaria de Educação para registrar '
        'denúncias, reclamações e sugestões.',
    whenToSeek: [
      'Você sofre ou presencia bullying na escola.',
      'Você recebe tratamento injusto de colegas ou funcionários.',
      'Um problema na escola não foi resolvido pela coordenação.',
    ],
    howToContact:
        'Procure a secretaria ou a coordenação da sua escola, ou a ouvidoria '
        'da Secretaria de Educação do seu estado ou município.',
  ),
];
