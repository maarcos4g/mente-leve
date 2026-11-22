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
- Coleção `faq` no Firestore (`FaqModel` e `FirestoreFaqRepository`): campos padronizados em inglês (`question`, `answer`, `createdAt`, `updatedAt`, `updatedBy`), seguindo a mesma convenção da coleção `users`.0
- Gatilho de apoio emergencial (SCRUM-31, UC20, RN11) ligado ao diário: o modal é avaliado depois de salvar o humor na roda de sentimentos (`DiaryFeelingsView`) e no Diário Pessoal (`DiaryReflectionView`), sem passos a mais no registro.
- Nomes das imagens de humor alinhados ao `Humor.brenoAsset` na regra do gatilho (`confused` corresponde a `ansioso` e `tired` a `cansado`).

## [21/11/2026]

### Adicionado

- Guia e lista de Canais Oficiais de Denúncia e Apoio para o aluno (`OfficialChannelsView`, rota `/faq/canais-oficiais` — RF06 / SCRUM-34): Disque 100, Conselho Tutelar e Ouvidoria Escolar, com o que cada canal faz, quando procurar e como entrar em contato. Só o Disque 100 tem botão "Ligar 100", porque os outros dois não têm número nacional. A lista é fixa no app e funciona offline. A tela traz também um aviso para ligar 190 em perigo imediato.
- Função de discagem compartilhada `dialPhoneNumber` (`lib/shared/utils/phone_dialer.dart`), que abre o discador nativo com qualquer número.
- Testes da nova tela, da discagem e da auditoria WCAG AA das cores novas (`test/modules/student/official_channels/`, `test/shared/utils/` e `test/accessibility_wcag_test.dart`).
- Entrada do aluno sem internet (RNF02, EPIC-03): se o login anônimo do Firebase falhar por falta de rede, o aluno entra com uma sessão local (`ProfileStore.localUid()`, id `local-<hex>` guardado no aparelho) e usa o diário normalmente. O login anônimo é refeito sozinho na próxima abertura do app com internet.
- Testes do `AuthRepository` com Firebase simulado (`test/shared/auth/auth_repository_test.dart`) e do onboarding em telas baixas (`test/modules/onboarding/onboarding_view_test.dart`).
- Especificação técnica dos mappers Documento (Firestore e aparelho) ↔ entidade de domínio: `toMap()`, `fromMap()`, conversores do Firestore, serialização JSON e tratamento de nulos (`docs/modelagem/05-especificacao-mappers.md`).
- Mascote de acolhimento (RF03 / SCRUM-30): o resumo da semana da Home do aluno passa a ser uma escala de 1 a 5 (raiva, triste, confuso, neutro, feliz) calculada pela média dos humores dos últimos 7 dias. O cérebro do nível atual fica em destaque (opacidade total e brilho verde) e a escala é recalculada ao voltar da roleta de sentimentos. Sem registros na semana, nenhum cérebro é destacado.
- Revisão e aprovação dos PRs #18 (FAQ dinâmico e painel da psicóloga), #19 (mascote de acolhimento), #21 (especificação dos mappers), #22 (justificativas do `pubspec`), #23 (responsabilidades no README), #24 (PIN do diário), #25 (persistência offline), #26 (testes offline) e #27 (canais oficiais de denúncia e apoio).

### Modificado

- Tela "Canais de Apoio & FAQ" (`StudentFaqView`): novo card "Canais oficiais de denúncia" (`#FEF3C7` com ícone `#B45309`) entre o CVV e as denúncias anônimas.
- Botão "Ajuda (CVV)" (`CvvButton`): passa a usar a discagem compartilhada, sem mudar o comportamento (continua ligando 188).

### Corrigido

- Diário Pessoal (`PrefsDiaryRepository`): um registro em formato inesperado não derruba mais a leitura do diário inteiro. Se a chave `diario` estiver ilegível, o conteúdo é copiado para `diario_corrompido` e o diário volta a funcionar.
- Sair da conta numa sessão offline agora também apaga o perfil local, para o app não entrar de novo sozinho.
- Onboarding (`OnboardingView`): o conteúdo passa a rolar. No Android 7 (731 dp de altura) ele estourava 194 px e o botão "Entrar como aluno" ficava fora da área de toque.
- Acessibilidade (SCRUM-30): os cérebros da escala da Home são anunciados por leitores de tela ("Escala N de 5: humor", com "(nível atual)" no destacado) e o rosto central da roleta de sentimentos é anunciado como botão "Registrar humor <humor>".
