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

*(A preencher pelo integrante)*

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

## Sprint 3 e 4

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
    2. **Branch:** o trabalho começou numa branch provisória de worktree e foi renomeado para `SCRUM51/perfil-logout`; commits locais, sem push.

    3. **Pendências:** não há teste automatizado de `AuthRepository.signOut`, porque ele depende do `FirebaseAuth`; o fluxo foi conferido manualmente no emulador. As Homes de psicóloga e responsável ainda são placeholders.
