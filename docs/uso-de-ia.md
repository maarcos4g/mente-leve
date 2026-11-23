# Registro de Uso de Inteligência Artificial — MenteLeve

Este documento registra como a equipe do **MenteLeve** utiliza ferramentas de Inteligência Artificial Generativa como apoio ao desenvolvimento do projeto.

O objetivo é manter o registro transparente: a IA é utilizada como suporte técnico para tirar dúvidas, revisar código e auxiliar em tarefas operacionais, sendo que todo o trabalho é revisado e validado pelos integrantes.

---

## Registros de Uso por Sprint

## Sprint 1

### Alexandre Pedro de Matos Ferreira

* **Automação e Integração com Jira:**
  * **O que foi feito:** Apoio na estruturação inicial das tarefas do projeto (épicos, histórias e tarefas, com critérios de aceite e calendário de quatro sprints) e escrita de um script em Python para cadastrar os itens na API do Jira Cloud.
  * **Ferramenta utilizada:** Antigravity (Gemini 3.6 flash).
  * **Prompts utilizados:**
    * > Atue como um Scrum Master experiente. Escreva um script em Python que crie épicos e tarefas em lote em um projeto SCRUM do Jira Cloud via API, com descrições em Atlassian Document Format, tarefas filhas vinculadas aos épicos e atribuídas às sprints.
    * > Atue como um gerente de projetos ágil. Monte um calendário de desenvolvimento em quatro sprints, priorizado da fase inicial até a final.
  * **Como a IA ajudou:** Ajudou na montagem da requisição HTTP, na formatação das descrições, na vinculação das tarefas filhas aos épicos e na atribuição das tarefas às sprints.
  * **Dificuldades e ajustes manuais:**
    1. **Campo de estimativa:** A IA indicou um código de campo incorreto (`customfield_10026`), que causava erro `400` na API do Jira. Foi necessário consultar os metadados dos campos e a documentação para achar o campo certo (`customfield_10016`).
    2. **Nome das sprints:** A IA sugeriu nomes com mais de 30 caracteres, que a API rejeita. Os nomes foram reduzidos manualmente e as descrições movidas para o objetivo (*goal*) da sprint.
    3. **Acentuação no Windows:** O `json.dumps()` escapava os caracteres em português, quebrando verificações condicionais. A correção foi usar `ensure_ascii=False` e definir a codificação UTF-8.
    4. **Campos de hierarquia:** A IA enviava ao mesmo tempo `parent` e o campo legado `customfield_10014` (Epic Link), gerando avisos. O payload passou a usar somente `parent`.

* **Revisão Técnica de Código (Pull Request #5 — 05/11):**
  * **O que foi feito:** Revisão do PR com o setup inicial do Flutter, temas e telas de login/avatar.
  * **Ferramenta utilizada:** Antigravity (Gemini 3.6 flash).
  * **Prompt utilizado:**
    > Atue como um desenvolvedor Flutter sênior. Revise o código deste Pull Request (setup inicial, temas e telas de login/avatar) e aponte possíveis problemas visuais e inconsistências antes do merge na `main`.
  * **Como a IA ajudou:** Apontou o risco de *overflow* (quando o teclado do celular sobe e estoura a tela) na tela de identificação do aluno por falta de scroll, e sugeriu unificar cores soltas para o padrão do tema.
  * **Dificuldades e ajustes manuais:** A IA considerou recursos muito recentes do Flutter (como `spacing` em Row/Column), mas mantivemos o uso de `SizedBox` para evitar problemas de compilação em computadores com versões anteriores do SDK.

* **Organização do Repositório e Documentação (05/11):**
  * **O que foi feito:** Reorganização da pasta `docs/`, padronização dos nomes dos fluxogramas e criação do sumário (`docs/README.md`).
  * **Ferramenta utilizada:** Antigravity (Gemini 3.6 flash).
  * **Prompt utilizado:**
    > Atue como um especialista em documentação de projetos. Reorganize a pasta `docs/` separando apresentações, protótipos e diagramas, padronize os nomes dos fluxogramas e crie um sumário para facilitar a navegação no GitHub.
  * **Como a IA ajudou:** Auxiliou na estrutura de pastas e na padronização dos nomes.
  * **Dificuldades e ajustes manuais:** Nenhuma dificuldade relevante registrada.

### Abraão Luiz Ribeiro da Cruz Dantas

*(A preencher pelo integrante)*

### Marcos Paulo

* **Reorganização da pasta `docs/` em subpastas temáticas (05/11):**
  * **O que foi feito:** Criação das subpastas `docs/modelagem/` (casos de uso, diagrama de classes, modelagem Firestore e mapeamento Dart) e `docs/levantamento/` (benchmark, escopo, estudo de caso, funcionalidades, justificativas, pesquisa e requisitos), mantendo as pastas já existentes sem alteração.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompt utilizado:**
    > **Atue como** um especialista em documentação de projetos de software.
    >
    > **Tarefa:** reorganizar a pasta `docs/`.
    >
    > **Regras:**
    > 1. Manter as pastas que já existem, sem alterá-las.
    > 2. Mover casos de uso, diagrama de classes, modelagem Firestore e mapeamento Dart para uma nova subpasta.
    > 3. Mover benchmark, escopo, estudo de caso, funcionalidades, justificativas, pesquisa e requisitos para outra nova subpasta.
    > 4. Criar as subpastas dentro de `docs/` e sugerir os nomes delas.
    > 5. Atualizar os links internos que quebrarem com a mudança.
  * **Como a IA ajudou:** Sugeriu os nomes das pastas, moveu os arquivos com `git mv` (preservando o histórico) e corrigiu os caminhos das imagens e as referências em `eap.md`, `escopo.md` e `CHANGELOG.md`.
  * **Dificuldades e ajustes manuais:** As referências antigas em `escopo.md` e `CHANGELOG.md` já estavam desatualizadas (nomes que não batiam com os arquivos reais), e foram corrigidas na mesma ocasião. Os nomes das subpastas foram revisados antes de seguir.

* **Telas de login do psicólogo e do responsável (03/11):**
  * **O que foi feito:** Criação das telas `PsychologistAuthView` e `ParentsAuthView`, de seus controllers com validação de formulário e do widget reutilizável `ProfileAuthScaffold` (cabeçalho com logo, ilustração, campos e botão de entrada).
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompt utilizado:**
    > **Atue como** um desenvolvedor Flutter sênior.
    >
    > **Tarefa:** criar as telas de login dos perfis psicólogo e responsável, seguindo o padrão visual da tela de login do aluno.
    >
    > **Requisitos:**
    > 1. Psicólogo: campos de e-mail institucional e senha, com validação de e-mail por expressão regular.
    > 2. Responsável: campos de número de identificação (teclado numérico) e senha fornecida pela escola.
    > 3. Mensagens de erro para campo vazio e e-mail inválido.
    > 4. Um controller por tela (`formKey` e métodos de validação), sem integrar a autenticação ainda.
    > 5. Extrair o layout em comum para um widget reutilizável, evitando código duplicado entre as telas.
    > 6. Usar as cores do tema e o campo de texto compartilhado do projeto.
  * **Como a IA ajudou:** Estruturou o `ProfileAuthScaffold` com `SingleChildScrollView`, o que evita *overflow* quando o teclado sobe, e reaproveitou o mesmo widget nas duas telas, deixando cada uma só com os campos e o texto de apoio.
  * **Dificuldades e ajustes manuais:** A integração com a autenticação ficou como pendência (comentário no `onSubmit`), pois depende do backend. Foi necessário revisar manualmente as cores usadas no cabeçalho para manter o padrão do tema.

* **Criação do arquivo de cores Tailwind (03/11):**
  * **O que foi feito:** Criação de `lib/shared/themes/tailwind_colors.dart`, com a paleta do Tailwind CSS (v3.4) como constantes Dart, para uso como `TailwindColors.sky500`.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompt utilizado:**
    > **Atue como** um desenvolvedor Flutter com experiência em design systems.
    >
    > **Tarefa:** criar uma classe `TailwindColors` com a paleta de cores do Tailwind CSS v3.4.
    >
    > **Requisitos:**
    > 1. Uma constante `Color` para cada tom (50 a 950) de cada família de cores, além de `black` e `white`.
    > 2. Nomes no padrão `familiaTom` (ex.: `blue500`, `slate900`).
    > 3. Construtor privado e constantes `static const`, sem instanciar a classe.
    > 4. Valores em hexadecimal idênticos aos da documentação oficial do Tailwind.
  * **Como a IA ajudou:** Gerou as constantes de todas as famílias da paleta, organizadas por comentários de seção, o que evitou digitar os valores à mão.
  * **Dificuldades e ajustes manuais:** Os valores hexadecimais gerados precisaram ser conferidos com a documentação oficial do Tailwind, já que a IA pode errar algum tom. Também foi preciso confirmar que as cores usadas nas telas (como `sky500` e `zinc50`) existem na classe.

### Mateus Henrique de Araújo Santos

* **Tela inicial (Home) fiel ao protótipo (08/11):**
  * **O que foi feito:** Criação da `HomeView` e do `HomeController` (`lib/modules/student/home/`), dos widgets `HomeHeader`, `MoodPromptCard`, `WeekSummary`, `MoodBubble` e `HomeFeatureCard`, do botão compartilhado `CvvButton` e da rota `/home`. O "Continuar" do codinome passou a abrir a Home. Foram adicionados o `url_launcher` (discar 188 pelo discador nativo, sem internet) e o teste de widget `test/home_view_test.dart`.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5), com o MCP do Figma para ler o nó `home` do design system.
  * **Prompt utilizado:**
    > Nova task: ler a documentação em `claude-md` e, de acordo com as diretrizes do projeto, construir a tela inicial (Home) fiel ao protótipo do Figma (EPIC-07, 5 story points). A Home precisa ter card de humor, mascote, acesso ao diário, FAQ e botão CVV visível. Compilação sem warnings críticos no `flutter analyze`, teste no emulador Android API 24+ e commits em Conventional Commits. A fidelidade ao protótipo deve ser de 100%.
  * **Como a IA ajudou:** Leu o frame do Figma (medidas, cores, tipografia e ilustrações), exportou as ilustrações em SVG e montou o layout em Flutter com `Row`, `Column` e `Stack`. O `flutter_svg` ignora filtros de SVG, então a IA refez em Dart o brilho dos humores (silhueta desfocada na cor de cada humor). Também apontou que as cores do Figma diferem da paleta Tailwind v3 do projeto (por exemplo `sky500` é `#00A6F4` no Figma e `#0EA5E9` em `TailwindColors`) e criou `app_colors.dart` com os valores do protótipo.
  * **Dificuldades e ajustes manuais:** O Figma exporta o SVG com o fundo do frame, que foi removido à mão dos arquivos em `assets/home/`. O botão CVV ficou fora da posição até o `SingleChildScrollView` ser envolvido em `Positioned.fill`. Não havia emulador Android configurado nesta máquina: a conferência visual foi feita por captura de teste e a execução em API 24+ continua pendente. O card "Chat Anônimo" aponta para a denúncia anônima (decisão do usuário) e os destinos de diário, FAQ e denúncia mostram "Disponível em breve" até as etapas 2, 4 e 5.

### Rayelen de Jesus Oliveira

* **Fluxograma de navegação (SCRUM-23) e preenchimento da documentação (03/11):**
  * **O que foi feito:** Mapeamento do fluxo de navegação do aplicativo em quatro fluxogramas no FigJam (entrada e autenticação; aluno: humor, diário e CVV; aluno: canais, FAQ e denúncia; psicóloga e responsável), com rotas nomeadas, transições e estados vazio/erro. A IA foi usada para fazer todos os preenchimentos da documentação desta etapa: a entrada do `CHANGELOG.md`, o texto de responsabilidade no `README.md`, este registro de uso de IA e a explicação do fluxograma.
  * **Ferramenta utilizada:** Claude (Claude Sonnet 5.5), com os conectores do Jira, do GitHub (leitura) e do Figma (FigJam).
  * **Prompts utilizados:**
    * > Verifique o ticket do Jira SCRUM-23 e o GitHub do projeto e avalie como deve ser feito esse fluxograma. Não faça nada, apenas responda.
    * **Changelog.**  *"Atue como analista de documentação do projeto MenteLeve. Com base em tudo o que foi executado nesta tarefa (SCRUM-23), redija a entrada do `CHANGELOG.md` no padrão do repositório, apenas com o que de fato foi feito, sinalizando como 'a validar' o que for inferência e listando os itens pendentes. Não altere nenhum arquivo do repositório."*
  * **Como a IA ajudou:** Leu o ticket e a documentação do repositório (escopo, requisitos, casos de uso, justificativas, modelagem do Firestore e protótipo de alta fidelidade), escolheu o fluxograma de processo como tipo de diagrama por ser o que o ticket pede, propôs a divisão em quatro fluxos por perfil e assunto e redigiu os textos de changelog, README e este registro.

---

## Sprint 2

### Alexandre Pedro de Matos Ferreira

* **Desenvolvimento do Diário de Sentimentos por Emojis (RF01 / SCRUM-28 — 08/11):**
  * **O que foi feito:** Implementação do módulo do Diário de Sentimentos (`lib/modules/student/diary/`), incluindo modelos (`Humor`, `RegistroDiario`), repositório local (`LocalDiaryRepository`), controlador (`DiaryController`), widgets de apoio (`MoodSelectorCard`, `EmojiButton`, `RecentMoodsSummary`), a tela principal `DiaryFeelingsView` fiel ao protótipo do Figma (disco radial interativo de 12 setores, expressões faciais em `CustomPainter`, ponteiro em gota e indicador duplo chevron) e suíte de testes automatizados (`test/modules/student/diary/`).
  * **Ferramenta utilizada:** Antigravity (Gemini 3.8 Flash).
  * **Prompts utilizados:**
    * > `https://menteleve.atlassian.net/jira/software/projects/SCRUM/boards/1?filter=&groupBy=none&selectedIssue=SCRUM-28` `/boost comece a trabalhar nessa tarefa.`
    * > Especificações CSS do Figma e imagem de referência da tela `diary-feelings`, seguido de: `dê um jeito de emular a tela, e qualquer arquivo q for criar, use a pasta /.agents`
  * **Como a IA ajudou:** Estruturou a arquitetura em camadas (model, repository, controller e views/widgets), implementou a geometria trigonométrica da roda de sentimentos com `CustomPainter` e rotação interativa (`GestureDetector` + `AnimationController`), escreveu os testes unitários e de widgets e montou um script de renderização headless (`.agents/render_screens_real.dart`) carregando as fontes Poppins e ícones Lucide para validar o visual em PNG sem precisar de emulador Android.
  * **Dificuldades e ajustes manuais:**
    1. **Emulação visual sem Android AVD:** Como não havia emulador Android configurado na máquina e o `flutter test` substitui fontes por blocos retangulares por padrão, foi necessário baixar os arquivos TTF da fonte Poppins na pasta ignorada `.agents/` e carregá-los via `FontLoader` junto ao `AssetManifest` para gerar as capturas reais da tela.
    2. **Ajustes visuais em relação ao protótipo do Figma:** Na primeira captura gerada pela IA, o título `"Como você está se sentindo hoje?"` cortava a palavra `"hoje?"`, o ponteiro apresentava uma deformação na ponta e havia um botão `"Salvar Neutro"` no centro vazado da roda que não existia no Figma. Após envio da imagem de referência, a caixa do título foi redimensionada, o `NeedlePainter` foi refeito com tangentes circulares contínuas e o botão sobreposto foi ocultado, mantendo o registro pelo toque no rosto central ou no ponteiro.

* **Revisão Técnica do PR #9 (08/11) e Resolução de Conflitos do PR #12 (15/11):**
  * **O que foi feito:** Revisão técnica do Pull Request #9 (integração com Firebase Auth/Firestore e autenticação por perfil) e resolução dos conflitos da branch `feat/SCRUM-28/diario-sentimentos-emojis` (PR #12) com a `main`.
  * **Ferramenta utilizada:** Antigravity (Gemini 3.8 Flash e Gemini 4 Argon).
  * **Prompts utilizados:**
    * > `atue como um especialista em codigo para revisar o pull request: https://github.com/maarcos4g/mente-leve/pull/9`
    * > `verifique o pull request que você fez sobre essa ultima tarefa e verifique os possíveis conflitos com a main para o merge. Corrija-os e atualize o changelog e o arquivo de uso de ia.`
  * **Como a IA ajudou:** Na revisão do PR #9, apontou o risco de logout forçado de usuários institucionais quando sem internet no `restoreSession()`, a falta de `WidgetsFlutterBinding.ensureInitialized()` no `main()` e a ausência do estado `isLoading` nas telas de login de pais e psicólogos. Na atualização do PR #12, identificou o conflito em `lib/app_widget.dart` e a duplicidade da Home do aluno após o merge da Home oficial na `main`, mantendo a `HomeView` da `main` e conectando a rota `HomeController.diaryRoute` (`/diary`) à `DiaryFeelingsView`.
  * **Dificuldades e ajustes manuais:** Durante os testes locais na Web (Chrome), a autenticação anônima do Firebase falhava por ausência de `FirebaseOptions` web registrado no console, sendo necessário reverter alterações temporárias no `lib/main.dart` antes do envio do PR para não impactar a inicialização nativa do Android.

* **Revisão do PR #13 (CI/CD), Planejamento das Sprints 3 e 4 no Jira e Correção da Roleta (18/11):**
  * **O que foi feito:** Revisão técnica do PR #13 (pipeline CI/CD com GitHub Actions e Firebase App Distribution), criação das tarefas `SCRUM-50` (proteção por senha no ícone de cadeado do diário) e `SCRUM-51` (seção de perfil do usuário e opção de logout) com balanceamento das Sprints 3 e 4 no Jira, e correção do bug da roleta em `DiaryFeelingsView` (restauração do emoji central e rotação livre em qualquer posição do dedo).
  * **Ferramenta utilizada:** Antigravity (Gemini 4 Argon).
  * **Prompts utilizados:**
    * > `agora preciso que revise esse pull request, avaliando todas as alterações e buscando possíveis falhas: https://github.com/maarcos4g/mente-leve/pull/13`
    * > `Conecte-se ao Jira e trabalhe nas 2 sprints restantes, atribuindo a cada membro uma tarefa e mantendo equilibrado a quantidade de tarefas. Caso uma tarefa dependa da outra ou seja co-relacionada, dê prioridade pro mesmo membro ser atribuido em ambas. As tarefas mais complexas dê prioridade pro membro Marcos. Além disso você precisa criar 2 novas tarefas: - função de adicionar senha na tela do diario (ja existe um icone de cadeado, porém não funciona) - adicionar na tela de login uma opção para deslogar da conta, de preferência uma sessão no perfil do usuário. Também deve corrigir o bug da roleta que atualmente ta com o icone errado (a branch de abrãao reescreveu por cima da minha) e também deveria ser possível rodar a roleta independente da posição do dedo, atualmente é so perto do ponto indicador.`
  * **Como a IA ajudou:** Na revisão do PR #13, identificou que o uso do `debug.keystore` efêmero no runner causaria erro de conflito de assinatura (`INSTALL_FAILED_UPDATE_INCOMPATIBLE`) ao atualizar o APK nos celulares, além do `versionCode` estático e da falta de execução do `flutter analyze`/`flutter test` na pipeline. No Jira, utilizou a API REST para criar as duas novas tarefas e distribuir exatamente 3 tarefas abertas por integrante nas Sprints 3 e 4 conforme co-relação e complexidade. Na roleta (`DiaryFeelingsView`), diagnosticou que os 57px superiores do arco ficavam em coordenadas negativas (`localY < 0`) fora da área de hit-test do `GestureDetector` e que o `SingleChildScrollView` com `BouncingScrollPhysics` roubava arrastos com componente vertical nas laterais da roda.
  * **Dificuldades e ajustes manuais:** Para corrigir a captura de toque no topo da roleta sem deslocar os elementos na tela, o `Positioned` do disco foi movido de `top: 623` para `top: 540` compensando `+83px` no centro interno (`center.dy` de `320` para `403`) e no ponteiro (`top` de `56` para `139`), mantendo a posição visual no mesmo pixel (`screenY = 943`) com 100% do arco visível dentro da caixa de gestos.

### Abraão Luiz Ribeiro da Cruz Dantas

* **Diário Reflexivo e Checklist de Pontos Positivos — RF02 (09/11):**
  * **O que foi feito:** Criação da tela `DiaryReflectionView` (escolha de humor, escrita livre e checklist de pontos positivos com sugestões e itens personalizados), do `DiaryReflectionController` e do `PrefsDiaryRepository`, que salva o diário no aparelho com `shared_preferences`. O card "Diário Pessoal" da Home passou a abrir a nova tela. Também foram criados os testes do controller, da tela e do repositório. Depois, a tela foi refeita seguindo as telas "personal diary" e "personal diary / add" do Figma (semana atual, botão "Anotar no Diário", lista de registros recentes com exclusão ao arrastar e folha de escrita com "Registrar"), com o checklist em chips vindo do protótipo de baixa fidelidade "diario-reflexivo".
  * **Ferramenta utilizada:** Claude Code (Claude Opus 5.5).
  * **Prompt utilizado:**
    > **Atue como** um desenvolvedor Flutter sênior.
    >
    > **Tarefa:** implementar o RF02 (Diário Reflexivo e Checklist de Pontos Positivos) no módulo do aluno, seguindo a modelagem em `docs/modelagem/`.
    >
    > **Requisitos:**
    > 1. Área de escrita livre e checklist de pontos positivos do dia, com sugestões prontas e a opção de o aluno adicionar os seus.
    > 2. A reflexão deve completar o registro de humor do dia (RF01), sem criar um registro duplicado.
    > 3. Salvar o diário somente no aparelho, funcionando offline e com os dados criptografados (RNF02, RNF03, RN02).
    > 4. Seguir o padrão de pastas e de controllers do projeto e criar testes para a nova funcionalidade.
    >
    > **Ajuste de layout:** olhe no Figma do projeto (conector do Figma no Claude Code) e deixe a tela o mais parecida possível com o design.
  * **Como a IA ajudou:** Estruturou a regra de completar o registro de humor do dia em vez de duplicá-lo, criou o repositório local do diário e escreveu os testes. Também leu as medidas, cores e fontes direto do Figma e reaproveitou componentes já existentes no projeto (ícones Lucide e o rostinho de emoção do RF01).
  * **Dificuldades e ajustes manuais:**
    1. **Repositório nos testes:** Foi criado o `DiaryController.defaultRepository`, para que o app use o `shared_preferences` e os testes continuem usando o repositório em memória.
    2. **Arquivo do Firebase:** O `android/app/google-services.json` não estava no `.gitignore` e precisou ser deixado de fora do commit manualmente.
    3. **Checklist fora do protótipo final:** O Figma final não tinha o checklist de pontos positivos exigido pela task; ele foi encaixado na folha de escrita usando os chips do protótipo de baixa fidelidade.
    4. **Bug encontrado pelos testes:** O diálogo de "Novo ponto positivo" descartava o campo de texto antes de terminar a animação de fechamento, o que quebrava o app. O diálogo virou um widget com estado próprio.
    5. **Ambiente:** O `flutter analyze` e o build Android falhavam com o "ç/ã" no nome da pasta (`Programação`), que foi renomeada para `Programacao`. O emulador Android 37 reiniciava sozinho por um bug gráfico com a GPU Intel, então o teste manual foi feito na versão web.

* **Ajustes da revisão do PR #11: shared_preferences e conflitos com a `main` (11/11):**
  * **O que foi feito:** O diário deixou de usar Hive CE e `flutter_secure_storage` e passou a usar o `shared_preferences`, que já estava no projeto: foi criado o `PrefsDiaryRepository`, que guarda os registros na chave `diario`, e os três pacotes saíram do `pubspec.yaml`. A branch recebeu o merge da `main` (Firebase e Home do aluno), com 11 arquivos em conflito resolvidos, e a `StudentHomeView` duplicada foi removida. Os docs de modelagem e o escopo foram atualizados, e a base do PR #11 mudou para a `main`.
  * **Ferramenta utilizada:** Claude Code (Claude Opus 5.5).
  * **Prompts utilizados:**
    > 1. "Analise as duas imagens e me diga o que precisa atualizar" (prints dos comentários do grupo no PR: usar o `shared_preferences` e resolver os conflitos).
    > 2. "Mantenha a Home da main e execute as outras tarefas."
    > 3. "Atualize os docs que dizem Hive e depois faça um push e abra PR."
  * **Como a IA ajudou:** Simulou o merge para listar os conflitos antes de mexer na branch, achou um conflito que o Git não acusava (duas classes `StudentHomeView`), reescreveu o repositório e o teste dele, ligou as rotas do diário à Home da `main` (`/diary` para sentimentos e `/diary/reflection` para a reflexão), rodou `flutter analyze` e `flutter test` (76 testes passando) e atualizou a descrição do PR.
  * **Dificuldades e ajustes manuais:**
    1. **Criptografia:** Com o `shared_preferences`, o diário continua só no aparelho, mas sem criptografia, o que precisa ser alinhado com o RNF03.
    2. **Base do PR:** Mesmo depois do merge, o GitHub mostrava conflito porque o PR #11 tinha sido aberto em cima da branch do PR #12 (SCRUM-28). A base foi trocada para a `main`, e o #12 ficou redundante.
    3. **OneDrive:** O `flutter test` falhou na primeira vez porque o OneDrive travou a pasta `build/`; foi preciso apagá-la e rodar de novo.


### Marcos Paulo

* **Arquitetura do perfil de usuário e autenticação com Firebase (SCRUM-25 / SCRUM-27) (06/11 a 08/11):**
  * **O que foi feito:** Definição de como modelar o perfil dos três papéis (aluno anônimo, psicóloga e responsável) e correção dos erros que apareceram ao integrar o Firebase Auth e o Firestore: `UserModel`, `LocalUserModel`, `SessionModel` selado, `AuthRepository`, `ProfileStore` e o bootstrap em `main.dart`. A IA também escreveu as regras de segurança do Firestore (controle de acesso por papel, lendo `users/{uid}`), já traduzidas para o inglês, revisou o `.gitignore` antes do commit (inclusão de `GoogleService-Info.plist`, `firebase_options.dart` e `.firebaserc`) e redigiu o título e a descrição do PR #9.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompt utilizado:**
    > **Atue como** um engenheiro de software sênior, especialista em Flutter e Firebase.
    >
    > **Tarefa:** definir a arquitetura do perfil de usuário e da autenticação do app e corrigir os erros da integração com Firebase Auth e Firestore.
    >
    > **Contexto:** leia `docs/` e `lib/` antes de responder. O estado é gerenciado com Provider e os dados offline ficam no `shared_preferences`.
    >
    > **Requisitos:**
    > 1. O aluno não tem login: entra com Auth anônima, identificado pelo `uid`, e guarda codinome e avatar só no aparelho.
    > 2. Psicóloga e responsável entram com e-mail e senha, previamente cadastrados, e o papel vem do documento `users/{uid}`.
    > 3. `UserModel`, sessão selada e `AuthRepository` seguindo esse modelo.
    > 4. Regras de segurança do Firestore por papel, em inglês e coerentes com os nomes usados no código.
    > 5. Diagnosticar os erros apresentados (tela branca, volta ao onboarding e falha ao sair da conta) e tratar login offline, loading e duplo envio.
    > 6. Entregar primeiro o plano e o código; só alterar arquivos quando eu pedir.
  * **Como a IA ajudou:** Leu `docs/modelagem/` e o código de `lib/` e apontou que a modelagem previa a coleção `usuarios`, enquanto o código usava `users`. Também achou a causa da tela branca (condição do `FutureBuilder` invertida em `main.dart`), do app que voltava ao onboarding depois do login (`jsonEncode` no lugar de `jsonDecode` em `ProfileStore`) e do erro ao sair da conta (`context.read()<AuthNotifier>()`, com o parêntese fora do lugar). Na última etapa, aplicou as quatro correções do review: o `signOut` passa a acontecer só quando o erro não é de conectividade, o binding é inicializado no `main()`, o `isLoading` chega às telas de psicóloga e responsável (com guarda contra duplo toque) e o método `emailFormIdentification` foi renomeado para `emailFromIdentification`. O `flutter analyze` não acusou problemas.
  * **Dificuldades e ajustes manuais:**
    1. **Divergência entre docs e código:** a modelagem usa Hive e `usuarios`/`papel`, mas o grupo decidiu por `shared_preferences` e por `users`/`role` em inglês. A decisão foi do integrante, e as regras foram reescritas para bater com o código.
    2. **Sem alteração automática:** na maior parte da conversa a IA só propôs código, e o integrante aplicou as mudanças à mão. Só no ajuste final a IA editou os arquivos.
    3. **Validação:** nada foi testado em aparelho nem contra as regras publicadas no Firebase. O teste de login offline ficou como roteiro manual para o integrante.
    4. **E-mail do responsável:** o domínio `@parents.menteleve.app` precisou ser conferido no console do Firebase, onde o usuário de teste é cadastrado.

* **Pipeline de CI/CD com GitHub Actions e Firebase App Distribution (10/11):**
  * **O que foi feito:** Criação do workflow `.github/workflows/ci_cd.yml`, que compila o APK Android e envia ao Firebase App Distribution a cada push na `main`, com as credenciais em Secrets do GitHub. A IA também escreveu a descrição do PR #13.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompt utilizado:**
    > **Atue como** um engenheiro DevOps com experiência em Flutter, GitHub Actions e Firebase App Distribution.
    >
    > **Tarefa:** criar `.github/workflows/ci_cd.yml` para compilar o APK Android e distribuí-lo no Firebase App Distribution.
    >
    > **Requisitos:**
    > 1. Gatilho em push na `main` e disparo manual.
    > 2. Java 17, Flutter SDK e `flutter build apk --release`.
    > 3. Credenciais apenas em Secrets do GitHub (`google-services.json`, conta de serviço, ID do app e grupos de testadores), sem expor nada no código.
    > 4. Envio do APK pela action oficial do Firebase App Distribution.
    > 5. Explicar passo a passo como gerar cada secret.
  * **Como a IA ajudou:** Montou o workflow (Java 17, Flutter, `google-services.json` recriado a partir de Secret, upload pela action oficial) e explicou como gerar a conta de serviço e os grupos de testadores. Diagnosticou que três secrets estavam no *environment* `default` e o job não declarava `environment:`, o que deixava o `GOOGLE_SERVICES_JSON` vazio. Também explicou que o build de iOS exigiria um runner macOS.
  * **Dificuldades e ajustes manuais:**
    1. **Chave exposta:** a chave privada da conta de serviço apareceu na conversa porque o arquivo estava selecionado no editor. A IA orientou a tratá-la como comprometida e a revogá-la.
    2. **Secrets:** o nome do secret foi recusado pelo GitHub por conter caracteres inválidos, e parte dos secrets estava no lugar errado (*environment* em vez do repositório). Ambos foram corrigidos pelo integrante.
    3. **Validação:** a IA não consegue rodar o GitHub Actions, então a pipeline só é confirmada rodando no repositório depois do push.
    4. **iOS:** o build de iOS não foi incluído, por estar fora do escopo da tarefa.

* **Revisão de Pull Requests da equipe (10/11 a 14/11):**
  * **O que foi feito:** Apoio na revisão técnica de PRs dos demais integrantes, comparando cada branch com a `main`: Home do aluno e Firebase (#10), CVV 188 (#15) e gatilho de apoio emergencial (#14). A IA devolveu a funcionalidade, os pontos positivos, os pontos de melhoria e um saldo de cada PR. O integrante usou esse parecer para decidir entre aprovar ou pedir ajustes no GitHub.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompt utilizado:**
    > **Atue como** um revisor de código sênior de projetos Flutter.
    >
    > **Tarefa:** revisar o PR #N comparando a branch com a `main`.
    >
    > **Requisitos:**
    > 1. Descrever a funcionalidade que o PR insere.
    > 2. Considerar apenas o código alterado neste PR, sem apontar pontos de PRs já mergeados.
    > 3. Rodar `flutter analyze` e `flutter test`.
    > 4. Listar os pontos positivos da implementação.
    > 5. Listar os pontos de melhoria e de atenção (bugs, riscos e aderência à modelagem em `docs/` e aos requisitos).
    > 6. Fechar com o saldo: se o PR está aprovável e o que o impede, incluindo conflitos e como resolvê-los.
    > 7. Não alterar nenhum arquivo nesta etapa.
  * **Como a IA ajudou:** Levantou o diff contra a `main` e rodou `flutter analyze` e `flutter test`. Apontou que o login institucional podia reabrir o aluno em silêncio depois de sair da conta (na revisão da Home e do Firebase) e que, no PR #14, o gatilho ainda não era chamado por nenhuma tela. Também separou, a pedido, o que era do PR do que já vinha de PRs mergeados.
  * **Dificuldades e ajustes manuais:**
    1. **Escopo da revisão:** a primeira revisão de 14/11 misturou pontos que pertenciam a PRs já mergeados. Foi preciso perguntar o que era de fato do PR e, nas revisões seguintes, restringir o pedido ao código alterado.
    2. **Revisão sem execução:** a IA não abriu o app em aparelho. O que ela diz sobre comportamento vem da leitura do código e dos testes.
    3. **Decisão de aprovar:** o resultado da IA é um parecer. Quem decidiu entre aprovar ou pedir ajustes (como no PR #15) foi o integrante, no GitHub.

### Mateus Henrique de Araújo Santos

*(A preencher pelo integrante)*

### Rayelen de Jesus Oliveira

* **Documentação do gatilho de apoio emergencial (SCRUM-31) (10/11 a 12/11):**
  * **O que foi feito:** A IA preencheu toda a documentação ligada ao ticket: o caso de uso UC20 e a regra RN11, a entidade local do estado do gatilho nos documentos de classes e de mapeamento, a nota de que o gatilho não usa o Firestore, a entrada do `CHANGELOG.md` e este registro. Também foi usada para escrever o prompt de desenvolvimento do ticket e os comentários de andamento no Jira.
  * **Ferramenta utilizada:** Claude (Claude Sonnet 5.5) e o agente que executou o desenvolvimento.
  * **Prompts utilizados:**
    * > Parta da `origin/main` atualizada (`git fetch`; o histórico remoto já foi reescrito uma vez). Se algo abaixo contradizer o que você encontrar, siga a documentação e me avise.

    * > Ao terminar, me entregue Um resumo curto do que foi feito e dos arquivos alterados. O resultado de `flutter analyze` e `flutter test`, e se o emulador foi usado. Dependências e lacunas encontradas (diário e registro de humor ausentes, Hive versus `shared_preferences`, 5 assets versus 6 humores). Decisões tomadas por falta de definição na documentação, que o grupo precisa validar.

  * **Dificuldades e ajustes manuais:**
    1. **Leitura desatualizada do repositório:** a primeira versão do prompt descrevia o humor como uma escala de 5 níveis. Ao atualizar o repositório, viu-se que a modelagem define 6 categorias sem ordem (`Humor`) e que a pasta `docs/` havia sido reorganizada. O prompt foi corrigido.
    2. **Divergência de armazenamento:** a modelagem prevê Hive criptografado, mas o código usa `SharedPreferences` sem criptografia. A decisão ficou registrada como pendente para o grupo.
    3. **Validação clínica:** o texto do modal e os limites do gatilho precisam ser revisados pela psicóloga da escola.

### 2. Integração via MCP do Jira
- Conexão do assistente de IA ao Jira Cloud por meio do servidor MCP (*Model Context Protocol*) da Atlassian, permitindo que a IA consulte e manipule o backlog diretamente, sem a necessidade de scripts intermediários.
- Consulta de épicos, stories e tasks do projeto SCRUM via JQL para apoiar revisões de escopo e acompanhamento das sprints.
- Criação e atualização de issues (descrições, critérios de aceite, status e vínculos com épicos) a partir de comandos em linguagem natural.
- Autenticação feita via OAuth com a conta Atlassian do time, respeitando as permissões já configuradas no projeto.


---


## Sprint 3

### Alexandre Pedro de Matos Ferreira

* **Desenvolvimento do FAQ Empático Dinâmico (RF04 / SCRUM-33), Painel de Publicação do FAQ da Psicóloga (RF08 / SCRUM-36) e Auditoria WCAG AA / Testes (SCRUM-41 / SCRUM-44 — 18/11):**
  * **O que foi feito:** Implementação da entidade `PerguntaFaq` (`lib/shared/models/pergunta_faq.dart`), dos repositórios `FirestoreFaqRepository` e `LocalFaqRepository` com cache offline em `SharedPreferences` (`lib/shared/faq/faq_repository.dart`), do card expansível compartilhado `FaqExpandableCard` (`lib/shared/widgets/faq/faq_expandable_card.dart`), da tela de Canais de Apoio & FAQ do estudante (`StudentFaqView` e `StudentFaqController` na rota `/faq`), do painel administrativo de CRUD de perguntas frequentes da psicóloga (`PsychologistFaqView` e `PsychologistFaqController` na rota `/psychologist/faq`) e da suíte de testes unitários, de widgets e de acessibilidade WCAG AA (`test/shared/faq/`, `test/modules/student/faq/`, `test/modules/psychologist/faq/` e `test/accessibility_wcag_test.dart`).
  * **Ferramenta utilizada:** Antigravity (Gemini 4 Argon).
  * **Prompt utilizado:**
    > `/goal Perfeito, pegue as tarefas que estão atribuidas a mim, Alexandre, e comece a produção delas em uma nova branch.`
  * **Como a IA ajudou:** Consultou a API do Jira para levantar os critérios de aceite das tarefas `SCRUM-33`, `SCRUM-36`, `SCRUM-41` e `SCRUM-44`, seguiu o modelo `PerguntaFaq` especificado em `docs/modelagem/04-mapeamento-dart-firestore.md` e o layout das telas `Canais de Apoio & FAQ` e `FAQ (Psicóloga)` em `docs/prototipos/prototipoAltaFidelidade.pdf`, implementou o cache offline com `SharedPreferences` e escreveu testes de contraste relativo WCAG 2.1 ($\ge 4,5:1$) e áreas de toque mínimas ($\ge 48\times 48\text{dp}$).
  * **Dificuldades e ajustes manuais:**
    1. **Rolagem automática ao editar pergunta no painel da psicóloga:** No teste de edição (`PsychologistFaqView`), ao tocar no botão de editar um card no final da lista, o botão de submissão `"Atualizar"` ficava fora da área visível do `SingleChildScrollView`. Foi adicionado um `ScrollController` que rola suavemente para o formulário no topo ao iniciar a edição de um item.
    2. **Espaço em disco durante execução paralela de testes:** O comando `flutter test` padrão falhou inicialmente com `errno = 112` (espaço insuficiente no disco `C:`) devido ao acúmulo de artefatos temporários em `build/` e `%TEMP%\flutter_tools.*`. Foi feita a limpeza dos diretórios temporários de build e a execução controlada com `--concurrency=2`.

* **Ajustes de Revisão do PR #18 — FAQ em Inglês no Firestore, Swipe-Left, Cores Figma e Perfil do Psicólogo (20/11):**
  * **O que foi feito:** Aplicados os 6 ajustes solicitados na revisão do PR #18: remoção do nome mockado na `PsychologistHomeView` (passando a exibir o nome e a foto de perfil `photoUrl` carregados do documento do usuário no Firestore via `UserModel` + `AuthNotifier`), redimensionamento do card `"Editar Perguntas Frequentes (FAQ)"` na Home do psicólogo para as medidas exatas do Figma (`152×142`), restrição dos botões de editar e excluir em `PsychologistFaqView` para aparecerem apenas ao arrastar o card para a esquerda, correção das cores dos cards de `"Canais de Apoio"` e do FAQ expandido em `StudentFaqView`/`FaqExpandableCard` conforme os hexadecimais exatos extraídos de `docs/prototipos/prototipoAltaFidelidade.pdf`, e migração da modelagem e campos da coleção `faq` no Firestore para nomenclatura em inglês (`FaqModel`: `question`, `answer`, `createdAt`, `updatedAt`, `updatedBy`).
  * **Ferramenta utilizada:** Antigravity (Gemini 4 Argon).
  * **Prompt utilizado:**
    > `Fluxo bem estruturado! Solicito pequenos ajustes: Na home do psicólogo, o nome ainda está mockado... Os botões de editar e excluir são mostrados APENAS quando o card da pergunta é arrastado para o lado esquerdo... As cores dos cards de "Canais de Apoio" estão diferentes do que foi proposto no figma... O card de "Editar perguntas frequentes" na home é um pouco menor no figma... Mostrar a foto do psicólogo na app bar... Atualizar os nomes dos termos/variáveis na tabela de FAQ no banco firestore para usar a nomenclatura em inglês.`
  * **Como a IA ajudou:** Inspecionou diretamente os fluxos vetoriais do PDF do protótipo de alta fidelidade para extrair os hexadecimais e dimensões exatas do Figma (`#FFE2E2`/`#FB2C36`, `#DFF2FE`/`#00A6F4`, `#F4F4F5`/`#D4D4D8`, `152×142`), refatorou `PerguntaFaq` para `FaqModel` com chaves em inglês mantendo compatibilidade no repositório/cache e atualizou os testes de widgets, repositório e contraste WCAG AA.
  * **Dificuldades e ajustes manuais:**
    1. **Overflow no card compacto da Home do psicólogo:** Ao reduzir o card de ação para `152×142` (conforme o Figma), o teste de widget acusou `RenderFlex overflowed by 10.0 pixels on the bottom`; o espaçamento interno e o rótulo foram ajustados com `Flexible` mantendo a dimensão fiel ao protótipo.
    2. **Erro de coeficiente na fórmula de luminância do teste WCAG:** O teste `test/accessibility_wcag_test.dart` continha `0.722 * b` em vez de `0.0722 * b` no cálculo de luminância relativa, distorcendo o contraste de tons azuis (`sky700`); o coeficiente foi corrigido para o padrão oficial WCAG 2.1.

### Abraão Luiz Ribeiro da Cruz Dantas

* **Persistência Offline e Cache Local do diário — EPIC-03 (21/11):**
  * **O que foi feito:**
    * O diário já gravava no `SharedPreferences`, mas o aluno só entrava no app com internet, porque o login anônimo do Firebase falha sem rede.
    * Agora, sem rede, o aluno entra com uma sessão local (id `local-<hex>` guardado pelo `ProfileStore`), e o login anônimo é refeito quando a internet volta.
    * O `PrefsDiaryRepository` passou a ignorar registros inválidos e a guardar um backup (`diario_corrompido`) se a chave inteira estiver ilegível.
    * O onboarding passou a rolar em telas baixas.
    * Foram criados os testes do `AuthRepository` com Firebase simulado, da leitura tolerante do diário e do onboarding.
    * O app foi homologado num emulador Android 7.0 (API 24) em modo avião.
  * **Ferramenta utilizada:** Claude Code (Claude Opus 5.5).
  * **Prompts utilizados:**
    > 1. A descrição da task colada ("Configuração de Persistência Offline e Cache Local (Hive / SharedPreferences)", EPIC-03, 5 SP; DoD: escrita e leitura do diário de sentimentos sem conectividade; homologação: analyzer limpo, emulador Android API 24+ e commits em Conventional Commits). "Seguiremos agora com essa task."
    > 2. Nas perguntas da IA: incluir a entrada do aluno sem internet e "baixe um API 24, mas no disco D:".
  * **Como a IA ajudou:**
    * Viu que a persistência do diário já existia e que a lacuna real era o login anônimo, que bloqueava o uso offline.
    * Testou o `AuthRepository` sem pacote novo, com fakes do Firebase.
    * Criou o emulador API 24 no disco D: e conduziu o teste completo em modo avião. O roteiro foi: dados apagados, entrar, registrar o humor, escrever no diário, fechar e reabrir offline, depois ligar a rede. A IA conferiu os dados gravados direto no `SharedPreferences` do aparelho.
    * Fez um commit por assunto, em Conventional Commits.
  * **Dificuldades e ajustes manuais:**
    1. **Onboarding no Android 7:** No emulador API 24 (731 dp de altura), o botão "Entrar como aluno" ficava fora da área de toque, porque o layout tem alturas fixas que somam cerca de 890 dp. O conteúdo passou a rolar, e um teste prova que antes falhava e agora passa.
    2. **Fonte de teste:** Nos testes de widget, a fonte padrão do Flutter desenha cada letra como um quadrado e estoura o botão na horizontal. Isso não acontece no aparelho, então o teste do onboarding descarta esse aviso e confere só a navegação.
    3. **Ping no Android 7:** O emulador API 24 não responde a `ping` mesmo com internet. A volta da rede foi confirmada pela fonte Poppins carregando e pela sessão do Firebase criada.
    4. **Commit pelo PowerShell:** Aspas dentro da mensagem quebravam o `git commit -m` no PowerShell 5.1; a mensagem passou a ir por arquivo (`git commit -F`).
* **Proteção por PIN no Diário Pessoal (19/11 a 21/11):**
  * **O que foi feito:** O cadeado (`LucideIcons.lockKeyhole`) que já existia na App Bar do `DiaryReflectionView` passou a abrir um fluxo para criar, alterar ou remover um PIN de 4 números. Com o PIN ativo, a tela pede o PIN antes de mostrar os registros. Foram criados o `DiaryLockRepository` / `PrefsDiaryLockRepository` (PIN salvo no `SharedPreferences`, chave `diario_pin`, como hash SHA-256 com salt) e o `DiaryLockController`, além dos testes do repositório, do controller e da tela. Depois, a branch recebeu o merge da `main` (FAQ da Sprint 3) e o app foi testado no emulador Android.
  * **Ferramenta utilizada:** Claude Code (Claude Opus 5.5).
  * **Prompts utilizados:**
    > 1. "Implementar proteção por senha no Diário Pessoal (Ícone de Cadeado)", com a descrição e os critérios de aceite da task colados: abrir o fluxo de cadastrar, alterar ou remover a senha/PIN ao tocar no cadeado; persistir a senha localmente com `SharedPreferences`, 100% offline; pedir a senha ao abrir o Diário Pessoal quando a proteção estiver ativa. "Faça o que foi pedido nessa task."
    > 2. "Verifique o projeto e abra o android para eu testar a última task que fiz."
    > 3. "Por que não consigo entrar no app?"
    > 4. "Pronto, suba no GitHub. Não esqueça de alterar no docs as minhas atualizações."
  * **Como a IA ajudou:** Propôs guardar só o hash do PIN com salt, em vez do PIN digitado, e tratar PIN corrompido como "sem PIN" para o aluno não ficar trancado fora do diário. Escreveu os testes (162 passando na branch e 181 depois do merge com a `main`, `flutter analyze` sem avisos), abriu o app no emulador, descobriu por que o login do aluno falhava e resolveu o conflito do merge com a `main` em `main.dart`.
  * **Dificuldades e ajustes manuais:**
    1. **Pasta do projeto vazia no OneDrive:** A cópia em `OneDrive\Documentos\...\mente-leve` só tinha pastas vazias e um `.git` quebrado. O trabalho foi feito na cópia de `Documents\...\mente-leve`.
    2. **SDK do Flutter corrompido pelo OneDrive:** O build Android falhava com `Cannot snapshot ... AgpCommonExtensionWrapper.kt: not a regular file`. O SDK veio de uma cópia do OneDrive e tinha cerca de 16,8 mil arquivos que ainda eram atalhos de nuvem. Os 58 arquivos de `packages/flutter_tools/gradle` foram regravados como arquivos normais, com o mesmo conteúdo. O ideal é reinstalar o Flutter fora do OneDrive.
    3. **Arquivo duplicado no Android:** Uma cópia solta, `GeneratedPluginRegistrant - Copy.java`, foi tirada do projeto para não quebrar o build.
    4. **Emulador sem internet:** O emulador travou no primeiro boot e, depois de reiniciado, ficou sem rede. O "Entrar como aluno" mostrava "Sem conexão com a internet", porque o login anônimo do Firebase precisa de rede. Foi resolvido desligando e ligando de novo o Wi-Fi e os dados do emulador.
    5. **Sem recuperação de PIN:** A task não pedia recuperação. Quem esquecer o PIN não consegue mais abrir o diário, o que precisa ser alinhado com o grupo.

* **Bateria de Testes de Falha de Conexão (modo avião / offline) — EPIC-09 (21/11):**
  * **O que foi feito:**
    * Foi mapeado o que cada recurso faz sem internet: o diário é só local, o CVV só abre o discador e o FAQ usa o Firestore com cache.
    * Foi encontrado e corrigido um defeito: sem rede, salvar ou excluir uma pergunta no painel da psicóloga deixava a tela em "Salvando…" até a internet voltar, porque o `FirestoreFaqRepository` esperava a confirmação do servidor. Agora a espera tem limite e a escrita segue na fila offline do Firestore. Depois, a releitura da lista foi acelerada.
    * Foram criados 17 testes em `test/offline/`, com um Firestore simulado em que a escrita sem rede fica pendente até "reconectar".
    * O app foi homologado no emulador Android 7.0 (API 24): aluno em modo avião, e psicóloga criando e excluindo perguntas offline, conferidas no Firestore depois da reconexão.
    * Os resultados estão em `docs/testes/bateria-offline.md`.
  * **Ferramenta utilizada:** Claude Code (Claude Opus 5.5).
  * **Prompts utilizados:**
    > 1. A descrição da task colada ("Bateria de Testes de Falha de Conexão (Modo Avião / Offline)", EPIC-09, 3 SP; DoD: diário e botão CVV operam sem travar em modo offline e a reconexão sincroniza dados pendentes; homologação: analyzer limpo, emulador Android API 24+ e commits em Conventional Commits). "Segue a última task."
    > 2. Nas perguntas da IA: criar a branch em cima do PR #25 e o próprio Abraão digitar o login da psicóloga no emulador.
    > 3. "Crie uma conta de psicóloga" e "feche o Opera e abra em uma porta que você tenha acesso".
  * **Como a IA ajudou:**
    * Achou o ponto que travava (a espera pela confirmação do Firestore offline) e provou com teste: sem a correção, o salvar não terminava em 3 s; com ela, termina em ~2 s.
    * Escreveu os fakes do Firestore sem pacote novo.
    * No emulador, mediu o tempo de salvar (de 5 a 9 s antes da otimização, ~3 s depois) e conferiu a sincronização direto no console do Firestore, pelo Opera conectado via Playwright na porta 9222.
    * Limpou as perguntas de teste ao final.
  * **Dificuldades e ajustes manuais:**
    1. **Conta de psicóloga:** A conta Google do Abraão só tem leitura no projeto Firebase ("solicite a permissão necessária a um proprietário do projeto"), então não foi possível criar um usuário novo. O teste usou a conta de psicólogo do Marcos, e o Abraão digitou a senha no emulador.
    2. **Extensão do navegador:** A extensão Claude no Opera não respondia ("No group with id"). O Opera foi reaberto com `--remote-debugging-port=9222` e controlado via Playwright.
    3. **Classes "sealed" do Firestore:** O analyzer avisa ao implementar `Query` e `DocumentReference` num fake. O aviso foi silenciado só no arquivo do fake, como faz o pacote `fake_cloud_firestore`.
    4. **Observação fora do escopo:** O painel mostra 1 das 2 perguntas do servidor. Provavelmente o outro documento não tem `createdAt`, e a consulta ordenada por esse campo o deixa de fora. Ficou registrado para o grupo.

### Marcos Paulo

* **Evolução da pipeline de CI/CD: testes, assinatura e versionamento (16/11):**
  * **O que foi feito:** Evolução do `.github/workflows/ci_cd.yml` e do `android/app/build.gradle.kts`: `flutter analyze` e `flutter test` antes do build, cache do Gradle, assinatura do APK com keystore fixo restaurado de Secret e `versionCode` igual ao `run_number` do workflow.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompt utilizado:**
    > **Atue como** um engenheiro DevOps com experiência em Flutter, GitHub Actions e Firebase App Distribution.
    >
    > **Tarefa:** evoluir a pipeline de CI/CD existente para que cada build seja aceito como atualização nos celulares dos testadores.
    >
    > **Requisitos:**
    > 1. Assinatura com keystore fixo, restaurado a partir de um Secret (prioridade crítica).
    > 2. Versionamento com `--build-number=${{ github.run_number }}` (prioridade).
    > 3. `flutter analyze` e `flutter test` antes de gerar e enviar o APK.
    > 4. Cache do Gradle no `setup-java`.
    > 5. Explicar como gerar o keystore e cada secret de assinatura, considerando que o projeto é acadêmico (sem conta na Play Store) e que o terminal é o PowerShell do Windows.
    > 6. Corrigir falhas que apareçam na análise de código da pipeline.
  * **Como a IA ajudou:** Alterou o workflow e o Gradle, e explicou como gerar o keystore com `keytool` e convertê-lo em base64 para o Secret. Esclareceu que o `run_number` é preenchido pelo GitHub e pode pular números, e que isso não impede o Android de aceitar a atualização. No `flutter analyze`, a falha vinha de a pipeline usar um Flutter mais novo que o local, e a versão foi fixada em 3.44.0.
  * **Dificuldades e ajustes manuais:**
    1. **Terminal:** o comando do `keytool` usava `\` para quebrar linha (válido só no Bash) e falhou no PowerShell. A leitura do `release.jks` também falhou por caminho relativo, e foi preciso usar o caminho completo.
    2. **Keystore e secrets:** o `release.jks` fica fora do repositório e só entra na pipeline pelo Secret `ANDROID_KEYSTORE_BASE64`. Os secrets de assinatura foram cadastrados à mão no GitHub pelo integrante.
    3. **Validação:** `flutter analyze` e `flutter test` passaram localmente, mas a IA não consegue rodar o GitHub Actions. O build local usou a chave de debug, então o caminho do keystore só é exercitado na pipeline.

* **Revisão de Pull Requests da equipe (17/11 a 21/11):**
  * **O que foi feito:** Apoio na revisão técnica dos PRs dos demais integrantes, comparando cada branch com a `main`: diário de sentimentos (#12), diário reflexivo (#11), nova revisão do gatilho de apoio (#14), FAQ dinâmico e painel da psicóloga (#18), PIN do diário (#24), mascote de acolhimento (#19), especificação dos mappers (#21), persistência offline (#25), testes offline (#26) e canais oficiais de denúncia e apoio (#27). A IA devolveu a funcionalidade, os pontos positivos, os pontos de melhoria e um saldo de cada PR. O integrante usou esse parecer para decidir entre aprovar ou pedir ajustes no GitHub.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompt utilizado:**
    > **Atue como** um revisor de código sênior de projetos Flutter.
    >
    > **Tarefa:** revisar o PR #N comparando a branch com a `main`.
    >
    > **Requisitos:**
    > 1. Descrever a funcionalidade que o PR insere.
    > 2. Considerar apenas o código alterado neste PR, sem apontar pontos de PRs já mergeados.
    > 3. Rodar `flutter analyze` e `flutter test`.
    > 4. Listar os pontos positivos da implementação.
    > 5. Listar os pontos de melhoria e de atenção (bugs, riscos e aderência à modelagem em `docs/` e aos requisitos).
    > 6. Fechar com o saldo: se o PR está aprovável e o que o impede, incluindo conflitos e como resolvê-los.
    > 7. Não alterar nenhum arquivo nesta etapa.
  * **Como a IA ajudou:** Levantou o diff contra a `main` e rodou `flutter analyze` e `flutter test` na maioria dos PRs. No PR #24, explicou que o PIN fica no `SharedPreferences`, guardado como hash SHA-256 com salt, e que isso não é criptografia. No PR #21, apontou que o `docs/modelagem/05-especificacao-mappers.md` estava desatualizado em relação ao FAQ já implementado. Nos PRs #25, #26 e #27 explicou a causa dos conflitos (`CHANGELOG.md` e `docs/uso-de-ia.md`) e, nos dois últimos, resolveu o merge mantendo os dois lados. No #26, o `flutter analyze` ficou sem problemas e os 220 testes passaram depois do merge.
  * **Dificuldades e ajustes manuais:**
    1. **Revisão sem execução:** a IA não abriu o app em aparelho. O que ela diz sobre comportamento vem da leitura do código e dos testes. No PR #25, ela não rodou `flutter analyze` nem `flutter test` e usou os números da descrição do PR.
    2. **Decisão de aprovar:** o resultado da IA é um parecer. Quem decidiu entre aprovar ou pedir ajustes (como nos PRs #11, #12 e #18) foi o integrante, no GitHub.
    3. **Resolução de conflitos:** nos PRs #26 e #27 a IA resolveu o merge. No #26, o push ficou para o integrante.
    4. **Ajuste em um PR:** na revisão do PR #12, o integrante pediu para remover do card "Diário Pessoal" da Home a navegação para a roleta de sentimentos. A IA mudou o destino para `/diary/reflection`, que ainda não estava registrada, então o card passou a mostrar "Disponível em breve".

* **Painel de Gestão e Triagem de Relatos Anônimos (RF09 / EPIC-06) (21/11):**
  * **O que foi feito:** Criação do painel de triagem da psicóloga (`ReportsView`, rota `/psychologist/reports`, com `ReportsController`) e do card "Triagem das denúncias" na Home. A tela lista as denúncias anônimas com selos de status, gravidade e tipo, ordem de triagem e estados de carregamento, vazio e erro (a primeira versão tinha filtros de gravidade e de status e "Ver relato", ambos removidos depois, conforme o registro do ajuste de revisão abaixo). Também foram criados a entidade `Report` (`lib/shared/models/report_model.dart`), o `ReportRepository` (Firestore e em memória), a injeção no `main.dart` e os testes de modelo, controller, tela, Home e contraste WCAG. O `CHANGELOG.md`, o `README.md` e este registro foram atualizados na mesma tarefa.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompt utilizado:**
    > **Atue como** um engenheiro de software sênior com experiência em Flutter.
    >
    > **Tarefa:** implementar o Painel de Gestão e Triagem de Relatos Anônimos (RF09), vinculado ao EPIC-06, com estimativa de 5 Story Points, com base nas capturas de tela do Figma em anexo (Home/Painel da psicóloga, FAQ, Guias e Chat).
    >
    > **Critério de Aceite / DoD:** visualização das denúncias anônimas recebidas, com filtros de gravidade e de status de mediação.
    >
    > **Requisitos:**
    > 1. Seguir a arquitetura, o padrão visual e as cores já usados no projeto, e consultar a modelagem em `docs/` antes de implementar.
    > 2. Manter o anonimato do aluno: o painel não pode ler nem exibir nenhum dado que o identifique.
    > 3. Nomear todos os arquivos novos apenas em inglês.
    > 4. Usar nomes em inglês em todas as coleções e campos do Firestore.
    > 5. Criar testes automatizados da regra de negócio, das telas e do contraste de acessibilidade (WCAG AA).
    > 6. Atualizar o `CHANGELOG.md`, o `docs/uso-de-ia.md`, o `README.md` e a modelagem do Firestore.
    >
    > **Diretrizes de homologação:**
    > 1. Compilação limpa, sem warnings críticos no `flutter analyze`.
    > 2. Teste no emulador Android (API 24+ / Android 7.0+).
    > 3. Commits individuais rastreáveis no GitHub, seguindo Conventional Commits.
  * **Como a IA ajudou:** Leu `docs/modelagem/` e viu que a `Denuncia` já estava especificada, mas sem gravidade e sem o estado de mediação, então estendeu o modelo. Depois, a pedido do integrante, renomeou os arquivos para inglês e passou a coleção e os campos do Firestore para inglês (coleção `reports`; campos `studentUid`, `type`, `description`, `status`, `severity` e `createdAt`), atualizando também `docs/modelagem/03-modelagem-firestore.md`. Reaproveitou o padrão de controller, tela e repositório injetado do FAQ da psicóloga e as cores do `AppColors`. Escreveu 24 testes novos, e `flutter analyze` e `flutter test` ficaram sem problemas (240 testes passando). Validou o build Android com `flutter build apk --debug`.
  * **Dificuldades e ajustes manuais:**
    1. **Gravidade não existe no documento do aluno:** a regra de criação da denúncia aceita só `studentUid`, `type`, `description`, `status` e `createdAt`. Sem o campo, a gravidade é estimada pelo tipo e por palavras de risco no texto. É uma regra provisória que precisa ser validada pela psicóloga da escola.
    2. **Status "em mediação" e regras do Firestore:** a regra de `update` da modelagem só aceitava `pending` e `answered`. A modelagem foi atualizada para aceitar também `inMediation` e a chave `severity`, mas o `firestore.rules` não é versionado e a regra precisa ser publicada no console do Firebase.
    3. **Botão "Responder" do Figma:** não foi criado nesta tarefa, porque a resposta e o chat são o RF10. O card tinha "Ver relato", que abria o texto completo. O botão foi feito na tarefa do chat da psicóloga e ajustado ao Figma no registro do ajuste de revisão abaixo.
    4. **Sem denúncias no app ainda:** nesta tarefa o envio pelo aluno (RF05) não existia no código, e a coleção `reports` só tinha dados se fosse preenchida pelo console do Firebase. O envio foi feito na tarefa seguinte, registrada abaixo.
    5. **Teste no emulador:** o emulador `Pixel_6_API_34` existe, mas o login da psicóloga usa credenciais reais do Firebase que a IA não tem. A homologação visual no aparelho (e em API 24) ficou para o integrante; a IA validou analyzer, testes e o build do APK.
    6. **Testes com lista longa:** o `ListView` constrói os cards sob demanda, e três testes falharam por procurar cards fora da área visível. Os testes passaram a rolar até o card.

* **Chat Anônimo do Aluno em Tempo Real e Envio de Relatos (RF05 / EPIC-06) (21/11):**
  * **O que foi feito:** Criação do chat anônimo do aluno com a escola (`AnonymousChatView`, rota `/report`, com `AnonymousChatController`). O aluno escolhe o tipo do relato, escreve a mensagem e acompanha a conversa em tempo real, e as respostas da psicóloga aparecem sem recarregar a tela. Também foram criados o modelo `ChatMessage` e o `ChatRepository` (`FirestoreChatRepository` sobre `snapshots()` do Firestore e `InMemoryChatRepository`), a injeção no `main.dart`, o registro da rota no `AppWidget` e os testes do controller, da tela e do contraste WCAG. A modelagem do Firestore foi atualizada (mensagens na subcoleção `reports/{uid}/messages` e regras de segurança), e o `CHANGELOG.md`, o `README.md` e este registro foram atualizados na mesma tarefa.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompt utilizado:**
    > **Atue como** um engenheiro de software sênior com experiência em Flutter e Cloud Firestore.
    >
    > **Tarefa:** implementar a parte do aluno do Chat Anônimo e Envio de Relatos (RF05), vinculado ao EPIC-06, de modo que as denúncias enviadas apareçam no Painel de Triagem da psicóloga (RF09) já implementado. O bate-papo deve funcionar em tempo real, com base na tela de chat do aluno do Figma.
    >
    > **Critério de Aceite / DoD:** o aluno envia relatos anonimamente, escolhendo o tipo do relato, e acompanha a conversa com a escola em tempo real, vendo as respostas da psicóloga assim que elas chegam.
    >
    > **Requisitos:**
    > 1. Seguir a arquitetura, o padrão visual e as cores já usados no projeto, e consultar a modelagem em `docs/` antes de implementar.
    > 2. Manter o anonimato do aluno: a mensagem não pode carregar nome nem qualquer dado que o identifique.
    > 3. Atualizar o chat em tempo real com `snapshots()` do Firestore, sem exigir que o aluno recarregue a tela.
    > 4. Funcionar sem internet: a mensagem entra na fila do Firestore e a tela mostra "Enviando…" até sincronizar.
    > 5. Tratar os estados de carregamento, erro de conexão, mensagem vazia, limite de 2000 caracteres e aluno sem login no Firebase.
    > 6. Nomear todos os arquivos novos apenas em inglês e usar nomes em inglês em todas as coleções e campos do Firestore.
    > 7. Criar testes automatizados do controller, da tela e do contraste de acessibilidade (WCAG AA).
    > 8. Atualizar o `CHANGELOG.md`, o `docs/uso-de-ia.md`, o `README.md` e a modelagem do Firestore (estrutura e regras de segurança).
    >
    > **Diretrizes de homologação (UNIT):**
    > 1. Compilação limpa, sem warnings críticos no `flutter analyze`.
    > 2. Teste no emulador Android (API 24+ / Android 7.0+).
    > 3. Commits individuais rastreáveis no GitHub, seguindo Conventional Commits.
  * **Como a IA ajudou:** Viu que os cards "Chat Anônimo", "Denúncias anônimas à escola" e o modal de apoio já apontavam para `/report`, rota que não estava registrada. Propôs usar o `uid` do aluno como id do relato, o que dispensa consulta e índice extra e torna a conversa única e estável, e guardar as mensagens numa subcoleção para o tempo real. Escreveu as regras de segurança do chat, o repositório com `snapshots(includeMetadataChanges: true)` e `hasPendingWrites` para o estado "Enviando…", e 22 testes novos. `flutter analyze` ficou sem problemas e os 262 testes passaram.
  * **Dificuldades e ajustes manuais:**
    1. **Escrita offline no Firestore:** sem rede, o `commit()` só termina quando o servidor responde. O envio passou a considerar a mensagem "na fila" depois de 3 segundos, para a tela não travar, e o balão fica como "Enviando…" até sincronizar.
    2. **Botão CVV sobre o campo de mensagem:** o botão "Ajuda (CVV)" fica no canto inferior direito das telas do aluno, inclusive em `/report`, e cobria o botão de enviar. O campo de mensagem sobe 96 dp para ficar acima dele.
    3. **Regras do Firestore:** a regra de leitura do relato falharia para um aluno sem relato ainda (o documento não existe), então a leitura aceita `resource == null` quando o id é o próprio `uid`. As regras não são versionadas no repositório e precisam ser publicadas no console do Firebase.
    4. **Resposta da psicóloga:** a tela do aluno já mostra as mensagens da psicóloga em tempo real, mas escrever a resposta (RF10) ainda não existe no app da psicóloga, e o painel de triagem mostra só a primeira mensagem do relato.
    5. **Campo `reply` removido:** o campo de resposta único do relato, criado na tarefa anterior, foi trocado pela subcoleção de mensagens, e a modelagem foi atualizada.
    6. **Teste no emulador:** o chat usa o login anônimo e o Firestore reais e não foi aberto em aparelho pela IA. A homologação no emulador (API 24+) e a conferência em tempo real entre dois aparelhos ficam para o integrante.
    7. **Testes com tempo real:** o repositório de teste precisou emitir uma conversa vazia logo na assinatura, como o Firestore faz; sem isso o indicador de carregamento nunca terminava e os testes de tela travavam.
    8. **Chat com erro no emulador:** ao abrir o chat, a tela mostrou "Não foi possível acompanhar a conversa" mesmo com internet. O `adb logcat` do emulador mostrou `PERMISSION_DENIED` nas duas escutas do Firestore (`reports/{uid}` e `reports/{uid}/messages`): as regras de segurança da modelagem ainda não estavam publicadas no projeto do Firebase. A causa não era de rede. A IA passou a diferenciar os erros na mensagem (rede, permissão e genérico) e a registrar o erro real no log; publicar as regras no console do Firebase continua sendo ação do integrante.

* **Telas da Psicóloga: Chat em Tempo Real e Gestão dos Relatos (RF10 / EPIC-06) (22/11):**
  * **O que foi feito:** Criação do chat da psicóloga com o aluno (`PsychologistChatView`, rota `/psychologist/chat`, com `PsychologistChatController`), em tempo real. A psicóloga abre a conversa pelo botão "Responder" dos cards da triagem (tela de triagem e Home), e responde ao aluno (a primeira versão tinha o painel "Gerenciar relato", com seletores de status e de gravidade, removido depois conforme o registro do ajuste de revisão abaixo). O painel de triagem passou a acompanhar os relatos em tempo real (`ReportRepository.watch()`). Também foram criados o `PsychologistChatRepository` (Firestore e em memória), os widgets de chat compartilhados com o aluno, a injeção no `main.dart`, o registro da rota no `AppWidget` e os testes. O `CHANGELOG.md`, o `README.md`, a modelagem do Firestore e este registro foram atualizados na mesma tarefa.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompt utilizado:**
    > **Atue como** um engenheiro de software sênior com experiência em Flutter e Cloud Firestore.
    >
    > **Tarefa:** implementar as telas da psicóloga do Chat e Resposta aos Relatos Anônimos (RF10), vinculado ao EPIC-06, completando o ciclo entre o relato do aluno (RF05) e o Painel de Triagem (RF09) já implementados. O bate-papo deve funcionar em tempo real, com base nas telas de Home/Painel e de Chat da psicóloga do Figma.
    >
    > **Critério de Aceite / DoD:** a psicóloga abre um relato pela triagem, conversa com o aluno anônimo em tempo real, vê as mensagens novas assim que chegam e gerencia o status de mediação e a gravidade do relato.
    >
    > **Requisitos:**
    > 1. Seguir a arquitetura, o padrão visual e as cores já usados no projeto, reaproveitando os componentes do chat do aluno em vez de duplicá-los.
    > 2. Manter o anonimato do aluno: nenhuma tela pode mostrar dado que o identifique, apenas o número do protocolo.
    > 3. Atualizar o chat e o painel de triagem em tempo real com `snapshots()` do Firestore, sem exigir recarregar a tela.
    > 4. Incluir o botão "Responder" nos cards da triagem, abrindo o chat do relato.
    > 5. Permitir mudar o status de mediação e a gravidade dentro do chat, respeitando as regras de segurança do Firestore.
    > 6. Tratar os estados de carregamento, erro de conexão e de permissão, relato inexistente, mensagem vazia e limite de 2000 caracteres.
    > 7. Nomear todos os arquivos novos apenas em inglês e usar nomes em inglês em todas as coleções e campos do Firestore.
    > 8. Criar testes automatizados do controller, das telas e do tempo real.
    > 9. Atualizar o `CHANGELOG.md`, o `docs/uso-de-ia.md`, o `README.md` e a modelagem do Firestore.
    >
    > **Diretrizes de homologação (UNIT):**
    > 1. Compilação limpa, sem warnings críticos no `flutter analyze`.
    > 2. Teste no emulador Android (API 24+ / Android 7.0+).
    > 3. Commits individuais rastreáveis no GitHub, seguindo Conventional Commits.
  * **Como a IA ajudou:** Reaproveitou o chat do aluno: moveu `ChatMessage` para `lib/shared/models/` e extraiu balões, separador de dia, campo de mensagem e barra superior para `lib/shared/widgets/chat/`, mantendo o comportamento e os testes do aluno. Como o id do relato é o `uid` do aluno, a tela da psicóloga trabalha só com o conteúdo e o protocolo. Trocou a leitura única do painel por `snapshots()`, de modo que `load()` continua servindo ao "puxar para atualizar". Escreveu os testes de status (primeira resposta, mediação mantida, aluno que volta a escrever) e de tempo real. `flutter analyze` ficou sem problemas e os 282 testes passaram.
  * **Dificuldades e ajustes manuais:**
    1. **Regras do Firestore:** as ações da psicóloga dependem das regras da modelagem (leitura de `reports` e de `messages`, criação de mensagem com `senderRole: psychologist` e `update` de `status`). Elas precisam estar publicadas no console do Firebase, e a conta usada precisa ter `role: psychologist` em `users/{uid}`.
    2. **Resposta e status:** a decisão de negócio ficou assim: a primeira resposta a um relato pendente muda para "respondida"; relato em mediação continua em mediação; se o aluno volta a escrever, o relato volta para pendente. A equipe de psicologia precisa validar esse fluxo.
    3. **Botão "Ver relato" removido:** a folha de detalhe da tarefa anterior deixou de existir, porque o chat mostra o relato inteiro. O botão virou "Responder", como no Figma.
    4. **Relatos sem mensagens:** um relato criado direto no console não tem mensagens, então a tela mostra o texto do relato como a primeira mensagem do aluno.
    5. **Identificação do aluno:** o id do documento é o `uid` anônimo do aluno. Ele não aparece em nenhuma tela, mas quem abre o console do Firebase consegue vê-lo.
    6. **Teste no emulador:** a IA validou analyzer, testes e o build do APK, mas não abriu o app logada como psicóloga. A homologação no emulador (API 24+) e a conferência do chat entre dois aparelhos ficam para o integrante.
    7. **Telas "guias" e "pais" do Figma:** a edição de guias e o chat do responsável com a psicóloga aparecem nas capturas, mas são outros requisitos e não foram feitos nesta tarefa.

* **Ajustes de Revisão das Telas da Psicóloga: Remoção dos Filtros da Triagem e Botão "Responder" (22/11):**
  * **O que foi feito:** Remoção dos filtros de gravidade e de status de mediação da tela de triagem (`ReportsView`) e do código que os sustentava no `ReportsController`, mantendo o restante da tela (selos, contador, ordem de triagem, estados de carregamento, vazio e erro). Ajuste do botão "Responder" dos cards da triagem (`ReportCard`, na tela de triagem e na Home) às medidas do Figma. Os testes foram atualizados, e `CHANGELOG.md`, `README.md`, `docs/modelagem/03-modelagem-firestore.md`, `docs/levantamento/escopo.md` e este registro foram corrigidos para não citar mais os filtros.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompt utilizado:**
    > **Atue como** um engenheiro de software sênior com experiência em Flutter.
    >
    > **Tarefa:** aplicar ajustes de revisão de fidelidade ao Figma nas telas da psicóloga (Painel de Triagem, RF09, e Chat, RF10), sem alterar o restante das telas aprovadas.
    >
    > **Requisitos:**
    > 1. Remover da tela de triagem os filtros de Gravidade e de Status da mediação, que não estavam previstos no Figma e não têm necessidade, mantendo o restante da tela.
    > 2. Ajustar o botão "Responder" dos cards da triagem às medidas do Figma: ícone `lucide/undo`, padding de 16 na horizontal e 4 na vertical, espaçamento de 8 entre os itens e cor `sky500`.
    > 3. Atualizar os testes automatizados para refletir as mudanças.
    > 4. Documentar o que for necessário e remover ou ajustar, no `CHANGELOG.md`, no `docs/uso-de-ia.md`, no `README.md` e na documentação de modelagem e escopo, tudo o que citar os filtros removidos.
    >
    > **Diretrizes de homologação (UNIT):**
    > 1. Compilação limpa, sem warnings críticos no `flutter analyze`.
    > 2. Teste no emulador Android (API 24+ / Android 7.0+).
    > 3. Commits individuais rastreáveis no GitHub, seguindo Conventional Commits.
  * **Como a IA ajudou:** Localizou o código dos filtros na tela, no controller e nos testes e tirou tudo, inclusive o estado "sem resultado". Montou o botão com `ElevatedButton.icon` e verificou as medidas num teste: cor `sky500`, ícone `undo`, padding 16x4 e gap de 8. Varreu a documentação procurando as menções aos filtros (README, CHANGELOG, modelagem do Firestore, escopo e este registro). `flutter analyze` ficou sem problemas e os 277 testes passaram.
  * **Dificuldades e ajustes manuais:**
    1. **Contraste do botão:** o texto branco sobre `sky500` (`#00A6F4`) tem contraste de cerca de 2,7:1, abaixo dos 4,5:1 do WCAG AA para texto pequeno. A cor foi mantida como o Figma define; se a acessibilidade for prioridade, vale o grupo avaliar `sky700` (que passa) ou texto escuro.
    2. **Altura do botão:** com padding vertical de 4, o botão fica baixo (cerca de 28 dp). A área de toque continua com 48 dp, com o botão visível centralizado nela, e o raio da borda (4) foi estimado, porque o Figma não traz esse valor nas capturas.
    3. **Ordem de triagem:** sem os filtros, a lista continua mostrando primeiro os relatos mais graves e, na mesma gravidade, os mais antigos. A gravidade segue sendo estimada pelo texto do relato.
    4. **Critério de aceite original:** o critério da tarefa RF09 citava "filtros de gravidade e status de mediação". A remoção foi decisão do integrante, e o critério do Jira pode precisar ser atualizado.
    5. **Quebra de linha dos arquivos:** vários arquivos do projeto usam CRLF, e o primeiro script de remoção, escrito para LF, falhou no meio e foi refeito normalizando as quebras de linha.

* **Ajustes de Revisão: Chat da Psicóloga sem Filtros e Assunto Obrigatório no Chat do Aluno (22/11):**
  * **O que foi feito:** Remoção do painel "Gerenciar relato" (seletores de status de mediação e de gravidade) do chat da psicóloga (`PsychologistChatView`) e de todo o código que o sustentava (`setStatus` e `setSeverity` no controller e no repositório). No chat do aluno (`AnonymousChatView`), o assunto da conversa deixou de vir pré-selecionado: o aluno precisa escolher bullying, cyberbullying ou outros antes de enviar a primeira mensagem. Os testes foram atualizados, e `CHANGELOG.md`, `README.md` e `docs/modelagem/03-modelagem-firestore.md` foram corrigidos.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompt utilizado:**
    > **Atue como** um engenheiro de software sênior com experiência em Flutter.
    >
    > **Tarefa:** aplicar ajustes de revisão nos chats do aluno e da psicóloga (RF05 e RF10), mantendo o restante das telas aprovadas.
    >
    > **Requisitos:**
    > 1. Remover do chat da psicóloga os filtros de gravidade e de status. No módulo da psicóloga, nenhuma ideia de filtro deve existir, porque ela não faz parte da proposta inicial do Figma.
    > 2. Manter no chat do aluno a escolha do assunto antes do envio da mensagem, porque é importante o aluno apontar o assunto que quer abordar.
    > 3. Atualizar os testes automatizados para refletir as mudanças.
    > 4. Documentar o que for necessário e remover ou ajustar, no `CHANGELOG.md`, no `docs/uso-de-ia.md`, no `README.md` e na modelagem do Firestore, tudo o que citar o que foi removido.
    >
    > **Diretrizes de homologação (UNIT):**
    > 1. Compilação limpa, sem warnings críticos no `flutter analyze`.
    > 2. Teste no emulador Android (API 24+ / Android 7.0+).
    > 3. Commits individuais rastreáveis no GitHub, seguindo Conventional Commits.
  * **Como a IA ajudou:** Removeu o painel, os dois métodos de escrita e os testes ligados a ele, e deixou um teste que garante que a tela da psicóloga não tem seletores. No aluno, percebeu que "Bullying" já vinha marcado e o aluno poderia enviar sem escolher de verdade; então o assunto passou a ser obrigatório, sem seleção prévia, com aviso quando falta. Varreu a documentação atrás das menções ao que foi removido. `flutter analyze` ficou sem problemas e os testes passaram.
  * **Dificuldades e ajustes manuais:**
    1. **Status "em mediação" sem tela:** sem o painel, nenhuma tela grava `inMediation` nem `severity`. Os valores continuam existindo no modelo (a equipe pode defini-los pelo console, e o app os lê), e o status só muda pelo fluxo da conversa: a primeira resposta marca "respondida" e a volta do aluno marca "pendente". O grupo precisa decidir se mantém esses valores.
    2. **Assunto obrigatório:** é uma decisão de interface tomada pela IA a partir do pedido ("é importante apontar o assunto"). O assunto só é pedido antes da primeira mensagem; nas seguintes, a conversa já tem o assunto.
    3. **Teste no emulador:** a IA validou analyzer e testes, mas não abriu o app em aparelho. A conferência visual no emulador (API 24+) fica para o integrante.

### Mateus Henrique de Araújo Santos

* **Perfil do usuário e logout com confirmação — SCRUM-51 (20/11):**
  * **O que foi feito:** Criação do painel de perfil (`ProfileSheet`, `lib/shared/widgets/profile/profile_sheet.dart`), aberto pelo avatar da Home do aluno e por um ícone de perfil nas Homes de psicóloga e responsável. O aluno vê só codinome e avatar; os perfis institucionais veem nome, e-mail e papel. O botão "Sair da conta" abre um diálogo de confirmação, chama `AuthNotifier.signOut()` e leva para `/onboarding` limpando a pilha. O `InstitutionalSession` passou a carregar o e-mail (lido do Firebase Auth), o `AuthRepository` ganhou o parâmetro `clearStudentData` (ligado no `main.dart`) e o diálogo do aluno avisa a perda dos registros do diário. Teste de widget em `test/profile_sheet_test.dart`.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompts utilizados:**
    > 1. "Adicionar seção de perfil do usuário e opção para deslogar da conta (Logout) [...] Tendo em mente o escopo do projeto, vamos tratar de criar um plano para a execução dessa task, lembrando das restrições de cada perfil de usuário" (com os três critérios de aceite da task).
    > 2. "Aprovo com as suas sugestões inclusas, Os commits não devem ser efetuados ainda porque usaremos um branch que ainda não foi criada"
    > 3. "Gostaria de mudar o modal de logout do aluno, indicando o aviso de perda dos registros em caso de logout que seria o caso de um logout correto?"
  * **Como a IA ajudou:** Leu o fluxo de autenticação e propôs o plano respeitando as restrições de cada perfil (o aluno é anônimo e não expõe dados pessoais; os institucionais mostram nome e e-mail). Sugeriu guardar o e-mail na sessão, em vez de criar um campo no Firestore, e escreveu o painel, o diálogo e os testes. Ao revisar o pedido do aviso, percebeu que o logout só apagava o perfil e deixava o diário e o estado do gatilho de apoio no aparelho, o que tornaria o aviso falso e deixaria o diário visível para o próximo aluno. Ajustou o logout para apagar também esses dados e conferiu que as três chaves locais (`profile`, `diario` e `support_trigger_state`) são limpas. `flutter analyze` sem problemas e 146 testes passando.
  * **Dificuldades e ajustes manuais:**
    1. **Arquivo do Firebase:** o worktree isolado não tinha o `android/app/google-services.json` (ignorado pelo git), e o build falhou até o arquivo ser copiado do checkout principal.
    2. **Pendências:** não há teste automatizado de `AuthRepository.signOut`, porque ele depende do `FirebaseAuth`; o fluxo foi conferido manualmente no emulador. As Homes de psicóloga e responsável ainda são placeholders no momento de execução da task.

* **Especificação dos mappers Documento ↔ Entidade de domínio (20/11):**
  * **O que foi feito:** Criação de `docs/modelagem/05-especificacao-mappers.md`, com a especificação técnica de `toMap()`, `fromMap()`, conversores do Firestore (`fromFirestore`/`toFirestore`), serialização JSON e tratamento de nulos, por entidade (`UserModel`, `LocalUserModel`, `RegistroDiario`, `SupportTriggerState`, `MoodRecord` e as entidades planejadas `Denuncia`, `PerguntaFaq`, `Guia` e `CanalApoio`). Também foi acrescentada a entrada no `CHANGELOG.md`. Nenhum código foi alterado.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompt utilizado:**
    > New task, Leia a documentação do repositório e com base nisso vamos estruturar a documentação de Objeto - Documento entre Firebase Mappers <-> Domain entites. Critério de Aceite / Definition of Done (DoD): Especificação técnica de métodos toMap(), fromMap(), serialização JSON e tratamento de nulos.
  * **Como a IA ajudou:** Leu os documentos de modelagem (`02`, `03`, `04`) e o código dos models e repositórios para descrever o contrato real de cada mapper: tipos convertidos, política de nulos (campo omitido no Firestore, lista nula virando vazia, fallback de `DateTime.now()` em timestamp pendente) e comportamento em caso de dado corrompido em cada leitura. Também propôs os critérios de teste dos mappers e apontou divergências entre código e documentação.
  * **Dificuldades e ajustes manuais:** O código usa nomes em inglês (`users`, `role`, `name`, `createdAt`, `parent`/`psychologist`) e a modelagem usa português (`usuarios`, `papel`, `nome`, `criadoEm`, `responsavel`/`psicologa`); a decisão de qual vale ficou como ponto em aberto no documento. As entidades de FAQ, guias, canais e denúncias ainda não existem no código, então foram especificadas a partir do `04`. O documento foi validado pelo integrante antes do commit.
* **Mascote de acolhimento interativo com escala de humor (RF03 / SCRUM-30) (20/11):**
  * **O que foi feito:** Os cinco cérebros do "Resumo da semana" da Home do aluno passaram a formar uma escala de 1 a 5 (raiva, triste, confuso, neutro, feliz), calculada pela média dos humores dos últimos 7 dias. O cérebro do nível atual fica em destaque (opacidade total e brilho verde) e a escala é recalculada ao voltar da roleta de sentimentos. Sem registros na semana, nenhum cérebro é destacado. Arquivos: `mood_scale.dart` (regra), `HomeController` (`loadScale` e `weekMoods`), `StudentHomeView` (recarrega ao abrir e ao voltar de outra tela), `MoodVisual`/`MoodBubble` (rótulo de semântica) e o botão central da roleta (rótulo "Registrar humor"). Testes novos em `test/modules/student/home/mood_scale_test.dart`.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5), em modo de planejamento antes de implementar.
  * **Prompts utilizados:**
    > Mascote de Acolhimento Interativo e Resposta de Empatia (RF03). Mascote dinâmico que interpreta o humor registrado e exibe um feedback visual na tela home. Agora com a roleta de sentimentos, os mascotes dinâmicos da tela Home de alunos devem levar em consideração os últimos moods selecionados pelo usuário e sumarizar em uma escala de 1 a 5 a partir dos moods de uma semana, atualizando toda vez que um novo mood for selecionado. Analise a tela principal e a roleta de sentimentos e vamos planejar como agir e executar (essas alterações apenas são pertinentes às telas de roleta de mood e home do perfil de ALUNO).
    > Lembre que o mascote já está na tela principal, é o pequeno Cérebro em cima dos widgets de rotas, é nele que vamos implementar a escala. Perceba que há 5 deles com uma borda esverdeada, a borda será usada para apontar o grau da escala que está no momento.
  * **Como a IA ajudou:** Mapeou a Home, a roleta e o repositório do diário com um agente de exploração; propôs o plano (regra de pontuação, janela de 7 dias, recarga da Home ao voltar da roleta); implementou a regra e o destaque reaproveitando o brilho e a opacidade do `MoodBubble`; escreveu 8 testes unitários e rodou `flutter analyze` e `flutter test` (150 testes passando).
  * **Dificuldades e ajustes manuais:** O primeiro plano criava um widget de mascote novo; a correção do usuário (o mascote são os 5 cérebros do resumo) refez o plano. O mapeamento humor→nota foi definido com o usuário: raiva 1, triste 2, confuso 3, neutro 4, feliz 5, e "cansado" (sem cérebro próprio) conta como 2. O destaque é o brilho verde do próprio cérebro, não um contorno desenhado. A conferência visual no aparelho foi feita pelo integrante. Uma suíte e2e com Playwright foi iniciada, mas cancelada por decisão do grupo e mantida só localmente, sem entrar no repositório.

*(A preencher pelo integrante)*

## Sprint 4

### Mateus Henrique de Araújo Santos

* **Justificativa técnica das bibliotecas e dependências do `pubspec.yaml` (SCRUM-43 — 20/11):**
  * **O que foi feito:** Criação da seção "Justificativa de Bibliotecas e Dependências" neste documento, com uma tabela que descreve a finalidade de cada pacote declarado no `pubspec.yaml` (dependências, `dev_dependencies`, assets e configuração) e os arquivos de `lib/` em que cada um é usado. Também foram registradas observações para o grupo: `cupertino_icons` sem uso direto, Firebase configurado só para Android e a divergência entre Hive (modelagem) e `shared_preferences` (código).
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompts utilizados:**
    * > Justificativa Técnica das Bibliotecas e Dependências Adotadas. Documentação em `docs/uso-de-ia.md` explicando o motivo de cada pacote no `pubspec.yaml`. Crie uma nova subcategoria `## Justificativa de Bibliotecas e Dependências`. Analise todos os pacotes utilizados no projeto, veja o pubspec de todos os commits mais recentes de cada usuário do repositório e descreva a análise de forma objetiva e profissional. As alterações serão commitadas em `docs/SCRUM-43/pubspec-justificativas`.
    * > Você vai registrar essa atividade no uso de IA de Mateus na seção `## Sprint 3 e 4` após a seção `## Sprint 2`.
  * **Como a IA ajudou:** Levantou o autor e o último commit de cada integrante e comparou o `pubspec.yaml` de cada um com o da `main`, concluindo que o conjunto de pacotes é idêntico. Depois cruzou cada pacote com os imports em `lib/` para indicar onde é usado e identificou o `cupertino_icons` como o único sem uso direto. Redigiu a seção e fez o commit e o push.
  * **Dificuldades e ajustes manuais:**
    1. **Branch em uso por outro worktree:** `docs/SCRUM-43/pubspec-justificativas` já estava em checkout em outro worktree, então o commit foi feito em uma branch temporária e enviado ao remoto com o nome pedido. A branch local de mesmo nome precisa de um `git pull`.
    2. **Quebra de linha:** o arquivo usa CRLF, e o trecho inserido teve de ser normalizado para não misturar finais de linha.
    3. **Validação:** a análise se baseia em leitura de imports e de diffs. Os testes e o app não foram executados, e a lista de dependências precisa ser revisada pelo grupo.

### Abraão Luiz Ribeiro da Cruz Dantas

*(A preencher pelo integrante)*

### Marcos Paulo

* **Consolidação da documentação: README, CHANGELOG e registro de uso de IA (21/11):**
  * **O que foi feito:** Atualização do `README.md` (responsabilidades da fase 2), do `CHANGELOG.md` (atividades rastreadas no histórico do Git e nas revisões de PR do GitHub, por data) e deste registro, com base no histórico das sessões com a IA.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompt utilizado:**
    > **Atue como** um engenheiro de software sênior e redator técnico.
    >
    > **Tarefa:** atualizar a documentação do projeto com as minhas atividades da fase 2.
    >
    > **Requisitos:**
    > 1. `README.md`: acrescentar as minhas responsabilidades na tabela, seguindo o modelo existente.
    > 2. `CHANGELOG.md`: rastrear minhas alterações no `git log` e nas revisões de PR do GitHub e registrá-las por data (`## [dd/mm/aaaa]` e `### Adicionado`).
    > 3. `docs/uso-de-ia.md`: registrar o uso da IA por sprint, no formato já usado, com base no histórico das sessões.
    > 4. Não registrar nada que não tenha evidência no repositório.
  * **Como a IA ajudou:** Reconstruiu as datas das atividades a partir do `git log` e das revisões feitas no GitHub com a CLI `gh`, inseriu as entradas nas seções certas do `CHANGELOG.md` e organizou o registro de uso de IA por sprint.
  * **Dificuldades e ajustes manuais:** Não existe um arquivo `firebase.rules` versionado no repositório, então as regras do Firebase não puderam ser registradas no CHANGELOG. As datas e os números dos PRs vêm do Git e do GitHub, e o texto final foi revisado pelo integrante. A distribuição das entradas entre as sprints seguiu o calendário de `docs/levantamento/escopo.md`.

* **Atualização In-App Anônima via GitHub Releases (22/11):**
  * **O que foi feito:** Criação do serviço de atualização in-app (`lib/shared/app_update/`). Ao abrir o app, ele consulta o endpoint público `/releases/latest` do GitHub (sem login nem token, com timeout de 5 s) e compara a `tag_name` com a versão instalada (`package_info_plus`). Havendo versão superior, abre um modal acolhedor (`AppUpdateDialog`) que, ao confirmar, baixa o APK com barra de progresso e abre o instalador do Android, pedindo "Instalar apps desconhecidos" só se ainda não concedida. Offline ou com falha na API, a verificação é ignorada. Também foram criados `AppVersion`, `ReleaseInfo`, `AppUpdateRepository`, `ApkDownloader` (confere tamanho e SHA-256), `AndroidApkInstaller`, `AppUpdateController` e `AppUpdatePrompter` (só abre o modal numa tela inicial, uma vez por execução), a integração em `main.dart` e `app_widget.dart` e as permissões no `AndroidManifest.xml`. O `ci_cd.yml` passou a publicar uma GitHub Release com o APK ao criar uma tag `vX.Y.Z`. Foram escritos 57 testes novos (`test/shared/app_update/`). O `CHANGELOG.md`, o `README.md` (responsabilidades e passo a passo de publicação de versão) e este registro foram atualizados na mesma tarefa.
  * **Ferramenta utilizada:** Claude Code (Claude Sonnet 5.5).
  * **Prompt utilizado:**
    > **Atue como** um engenheiro de software sênior.
    >
    > **Tarefa:** Atualização In-App Anônima via GitHub Releases. Implementar um serviço próprio de verificação e atualização automática (In-App Update) integrado à API pública de Releases do repositório do projeto no GitHub. Sempre que uma nova versão (tag) contendo o arquivo `.apk` for publicada, o aplicativo deve detectar a atualização na inicialização, exibir um modal acolhedor ao usuário e, mediante confirmação, baixar o pacote em segundo plano e acionar o instalador nativo do Android, garantindo o anonimato total sem exigir login ou cadastro de testadores.
    >
    > **Critério de Aceite / DoD:**
    > 1. Ao iniciar o aplicativo com acesso à internet, o sistema consulta o endpoint público `/releases/latest` da API do GitHub e compara a `tag_name` remota com a versão local instalada (`package_info_plus`).
    > 2. Caso exista uma versão superior, um modal seguindo a identidade visual do MenteLeve (cores suaves, cantos arredondados e tom acolhedor) informa a novidade e oferece a opção de atualizar.
    > 3. Ao confirmar no modal, o download do `.apk` é feito com barra de progresso visível e, ao concluir, o instalador de pacotes do Android é aberto automaticamente (exigindo a permissão "Instalar apps desconhecidos" apenas se ainda não concedida).
    > 4. Em cenários offline ou de falha na API do GitHub (como rate limit), a verificação é ignorada silenciosamente, com timeout curto, sem travar o app.
    > 5. O repositório no GitHub deve estar público (ou com releases acessíveis), para a requisição ocorrer sem token nem autenticação.
    >
    > **Diretrizes de homologação (UNIT):**
    > 1. Compilação limpa, sem warnings críticos no `flutter analyze`.
    > 2. Teste no emulador Android (API 24+ / Android 7.0+).
    > 3. Commits individuais rastreáveis no GitHub, seguindo Conventional Commits.
    >
    > **Etapas:** primeiro apresentar o plano; depois de aprovado, construir todas as etapas e, ao concluir, atualizar o `docs/uso-de-ia.md`, o `CHANGELOG.md` e o `README.md` com as responsabilidades e as alterações feitas.
  * **Como a IA ajudou:** Leu o projeto antes de planejar e viu que o repositório já era público, que o `ci_cd.yml` só enviava o APK ao Firebase App Distribution (sem criar Release, sem a qual `/releases/latest` devolve 404) e que o `AndroidManifest.xml` não tinha as permissões necessárias. Propôs separar o download (`ApkDownloader`, testável com `MockClient`) do instalador (`ApkInstaller`, que depende do Android) e reaproveitar o `CvvRouteObserver.currentRoute` para só mostrar o modal numa tela inicial, sem interromper o diário ou o chat. Notou que o `run_number` é contado por workflow e que um segundo workflow poderia gerar `versionCode` menor, e por isso pôs a publicação da Release no mesmo `ci_cd.yml`. Leu o código do `open_filex` e confirmou que o APK no cache do app dispensa permissão de armazenamento. Reaproveitou a paleta e o estilo do modal de apoio, escreveu os 57 testes e fez um commit por etapa, em Conventional Commits. Ao final, `flutter analyze` ficou sem problemas e os 334 testes da suíte passaram.
  * **Dificuldades e ajustes manuais:**
    1. **Build quebrado pelo `permission_handler` 13.x:** `flutter analyze` e `flutter test` passaram, mas o `flutter build apk --debug` falhou, porque o `permission_handler_android` 14.x exige `compileSdk` 37 e o Android Gradle Plugin do projeto recomenda no máximo 36. A dependência foi fixada em `^12.0.1`. Só o build real mostrou o problema.
    2. **Permissões que o app não usa:** o `open_filex` traz `READ_EXTERNAL_STORAGE` e `READ_MEDIA_*` para o manifesto. Como o APK fica no cache do app, elas foram removidas com `tools:node="remove"`, o que foi conferido com `aapt dump permissions` no APK gerado.
    3. **Comparação de versões:** a IA tinha adicionado o `pub_semver`, mas ele foi trocado por uma comparação própria de `major.minor.patch`, com testes, por aceitar tags como `v1.2` e por ignorar pré-lançamento e build de forma previsível. O pacote foi removido do `pubspec.yaml`.
    4. **"Em segundo plano":** foi interpretado como não bloquear a tela, com progresso visível. O download não continua com o app fechado, e o modal não pode ser fechado enquanto baixa.
    5. **Versão e assinatura:** o app só se atualiza se a tag for maior que o `versionName` instalado, e o APK novo precisa ter a mesma assinatura (keystore dos Secrets) e `versionCode` maior. Na primeira versão da pipeline o `versionName` vinha do `pubspec.yaml` nos builds comuns e da tag nos builds de tag; isso fez um build da branch (1.0.1) ficar igual à Release (v1.0.1) e o modal não aparecer. Depois a pipeline passou a calcular a versão sozinha (última tag + incremento pelos commits), com `versionCode` derivado da versão, para o Android não recusar a Release por downgrade. Um APK de debug local não é atualizado por um APK de release.
    6. **Validação parcial:** a IA rodou `flutter analyze` (sem problemas), os 334 testes, o `flutter build apk --debug` e abriu o app no emulador `Pixel_6_API_34` (API 34), sem falhas. A homologação em API 24 e o fluxo completo (modal, download, permissão e instalador) com uma Release real ainda dependem de o integrante publicar a primeira tag, porque ainda não existe nenhuma Release no repositório. A IA não publicou tag nem Release por ser uma ação externa.
    7. **Pipeline e publicação automática:** o passo de versão do `ci_cd.yml` foi testado localmente em repositórios git temporários (sem tag, só docs, `fix:`, `feat:`, breaking, dispatch manual e limite de versão) mas o fluxo completo (tag, Release e modal no app) só é confirmado rodando no GitHub. A publicação passou a ser automática a cada push na `main` que altere arquivos do app, com tag e Release criadas pelo workflow. A IA não publicou tag nem Release; os commits foram feitos pelo integrante.
    8. **Limite da API:** a API pública do GitHub permite cerca de 60 requisições por hora por IP, e sem token (para manter o anonimato) quem estoura o limite só não recebe a oferta de atualização, sem erro visível.
    9. **Arquivos regenerados:** rodar o Flutter no Windows alterou os registros de plugins de `macos/` e `windows/`. Essas mudanças ficaram fora dos commits.

### Rayelen de Jesus Oliveira

* **Guia e Lista de Canais Oficiais de Denúncia e Apoio (RF06 / SCRUM-34) (19/11 a 21/11):**
  * **O que foi feito:** A IA consultou o ticket no Jira e verificou o que já existia no código. Depois, rebaseou a branch sobre a `main` já com o FAQ da SCRUM-33/36 e implementou a tela "Canais Oficiais" (`OfficialChannelsView`, rota `/faq/canais-oficiais`). A tela traz Disque 100, Conselho Tutelar e Ouvidoria Escolar, cada um com o que é, quando procurar e como entrar em contato. A IA também criou o card de acesso na tela "Canais de Apoio & FAQ", a função de discagem compartilhada (`dialPhoneNumber`), os testes e os textos da documentação (`CHANGELOG.md`, `README.md` e este registro).
  * **Ferramenta utilizada:** Claude Code (Claude Opus 5.5), com o conector do Jira (Atlassian MCP).
  * **Prompts utilizados:**
    * > verfique agora no jira o SCRUM-34 DO JIRA
    * > faça uma branch nova a partir da main e verifique se tudo que tem na scrum-34 tem no projeto.
    * > verfique a main, faça rebase e verifique se tem tudo que precisa para finalizar esse ticket
  * **Como a IA ajudou:** Comparou o critério de aceite do ticket com o código e com uma branch ainda não mergeada. Assim, apontou que a tela de canais nascia na SCRUM-33/36 e que o rebase deveria esperar o merge dela. Reaproveitou o padrão visual da `StudentFaqView` e colocou a rota nova sob `/faq`, para o botão "Ajuda (CVV)" continuar visível. Escreveu 13 testes novos, que cobrem a lista de canais, a discagem do 100, a falha do discador. Ao final, `flutter analyze` não acusou nenhum problema e os 174 testes passaram.
  * **Dificuldades e ajustes manuais:**
    1. **Números sem alcance nacional:** só o Disque 100 tem número nacional. O Conselho Tutelar é municipal e a ouvidoria depende de cada escola, então os dois aparecem como guia de como encontrá-los, sem botão de ligar. Se a escola informar os números locais, eles podem ser incluídos.
    2. **Arquivos regenerados pelo Flutter:** rodar `flutter analyze` e `flutter test` no Windows reescreveu os registros de plugins de `linux/`, `macos/` e `windows/`, mudando só a quebra de linha (LF para CRLF). Essas alterações foram descartadas para não entrarem no commit.
    3. **Rótulo de acessibilidade:** o primeiro teste do leitor de tela falhou porque o botão estava envolto em outro `Semantics`. O rótulo passou para o `semanticsLabel` do texto do botão.

### Alexandre Pedro de Matos Ferreira

* **Revisão Técnica do PR #28 e Consolidação da Documentação Final (21/11):**
  * **O que foi feito:** Revisão técnica do PR #28 (verificação de mergeability com `git merge-tree`, checagem de conflitos com outros PRs abertos, análise da distribuição de sprints em `docs/uso-de-ia.md` e conferência de referências no repositório) e atualização das responsabilidades de Alexandre no `README.md`, no `CHANGELOG.md` e na seção da Sprint 4 de `docs/uso-de-ia.md`.
  * **Ferramenta utilizada:** Antigravity (Gemini 4 Argon).
  * **Prompts utilizados:**
    * > `analise esse pull request e me retorne um feedback profissional sobre bugs ou conflitos. https://github.com/maarcos4g/mente-leve/pull/28`
    * > `agora preciso q atualize o readme com minhas responsabilidades. também atualize o changelog e o uso de IA. primeiro faça um pull da main`
  * **Como a IA ajudou:** Inspecionou o diff completo do PR #28 via Git e API do GitHub, simulou o merge sem alterar o workspace (`git merge-tree`) contra a `main` e contra o PR #20, apontou ajustes de consistência documental (separação das entradas por sprint, referência a `firebase.rules` sem arquivo versionado e padronização de cabeçalhos no `CHANGELOG.md`) e cruzou o `git log` da `main` para atualizar o `README.md` com base apenas nas entregas versionadas.
  * **Dificuldades e ajustes manuais:** A CLI `gh` não estava disponível no ambiente local, sendo substituída por consultas diretas à API REST do GitHub via PowerShell combinadas com `git fetch origin pull/<N>/head` para leitura do diff e simulação de merge.

* **Revisão Técnica do PR #30 e Implementação da Home dos Responsáveis (`home / parents`) e Gestão de Guias e Orientações (`guias / edit`) (22/11):**
  * **O que foi feito:** Revisão técnica completa do PR #30 (triagem e chat anônimo em tempo real, com validação de `flutter analyze`, 277 testes e diagnóstico de race conditions e regras do Firestore) seguida do planejamento (`/plan`) e implementação das telas faltantes do protótipo: camada compartilhada `GuideModel` / `FirestoreGuideRepository` / `LocalGuideRepository` / `GuideCard` (`guides` no Firestore com cache offline em `SharedPreferences`), tela `"Orientações"` da psicóloga (`PsychologistGuidesView` com CRUD completo e ações de editar/excluir via *swipe* para a esquerda + card de atalho na `PsychologistHomeView`), Home dos responsáveis (`ParentsHomeView` com saudação via Firestore, modal `"Fale com a escola"`, lista de guias e `GuideDetailView` para leitura completa), polimento do ícone de senha no login dos pais, atualização do `README.md`, `CHANGELOG.md` e deste registro, além da nova suíte de testes unitários, de widgets e WCAG AA (372 testes passando no total, `flutter analyze` sem avisos).
  * **Ferramenta utilizada:** Antigravity (Gemini 4 Argon).
  * **Prompts utilizados:**
    * > `analisa o novo pull request atrás de bug e erros: https://github.com/maarcos4g/mente-leve/pull/30`
    * > `/plan ficaram faltando algumas tarefas referente as telas que você aparentemente ignorou: tela dos pais/responsáveis e uma tela especifica para a publicação de conteudos informativos (acredito que o faq).` (com capturas e especificações CSS do Figma para `parents`, `home / parents`, `chat` e `guias / edit`).
    * > `atualize também o changelog e o uso de IA, também o readme com a nova função que desenvolvemos.`
  * **Como a IA ajudou:** Mapeou o que já existia na `origin/main` versus o que faltava (`ParentsHomeView` ainda era um stub e `guides` ainda não tinha implementação Dart), alinhou o modelo `GuideModel` aos campos em inglês já definidos em `docs/modelagem/03-modelagem-firestore.md`, reaproveitou o padrão de resiliência offline com timeouts e cache em `SharedPreferences` do `FirestoreFaqRepository`, preservou a integração de perfil/logout (`showProfileSheet`) e escreveu os testes de repositório, telas e contraste WCAG AA.
  * **Dificuldades e ajustes manuais:**
    1. **Contraste de cores do protótipo nos cards de guia:** No CSS do Figma, a etiqueta de categoria (`#00A6F4`) e a descrição (`#9F9FA9`) sobre `#F4F4F5` ficavam abaixo de `4,5:1`; foram ajustadas para `AppColors.sky700` e `AppColors.slate600` mantendo a identidade visual com conformidade WCAG AA.
    2. **Overflow no modal `"Fale com a escola"`:** O teste de widget detectou `RenderFlex overflowed by 71 pixels on the bottom` no bottom sheet padrão (`isScrollControlled: false`); o modal foi envolvido em `SingleChildScrollView` com `isScrollControlled: true`, passando todos os 372 testes sem avisos.
    3. **Marcadores de conflito residuais em `CHANGELOG.md`:** Ao atualizar o changelog da `main`, foram encontrados marcadores `<<<<<<< HEAD` / `>>>>>>> origin/main` remanescentes na seção `[22/11/2026]`, que foram limpos preservando todas as entradas dos integrantes.

## Justificativa de Bibliotecas e Dependências

Esta seção documenta o motivo técnico de cada pacote declarado no `pubspec.yaml` do MenteLeve.

**Escopo da análise:** foi lido o `pubspec.yaml` do commit mais recente de cada integrante (Abraão, Alexandre, Marcos, Mateus e Rayelen) e o da `main`. Em todos eles o conjunto de pacotes é idêntico. Só a branch antiga `scrum-25-27/integrate-firebase` diverge, por ser anterior à inclusão do `url_launcher` e da pasta `assets/home/`. O uso de cada pacote foi conferido nos imports de `lib/`.

### Dependências de execução (`dependencies`)

| Pacote | Versão | Finalidade | Onde é usado |
|---|---|---|---|
| `flutter` (SDK) | — | Framework de UI multiplataforma, base do app. | Todo o projeto |
| `firebase_core` | ^5.1.0 | Inicializa o Firebase, pré-requisito dos demais pacotes `firebase_*`. | `main.dart` |
| `firebase_auth` | ^7.0.1 | Autenticação: login anônimo do aluno (`signInAnonymously`) e login por e-mail/senha da psicóloga e do responsável. Dispensa backend próprio de credenciais. | `auth_repository.dart`, `auth_notifier.dart` |
| `cloud_firestore` | ^7.1.0 | Banco NoSQL gerenciado, usado para o papel institucional do usuário e para conteúdos institucionais (FAQ, guias, canais, denúncias). Dados do aluno não são gravados nele. | `auth_repository.dart`, `user_model.dart` |
| `provider` | ^6.1.5+1 | Gerência de estado e injeção de dependência (`ChangeNotifierProvider`). Solução oficialmente recomendada, simples e suficiente para o porte do projeto. | `app_widget.dart`, `main.dart` e views de todos os perfis |
| `shared_preferences` | ^2.5.6 | Armazenamento local chave-valor. Mantém no aparelho o perfil do aluno (codinome e avatar), o diário e o estado do gatilho de apoio, preservando o anonimato. | `profile_store.dart`, `prefs_diary_repository.dart`, `prefs_mood_record_repository.dart`, `support_trigger_state_store.dart` |
| `google_fonts` | ^8.2.1 | Carrega a família Poppins definida no padrão visual, sem empacotar arquivos de fonte manualmente. | `app_text_styles.dart` e telas do diário |
| `flutter_svg` | ^2.3.2 | Renderiza SVG. Avatares, mascote e ilustrações da home são vetoriais, o que mantém nitidez em qualquer densidade de tela e reduz o tamanho dos assets. | Seleção de avatar, diário, modal de apoio e widgets da home |
| `lucide_icons_flutter` | ^4.0.2 | Conjunto de ícones Lucide, de traço leve e consistente, que complementa os ícones nativos do Material. | Onboarding, telas de autenticação, diário, home e botão CVV |
| `url_launcher` | ^6.3.2 | Abre aplicativos externos a partir do app. Faz a ligação para o CVV (188), um canal de apoio emergencial. | `cvv_button.dart` |
| `http` | ^1.6.0 | Cliente HTTP. Consulta o `releases/latest` do GitHub e baixa o APK da atualização em stream, o que permite mostrar o progresso. Aceita `MockClient` nos testes. | `app_update_repository.dart`, `apk_downloader.dart` |
| `package_info_plus` | ^10.2.2 | Lê o `versionName` instalado para compará-lo com a tag da release. | `app_update_controller.dart` |
| `path_provider` | ^2.1.6 | Localiza a pasta de cache do app, onde o APK é baixado sem exigir permissão de armazenamento. | `apk_downloader.dart` |
| `open_filex` | ^5.0.0 | Abre o APK baixado pelo instalador nativo do Android (via FileProvider). | `apk_installer.dart` |
| `permission_handler` | ^12.0.1 | Confere e pede a permissão "Instalar apps desconhecidos" só se ainda não concedida. Fixado em 12.x, porque a 13.x exige `compileSdk` 37. | `apk_installer.dart` |
| `cupertino_icons` | ^1.0.8 | Fonte de ícones estilo iOS, incluída pelo template do Flutter. **Não há uso direto em `lib/` hoje**; pode ser removida sem impacto se a equipe preferir enxugar o `pubspec.yaml`. | — |

### Dependências de desenvolvimento (`dev_dependencies`)

| Pacote | Versão | Finalidade |
|---|---|---|
| `flutter_test` (SDK) | — | Framework de testes de unidade e de widget. Ainda não há pasta `test/` no repositório. |
| `flutter_lints` | ^6.0.0 | Conjunto de regras de lint recomendado, ativado em `analysis_options.yaml`. Padroniza o código e é executado por `flutter analyze`. |

### Assets e configuração

- **`assets/images/`, `assets/avatars/`, `assets/home/`:** imagens gerais, avatares SVG do aluno e ilustrações da home.
- **`uses-material-design: true`:** inclui a fonte de ícones do Material.
- **`publish_to: 'none'`:** impede publicação acidental no pub.dev, pois o app é privado.
- **`sdk: ^3.12.0`:** versão mínima do Dart exigida pelo projeto.

### Observações

1. **Firebase só está configurado para Android** (`google-services.json`, fora do controle de versão). Os pacotes `firebase_*` estão declarados para todas as plataformas, mas só inicializam no Android.
2. **Sem pacote de roteamento ou de injeção de dependência extra:** a navegação usa rotas nomeadas do próprio `MaterialApp`, e a injeção é manual no bootstrap. É uma escolha deliberada para manter poucas dependências.
