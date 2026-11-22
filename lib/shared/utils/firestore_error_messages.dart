import 'package:firebase_core/firebase_core.dart';

/// Mensagem (PT-BR) para a falha ao acompanhar uma conversa em tempo real.
///
/// Só culpa a conexão quando o erro é mesmo de rede; negação de permissão e
/// outras falhas do Firestore têm texto próprio.
String chatLoadErrorMessage(Object error) {
  if (error is FirebaseException) {
    if (error.code == 'unavailable') {
      return 'Sem conexão com a escola. Verifique a internet e tente '
          'novamente.';
    }
    if (error.code == 'permission-denied') {
      return 'Sem permissão para abrir a conversa. Avise a equipe do app: '
          'as regras de segurança do chat ainda não estão ativas.';
    }
  }
  return 'Não foi possível abrir a conversa agora. Tente novamente em '
      'instantes.';
}

/// Mensagem (PT-BR) para a falha ao acompanhar a lista de relatos em tempo
/// real no painel de triagem.
String reportsLoadErrorMessage(Object error) {
  if (error is FirebaseException) {
    if (error.code == 'unavailable') {
      return 'Sem conexão. Verifique a internet e tente novamente.';
    }
    if (error.code == 'permission-denied') {
      return 'Sem permissão para ler as denúncias. Confira se a conta é de '
          'psicóloga e se as regras de segurança do Firestore estão '
          'publicadas.';
    }
  }
  return 'Não foi possível carregar as denúncias. Tente novamente em '
      'instantes.';
}
