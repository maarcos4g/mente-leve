## [01/09/2026]

### Adicionado

- Análise inicial do estudo de caso.

## [08/09/2026]

### Adicionado

- PESQUISA, BENCHMARK E PERSONAS

## [15/09/2026]

### Adicionado

- Descrição de Funcionalidades e Requisitos
- Documento para apresentação (Slides)

## [21/09/2026]

### Adicionado

- Protótipo de baixa fidelidade

## [05/10/2026]

### Adicionado

- Apresentação da Unidade I
- Protótipo de Alta Fidelidade
- Justificativas UI/UX

## [02/11/2026]

### Adicionado

- Declaração formal de Escopo do Projeto e Calendário de Sprints (`docs/levantamento/escopo.md`).
- Registro de uso e governança de Inteligência Artificial (`docs/uso-de-ia.md`).
- Arquivo `.gitignore` para proteção de credenciais de ambiente e arquivos de apoio.
- Diagramas de Caso de uso
- Modelagem e mapeamento de Classes
- Esquema Firestore
- Revisão e aprovação do PR #1 (escopo, calendário de sprints e registro de uso de IA).

## [03/11/2026]

### Adicionado

- EAP/WBS simplificada do projeto (`docs/eap.md`): diagrama Mermaid, estrutura hierárquica, dicionário com critérios de aceite e matriz de rastreabilidade RF/RNF x pacotes de trabalho.
- Fluxograma de navegação real do aplicativo, com rotas nomeadas, transições de tela e estados vazio/erro.
  - Fluxo 1: entrada e autenticação (onboarding, codinome, seleção de perfil, login institucional e de responsável).
  - Fluxo 2: aluno, com registro de humor, histórico do diário (criar, editar e excluir) e botão CVV 188.
  - Fluxo 3: aluno, com canais de apoio, FAQ e denúncia anônima (fila offline e leitura da resposta).
  - Fluxo 4: psicóloga (triagem, resposta, gestão de FAQ e guias) e responsável (consulta de guias).
- Legenda de cores (tela, entrada/destino, concluído, erro, vazio/pendente, CVV ou sem protótipo, só no protótipo).
- Estados de erro e vazio mapeados: credencial inválida, sem conexão, falha ao salvar, diário vazio, sem discador, FAQ e guias sem cache, triagem sem denúncias, denúncia aguardando envio e sem resposta.
- Revisão dos PRs #2 (docs) e #4 (fluxograma de telas), aprovados, e #3 (EAP/WBS), com ajustes solicitados e aprovação em seguida.

## [05/11/2026]

### Modificado

- Reorganização da pasta `docs/` com criação de subdiretórios dedicados para apresentações (`docs/apresentacoes/`) e protótipos (`docs/prototipos/`).
- Padronização dos nomes dos fluxogramas (`docs/fluxogramas/`) em formato limpo (*kebab-case*), sem espaços ou caracteres especiais.
- Atualização e simplificação do registro de uso de IA (`docs/uso-de-ia.md`), estruturado por integrante com template rápido e registros das atividades de revisão técnica e governança.
- Registro de uso de IA (`docs/uso-de-ia.md`) reorganizado por sprint e colaborador, com prompts utilizados e problemas e ajustes manuais de cada atividade.
- Criação das subpastas `docs/modelagem/` (casos de uso, diagrama de classes, modelagem Firestore e mapeamento Dart) e `docs/levantamento/` (benchmark, escopo, estudo de caso, funcionalidades, justificativas, pesquisa e requisitos).
- Links internos e referências a documentos atualizados para os novos caminhos (`docs/eap.md`, `docs/levantamento/escopo.md` e imagens dos documentos de modelagem).

### Adicionado

- Estrutura-base do projeto flutter.
- Implementação do Design System (Cores, tipografias, assets).
- Construção das telas de login nos módulos de aluno, psicólogo e responsável familiar.
- Revisão e aprovação do PR #7 (reorganização da pasta `docs/` e simplificação do registro de uso de IA).
- Setup do projeto Flutter (SCRUM-24): estrutura de pastas por módulo, rotas nomeadas, tema e dependências iniciais (PR #5).

## [06/11/2026]

### Adicionado

- Integração com SDK do Firebase (Authentication e Firestore).
- Implementação dos módulos de autenticação para pais, psicólogos e alunos.
- Dependências `firebase_core`, `firebase_auth` e `cloud_firestore`, com `Firebase.initializeApp()` no bootstrap e plugin Google Services no Android (SCRUM-25/27).

## [08/11/2026]

### Adicionado

- Tela inicial (Home) do aluno fiel ao protótipo do Figma: cabeçalho com saudação e avatar, card "Como está sua mente hoje?", resumo da semana, atalhos de Diário Pessoal, Chat Anônimo e Canais de Apoio & FAQ.
- Botão "Ajuda (CVV)" compartilhado, que disca 188 pelo discador nativo (`url_launcher`).
- Cores do Figma em `lib/shared/themes/app_colors.dart` e ilustrações em `assets/home/`.
- Teste de widget da Home (`test/home_view_test.dart`).
- Diário de Sentimentos por Emojis (RF01 / SCRUM-28): tela `DiaryFeelingsView` fiel ao protótipo do Figma com disco radial interativo de 12 setores, expressões faciais vetoriais (`EmotionFacePainter`), ponteiro em gota (`NeedlePainter`), controlador (`DiaryController`), modelos (`Humor` e `RegistroDiario`), repositório local (`LocalDiaryRepository`) e widgets (`MoodSelectorCard`, `EmojiButton` e `RecentMoodsSummary`), cumprindo o fluxo de registro rápido em até 3 interações (RNF05).
- Testes unitários e de widgets para o módulo do Diário de Sentimentos (`test/modules/student/diary/`).
- Estado de carregamento e tratamento de erros no fluxo de autenticação das telas de aluno, psicóloga e responsável, com mensagens em PT-BR (PR #9).

### Modificado

- Home do aluno (`/student/home`) substitui a tela provisória e lê codinome e avatar da sessão do aluno.

## [09/11/2026]

### Adicionado

- Diário Reflexivo Livre e Checklist de Pontos Positivos (RF02): tela com área de texto livre, checklist de pontos positivos do dia (com sugestões e itens personalizados) e salvamento local. A reflexão completa o registro de humor do dia (RF01) em vez de criar outro.
- Persistência do diário no aparelho com `shared_preferences`, reaproveitando o pacote já usado pelo perfil do aluno (RNF02 / RNF03).

## [10/11/2026]

### Adicionado

- Pipeline CI/CD com Github Actions e Firebase App Distribution
- Workflow `.github/workflows/ci_cd.yml` que compila o APK Android em modo release a cada push na `main` (ou disparo manual) e envia o build ao Firebase App Distribution.
- Revisão e aprovação do PR #10 (Home do aluno) e primeira revisão do PR #11 (diário reflexivo), com ajustes solicitados.

## [12/11/2026]

### Adicionado

- Gatilho de apoio emergencial para sofrimento intenso (SCRUM-31, UC20, RN11): regra local que identifica 3 dias seguidos de humor negativo (`triste`, `ansioso`, `comRaiva`) e mostra, no máximo uma vez por dia, um modal acolhedor na voz do mascote com ligação para o CVV 188, Canais de Apoio e FAQ, relato anônimo (quando as telas existirem) e "Agora não". Roda 100% offline e não envia nada ao Firestore (`lib/modules/student/support_trigger/`).
- Estado de controle do gatilho no aparelho (`SupportTriggerStateStore`, chave `support_trigger_state` no `SharedPreferences`).
- Testes da regra, do armazenamento, do controller e do modal (`test/modules/student/support_trigger/`).
- UC20 e RN11 em `docs/modelagem/01-casos-de-uso.md`; entidade local `EstadoGatilhoApoio` no diagrama de classes e no mapeamento.

### Modificado

- `CvvButton.dial()` passa a ser reaproveitado pelo modal de apoio, sem duplicar a discagem.

## [14/11/2026]

### Adicionado

- Botão de emergência "Ajuda (CVV)" fixo nas telas funcionais do aluno (Home e rotas de diário, chat anônimo e FAQ), que disca 188 pelo discador nativo (`url_launcher`) e não depende de internet (RF05).
- `CvvOverlay` e `CvvRouteObserver` (`lib/shared/widgets/cvv_button/cvv_overlay.dart`), aplicados em `MaterialApp.builder` para sobrepor o botão a todas as rotas.
- Teste de widget do overlay (`test/cvv_overlay_test.dart`): botão visível apenas nas telas do aluno, oculto em splash, onboarding, login, pais e psicólogo, e disparo da ação.
- Revisão dos PRs #11 (diário reflexivo), #12 (diário de sentimentos) e #15 (CVV 188), com ajustes solicitados, e aprovação do PR #16 (responsabilidades no README).

### Modificado

- Botão CVV oculto em splash, onboarding, telas de login e homes de pais e psicólogo.
- Botão CVV removido da Home do aluno (`StudentHomeView` e `test/home_view_test.dart`), pois passou a ser exibido pelo overlay global.
- Rota `/diary` (`HomeController.diaryRoute`) registrada em `AppWidget.routes`, integrando os atalhos da Home do aluno à tela do Diário de Sentimentos (`DiaryFeelingsView`).

## [16/11/2026]

### Modificado

- Diário Pessoal: o calendário da semana ganhou setas para ver semanas anteriores, e tocar num dia mostra só os registros dele ("Ver todos" volta à lista completa). Dias futuros ficam desativados.
- Seletor de emoção (RF01): o mascote Breno substitui o emoji no centro do disco, com a cara de cada emoção (as mesmas do "Resumo da semana" da Home, mais uma nova para Cansado, `assets/home/mood_tired.svg`) e o fundo na cor da emoção escolhida.
- Diário Pessoal: a folha "Como você está se sentindo?", a lista de registros e o botão de humor mostram o Breno com a cara de cada emoção no lugar dos rostinhos desenhados.
- Seletor de emoção (RF01): um sentimento por dia. Se já houver registro hoje, a roda abre no humor registrado, avisa "Hoje você registrou: X" e salvar altera o humor do dia (mantendo texto e pontos positivos) em vez de criar outro registro.

### Adicionado

- Pipeline CI/CD: etapas de `flutter analyze` e `flutter test` antes do build, cache do Gradle e Flutter SDK fixado em 3.44.0.
- Pipeline CI/CD: assinatura do APK com keystore fixo restaurado de Secret (`ANDROID_KEYSTORE_BASE64`) e `versionCode` igual ao `run_number` do workflow, para que cada build seja aceito como atualização nos celulares dos testadores (`android/app/build.gradle.kts`).

## [17/11/2026]

### Adicionado

- Pipeline CI/CD com GitHub Actions e Firebase App Distribution integrada à `main` (PR #13).
- Revisão e aprovação dos PRs #11 (diário reflexivo e checklist de pontos positivos), #12 (diário de sentimentos por emojis) e #15 (CVV 188).

## [18/11/2026]

### Adicionado

- FAQ Empático Dinâmico e Canais de Apoio para o estudante (`StudentFaqView`, `StudentFaqController`, `FaqExpandableCard`, `FaqModel` e `FirestoreFaqRepository` / `LocalFaqRepository` — RF04 / SCRUM-33), com busca por palavras-chave, cards expansíveis fiéis ao protótipo do Figma, cache em `SharedPreferences` e fallback offline.
- Painel Institucional de Publicação e Edição do FAQ para a psicóloga (`PsychologistFaqView` e `PsychologistFaqController` — RF08 / SCRUM-36), com CRUD completo (criar, listar, editar e excluir perguntas e orientações no Firestore/cache local) e atalho no `PsychologistHomeView`.
- Suíte de testes automatizados de unidade, widgets e auditoria de acessibilidade WCAG AA (contraste $\ge 4,5:1$ e áreas mínimas de toque $\ge 48\times 48\text{dp}$ — SCRUM-41 / SCRUM-44) em `test/shared/faq/`, `test/modules/student/faq/`, `test/modules/psychologist/faq/` e `test/accessibility_wcag_test.dart`.
- Revisão e aprovação dos PRs #14 (gatilho de apoio emergencial) e #17 (correção da roleta do diário).

### Modificado

- Rotas `/faq` (`HomeController.faqRoute`) e `/psychologist/faq` (`PsychologistFaqView.routeName`) registradas em `AppWidget.routes` e repositório do FAQ injetado no bootstrap (`main.dart`).

### Corrigido

- Roleta do Diário de Sentimentos (`DiaryFeelingsView` — RF01 / SCRUM-28): restaurado o emoji central (`EmotionFacePainter`) fiel ao protótipo do Figma e corrigida a área de captura de gestos (`Positioned` e física do `SingleChildScrollView`) para permitir girar a roleta livremente em qualquer posição do dedo (topo, laterais ou centro).

## [19/11/2026]

### Adicionado

- Proteção por PIN no Diário Pessoal (`DiaryReflectionView`): o cadeado da App Bar abre opções para criar, alterar ou remover um PIN de 4 números. Com o PIN ativo, o ícone fica azul e a tela pede o PIN antes de mostrar os registros ("PIN incorreto" limpa o campo). Alterar e remover exigem o PIN atual.
- `DiaryLockRepository` / `PrefsDiaryLockRepository` e `DiaryLockController`: o PIN fica só no aparelho (`SharedPreferences`, chave `diario_pin`), guardado como hash SHA-256 com salt, nunca em texto puro, e funciona offline. PIN salvo corrompido é tratado como "sem PIN", para o aluno não ficar trancado fora do diário.
- Testes do repositório, do controller e da tela do PIN (`test/modules/student/diary/`).
- Revisão do PR #18 (FAQ dinâmico e painel da psicóloga), com ajustes solicitados.

### Modificado

- Pacote `crypto` adicionado ao `pubspec.yaml` (já vinha como dependência indireta) e repositório do PIN injetado no bootstrap (`main.dart`).

## [20/11/2026]

### Modificado

- Home do psicólogo (`PsychologistHomeView` e `UserModel`): removido nome mockado, passando a exibir o nome e a foto (`photoUrl`) vindos do documento `users/{uid}` no Firestore na AppBar, e redimensionado o card "Editar Perguntas Frequentes (FAQ)" para o formato compacto do Figma (`152x142`, fundo `#F4F4F5`).
- Painel de FAQ da psicóloga (`PsychologistFaqView`): botões de editar e excluir agora são revelados exclusivamente ao arrastar o card da pergunta para o lado esquerdo.
- Tela de Canais de Apoio & FAQ do aluno (`StudentFaqView`): cores dos cards de Canais de Apoio ajustadas aos valores exatos do Figma (`#FFE2E2` com ícone `#FB2C36` para CVV e `#DFF2FE` com ícone `#00A6F4` para Denúncias anônimas).
- Coleção `faq` no Firestore (`FaqModel` e `FirestoreFaqRepository`): campos padronizados em inglês (`question`, `answer`, `createdAt`, `updatedAt`, `updatedBy`), seguindo a mesma convenção da coleção `users`.
- Gatilho de apoio emergencial (SCRUM-31, UC20, RN11) ligado ao diário: o modal é avaliado depois de salvar o humor na roda de sentimentos (`DiaryFeelingsView`) e no Diário Pessoal (`DiaryReflectionView`), sem passos a mais no registro.
- Nomes das imagens de humor alinhados ao `Humor.brenoAsset` na regra do gatilho (`confused` corresponde a `ansioso` e `tired` a `cansado`).

## [21/11/2026]

### Adicionado

- Perfil do usuário (SCRUM-51): tocar no avatar da Home do aluno (ou no ícone de perfil das Homes de psicóloga e responsável) abre um painel com codinome/avatar (aluno) ou nome, e-mail e papel (perfis institucionais), e a opção "Sair da conta".
- Logout com confirmação (SCRUM-51): o aluno é avisado de que o perfil anônimo e os registros do diário serão apagados do aparelho (e o logout passa a apagá-los de fato: diário e estado do gatilho de apoio); depois de sair, o app volta ao `/onboarding`. `InstitutionalSession` passou a carregar o e-mail da conta.

### Modificado

- Logout do aluno (SCRUM-51, `AuthRepository.signOut`): além do perfil, apaga o diário e o estado do gatilho de apoio guardados no aparelho, por meio do novo parâmetro opcional `clearStudentData` (ligado no `main.dart`). Logout de psicóloga e responsável não apaga nada local.
- Homes de psicóloga e responsável (SCRUM-51): o botão "Sair" sem confirmação foi trocado por um ícone de perfil na barra superior, que abre o mesmo painel de perfil.
- Guia e lista de Canais Oficiais de Denúncia e Apoio para o aluno (`OfficialChannelsView`, rota `/faq/canais-oficiais` — RF06 / SCRUM-34): Disque 100, Conselho Tutelar e Ouvidoria Escolar, com o que cada canal faz, quando procurar e como entrar em contato. Só o Disque 100 tem botão "Ligar 100", porque os outros dois não têm número nacional. A lista é fixa no app e funciona offline. A tela traz também um aviso para ligar 190 em perigo imediato.
- Função de discagem compartilhada `dialPhoneNumber` (`lib/shared/utils/phone_dialer.dart`), que abre o discador nativo com qualquer número.
- Testes da nova tela, da discagem e da auditoria WCAG AA das cores novas (`test/modules/student/official_channels/`, `test/shared/utils/` e `test/accessibility_wcag_test.dart`).
- Entrada do aluno sem internet (RNF02, EPIC-03): se o login anônimo do Firebase falhar por falta de rede, o aluno entra com uma sessão local (`ProfileStore.localUid()`, id `local-<hex>` guardado no aparelho) e usa o diário normalmente. O login anônimo é refeito sozinho na próxima abertura do app com internet.
- Testes do `AuthRepository` com Firebase simulado (`test/shared/auth/auth_repository_test.dart`) e do onboarding em telas baixas (`test/modules/onboarding/onboarding_view_test.dart`).
- Bateria de testes de falha de conexão (EPIC-09) em `test/offline/`: FAQ, painel da psicóloga, diário e botão CVV sem internet e na reconexão, com um Firestore simulado em que a escrita fica pendente até a rede voltar.
- Roteiro e resultados da bateria offline no emulador Android 7.0 (`docs/testes/bateria-offline.md`).
- Especificação técnica dos mappers Documento (Firestore e aparelho) ↔ entidade de domínio: `toMap()`, `fromMap()`, conversores do Firestore, serialização JSON e tratamento de nulos (`docs/modelagem/05-especificacao-mappers.md`).
- Mascote de acolhimento (RF03 / SCRUM-30): o resumo da semana da Home do aluno passa a ser uma escala de 1 a 5 (raiva, triste, confuso, neutro, feliz) calculada pela média dos humores dos últimos 7 dias. O cérebro do nível atual fica em destaque (opacidade total e brilho verde) e a escala é recalculada ao voltar da roleta de sentimentos. Sem registros na semana, nenhum cérebro é destacado.
- Revisão e aprovação dos PRs #18 (FAQ dinâmico e painel da psicóloga), #19 (mascote de acolhimento), #21 (especificação dos mappers), #22 (justificativas do `pubspec`), #23 (responsabilidades no README), #24 (PIN do diário), #25 (persistência offline), #26 (testes offline) e #27 (canais oficiais de denúncia e apoio).
- Revisão técnica do PR #28 (atualização de `README.md`, `CHANGELOG.md` e `docs/uso-de-ia.md`), com verificação de conflitos e sugestões de organização das sprints e referências.
- Painel de Gestão e Triagem de Relatos Anônimos da psicóloga (RF09 / EPIC-06): nova tela `ReportsView` (rota `/psychologist/reports`) que lista as denúncias recebidas como "Mensagem anônima #NNN", com selos de status, gravidade e tipo, contador de relatos, puxar para atualizar e estados de carregamento, vazio e erro (com "Tentar novamente"). A lista segue a ordem de triagem: mais grave primeiro e, na mesma gravidade, o relato mais antigo.
- Card "Triagem das denúncias" na Home da psicóloga (`ReportsSummaryCard`), com as duas denúncias pendentes mais urgentes e o botão "Ver todas as denúncias".
- Entidade `Report` (`ReportType`, `ReportStatus`, `ReportSeverity`) em `lib/shared/models/report_model.dart` e `ReportRepository` em `lib/shared/reports/report_repository.dart` (`FirestoreReportRepository`, que lê a coleção `reports`, e `LocalReportRepository`, em memória). O `studentUid` do documento nunca é lido, para manter o anonimato. Quando o documento não traz `severity`, ela é estimada pelo tipo e por sinais de risco no texto (regra provisória, a validar com a equipe de psicologia).
- Nomes de arquivos, coleções e campos do Firestore em inglês no painel de triagem: coleção `reports` com `studentUid`, `type`, `description`, `status` (`pending`, `inMediation`, `answered`), `severity` (`low`, `medium`, `high`), e `createdAt`.
- Testes do modelo, do controller, da tela, do card da Home e do contraste WCAG AA dos novos selos (`test/shared/models/`, `test/modules/psychologist/reports/` e `test/accessibility_wcag_test.dart`).
- Chat anônimo do aluno com a escola em tempo real (RF05): nova tela `AnonymousChatView` (rota `/report`, aberta pelos cards "Chat Anônimo" da Home e "Denúncias anônimas à escola" do FAQ e pelo modal de apoio). O aluno escolhe o assunto da conversa (bullying, cyberbullying ou outros), escreve a mensagem e acompanha a conversa, com balões do aluno e da psicóloga, separação por dia ("Hoje" e "Ontem"), horário e rolagem automática até a última mensagem. As respostas da psicóloga aparecem na hora, sem recarregar a tela.
- `AnonymousChatController` e `ChatRepository` (`FirestoreChatRepository` e `InMemoryChatRepository`): a conversa é o documento `reports/{uid do aluno}` e as mensagens ficam em `reports/{uid}/messages` (`senderRole`, `text` e `createdAt`), acompanhadas com `snapshots(includeMetadataChanges: true)`. A primeira mensagem cria o relato que aparece no painel de triagem da psicóloga; se o aluno voltar a escrever depois de respondido, o relato volta para pendente.
- Chat sem internet: a mensagem entra na fila do Firestore e aparece como "Enviando…" até sincronizar. Sem login no Firebase (sessão local), o campo fica desativado com aviso. Limite de 2000 caracteres por mensagem, com mensagem vazia ignorada.
- Modelagem do Firestore (`docs/modelagem/03-modelagem-firestore.md`): subcoleção `messages`, relato com id igual ao `uid` do aluno (sem índice extra), campo `reply` removido e regras de segurança do chat e do status do relato.
- Testes do controller (inclusive resposta em tempo real e falhas), da tela, do modelo de mensagem e do contraste WCAG AA dos balões (`test/modules/student/chat/` e `test/accessibility_wcag_test.dart`).

### Modificado

- Tela "Canais de Apoio & FAQ" (`StudentFaqView`): novo card "Canais oficiais de denúncia" (`#FEF3C7` com ícone `#B45309`) entre o CVV e as denúncias anônimas.
- Botão "Ajuda (CVV)" (`CvvButton`): passa a usar a discagem compartilhada, sem mudar o comportamento (continua ligando 188).
- Responsabilidades de Alexandre Pedro de Matos Ferreira atualizadas em `README.md` e registro de uso de IA da Sprint 4 consolidado em `docs/uso-de-ia.md`.

### Corrigido

- Diário Pessoal (`PrefsDiaryRepository`): um registro em formato inesperado não derruba mais a leitura do diário inteiro. Se a chave `diario` estiver ilegível, o conteúdo é copiado para `diario_corrompido` e o diário volta a funcionar.
- Sair da conta numa sessão offline agora também apaga o perfil local, para o app não entrar de novo sozinho.
- Onboarding (`OnboardingView`): o conteúdo passa a rolar. No Android 7 (731 dp de altura) ele estourava 194 px e o botão "Entrar como aluno" ficava fora da área de toque.
- Painel de FAQ da psicóloga (`FirestoreFaqRepository`): salvar ou excluir uma pergunta sem internet deixava a tela em "Salvando…" até a rede voltar. Agora a escrita é esperada por no máximo 2 s e segue na fila offline do Firestore, que a envia na reconexão. A leitura da lista ganhou limite de 6 s, e de 1 s logo depois de uma escrita sem resposta.
- Acessibilidade (SCRUM-30): os cérebros da escala da Home são anunciados por leitores de tela ("Escala N de 5: humor", com "(nível atual)" no destacado) e o rosto central da roleta de sentimentos é anunciado como botão "Registrar humor <humor>".

## [22/11/2026]

### Corrigido

- Chat anônimo do aluno (`AnonymousChatController`): a falha ao acompanhar a conversa não culpa mais a internet por qualquer erro. Agora há mensagem própria para falta de rede (`unavailable`), para regra de segurança que nega o acesso (`permission-denied`) e para os demais erros, e o erro real passa a ser registrado no log (`debugPrint`). Testes em `test/modules/student/chat/`.

### Adicionado

- Chat da psicóloga com o aluno em tempo real (RF10): nova tela `PsychologistChatView` (rota `/psychologist/chat`, com `ReportChatArgs`), que mostra a conversa inteira do relato com o aluno identificado só como "Aluno anônimo" e pelo número do protocolo. A psicóloga responde por ali, e as mensagens novas do aluno aparecem sozinhas. Sem mensagens gravadas (relato criado direto no console), o texto do relato aparece como a primeira mensagem.
- Status do relato no chat da psicóloga: a primeira resposta a um relato pendente muda o status para respondido; um relato em mediação continua em mediação, e se o aluno volta a escrever o relato volta para pendente.
- `PsychologistChatController` e `PsychologistChatRepository` (`FirestorePsychologistChatRepository` e `InMemoryPsychologistChatRepository`): a resposta grava a mensagem com `senderRole: psychologist` e atualiza o status no mesmo lote, sem gravar nenhum dado da psicóloga na mensagem.
- Painel de triagem em tempo real: `ReportRepository.watch()` (`snapshots()` do Firestore) no lugar da leitura única. Relatos novos, mensagens e mudanças de status aparecem na lista e no resumo da Home sem recarregar.
- Widgets de chat compartilhados entre aluno e psicóloga (`lib/shared/widgets/chat/chat_widgets.dart`: balões, separador de dia, campo de mensagem e barra superior) e `ChatMessage` em `lib/shared/models/`.
- Testes do controller e da tela do chat da psicóloga, do painel em tempo real e do botão "Responder" (`test/modules/psychologist/chat/` e `test/modules/psychologist/reports/`).
- Atualização in-app anônima via GitHub Releases (`lib/shared/app_update/`), sem login nem token:
  - Ao abrir o app com internet, `AppUpdateRepository` consulta o endpoint público `GET /repos/maarcos4g/mente-leve/releases/latest` (timeout de 5 s) e compara a `tag_name` com o `versionName` instalado (`package_info_plus`). `AppVersion` compara `major.minor.patch` e aceita `v1.2.3`, `1.2.3+4` e `v1.2`.
  - `ReleaseInfo` escolhe o primeiro asset `.apk` da release e ignora rascunho, pré-lançamento, download fora de HTTPS e JSON inesperado.
  - Offline, timeout, limite de requisições (403/429), 404 (sem releases) ou resposta inválida são ignorados em silêncio: o app abre normalmente.
  - Modal acolhedor (`AppUpdateDialog`, mesma identidade do modal de apoio: cantos de 24, mascote sobre o rosa da marca, botões de 48 dp, modo escuro) com "Atualizar agora" e "Agora não". Durante o download mostra barra de progresso com porcentagem e não pode ser fechado; se algo falhar ou a permissão for negada, tranquiliza e oferece "Tentar de novo".
  - `ApkDownloader` baixa o APK para o cache do app, informa o progresso e confere o tamanho e o SHA-256 (`digest`) do asset, apagando o arquivo se não baterem. `AndroidApkInstaller` pede "Instalar apps desconhecidos" só se ainda não concedida e abre o instalador nativo do Android.
  - `AppUpdateController` (estados: disponível, baixando, instalando, instalador aberto, permissão negada e falha) e `AppUpdatePrompter`, que dispara a verificação em paralelo à splash e só abre o modal numa tela inicial (aluno, responsável ou psicóloga), uma vez por execução, sem interromper o diário ou o chat. A verificação só roda no Android.
  - Pipeline (`.github/workflows/ci_cd.yml`): ao criar uma tag `vX.Y.Z`, a publicação é automática, sem editar o `pubspec.yaml` nem criar tag à mão. A cada push na `main` que altera arquivos do app (`lib/`, `assets/`, `android/`, `pubspec.yaml` ou `pubspec.lock`) desde a última tag, o workflow calcula a próxima versão, compila o APK, cria a tag `vX.Y.Z` e publica uma GitHub Release pública com `mente-leve-vX.Y.Z.apk`. Mudanças só em docs, testes ou CI não geram Release. Incremento pelas mensagens de commit: `!:` ou `BREAKING CHANGE` sobe o major, `feat:` o minor e qualquer outra o patch. Também dá para forçar a publicação, a partir de qualquer branch, em Actions → Run workflow, escolhendo `patch`, `minor` ou `major`.
  - Permissões `INTERNET` e `REQUEST_INSTALL_PACKAGES` declaradas no `AndroidManifest.xml`.
  - Dependências: `http`, `package_info_plus`, `path_provider`, `open_filex` e `permission_handler`.
  - 57 testes novos em `test/shared/app_update/` (versão, release, repositório com `MockClient`, download, controller, modal e coordenação na inicialização).

### Modificado

- Cards da triagem (`ReportCard`, na tela de triagem e na Home): o botão "Ver relato" e a folha com o texto completo foram substituídos pelo botão "Responder", que abre o chat do relato.
- Botão "Responder" ajustado ao Figma: cor `sky500`, ícone `lucide/undo`, padding de 16 na horizontal e 4 na vertical e 8 entre o ícone e o texto. A área de toque continua com 48 dp.
- Tela do chat do aluno (`AnonymousChatView`): passou a usar os widgets de chat compartilhados, sem mudar o comportamento.
- Mensagem de erro do painel de triagem: separa falta de rede, permissão negada e demais falhas, e registra o erro real no log.
- Chat do aluno (`AnonymousChatView`): o assunto da conversa deixou de vir pré-selecionado em "Bullying". O aluno precisa escolher o assunto (bullying, cyberbullying ou outros) antes de enviar a primeira mensagem; sem escolher, a mensagem não é enviada e a tela avisa "Escolha o assunto da conversa antes de enviar.". Testes em `test/modules/student/chat/`.
<<<<<<< HEAD
- Responsabilidades de Abraão Luiz Ribeiro da Cruz Dantas atualizadas em `README.md` (diário reflexivo, Breno, um sentimento por dia, PIN do diário, persistência offline e bateria de testes offline).
=======
- Pipeline de CI/CD: o workflow passou a rodar também em tags `v*` e a ter `permissions: contents: write`, usado só para criar a Release em builds de tag. A versão do app deixou de depender do `pubspec.yaml`: o `versionName` vem da última tag (ou da próxima, quando há Release) e o `versionCode` passou a ser `(MAJOR*10000 + MINOR*100 + PATCH) * 10000 + run_number`. Assim, o APK de uma Release mais nova sempre tem código maior que qualquer build de versão anterior, inclusive os da `main` distribuídos no Firebase, e o Android não recusa a atualização por downgrade.
- `AndroidManifest.xml`: as permissões de armazenamento e mídia que o `open_filex` traz (`READ_EXTERNAL_STORAGE`, `READ_MEDIA_*`) foram removidas do manifesto final, porque o app não as usa (o APK fica no cache do próprio app).
- `permission_handler` fixado na linha 12.x: a 13.x exige `compileSdk` 37, acima do que o Android Gradle Plugin do projeto recomenda (36), e quebrava o build.
>>>>>>> origin/main

### Removido

- Filtros de **gravidade** e de **status de mediação** da tela de triagem (`ReportsView`), que não estavam no protótipo do Figma, junto do estado "Nenhuma denúncia com esses filtros" e do botão "Limpar filtros". A lista continua na ordem de triagem (mais grave primeiro e, na mesma gravidade, o mais antigo), e o `ReportsController` perdeu `filterBySeverity`, `filterByStatus`, `clearFilters` e `visible` (agora `sorted`).
- Painel "Gerenciar relato" do chat da psicóloga (`PsychologistChatView`), com os seletores de status de mediação e de gravidade, e o código que o sustentava (`setStatus` e `setSeverity` no `PsychologistChatController` e no `PsychologistChatRepository`). A ideia de filtro e de classificação manual não existe no protótipo; o chat da psicóloga ficou só com a conversa, como no Figma.
- `CLAUDE.md` (instruções locais do assistente de IA) removido do repositório e adicionado ao `.gitignore`, junto da pasta `.claude/`.
