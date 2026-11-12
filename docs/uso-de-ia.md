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

*(A preencher pelo integrante)*

---

## Sprint 2

### Rayelen de Jesus Oliveira

* **Gatilho automático de apoio emergencial para sofrimento intenso — SCRUM-31 (12/11):**
  * **O que foi feito:** Criação do módulo `lib/modules/student/support_trigger/`: regra de detecção pura (`SupportTriggerRule`, com os parâmetros em `SupportTriggerConfig`), leitura do histórico por interface (`MoodRecordRepository`, com versão em memória para testes e um adaptador que lê a chave `diario` do `SharedPreferences`), estado de controle local (`SupportTriggerStateStore`, chave `support_trigger_state`), `SupportTriggerController` e o modal acolhedor (`SupportModal` e `showSupportModalIfNeeded`). A discagem do `CvvButton` virou o método `CvvButton.dial()`, usado também pelo modal. Foram escritos 48 testes (regra, armazenamento, controller e widget do modal) e a modelagem ganhou o UC20, a RN11 e a entidade local `EstadoGatilhoApoio`.
  * **Ferramenta utilizada:** Claude Code (Claude Opus 5.5).
  * **Prompt utilizado (resumido):**
    > **Tarefa:** SCRUM-31 — "Sistema identifica sequências de humor negativo e dispara modal amigável sugerindo o CVV 188."
    >
    > **Regras:** partir da `origin/main` e ler a documentação antes de codar; detecção 100% offline lendo só o histórico local, sem Firestore, analytics ou notificação à escola; sem diagnóstico; modal só dentro do app, depois de salvar o humor e sem acrescentar passos ao registro; discagem do CVV 188 pelo discador nativo, com aviso se não houver discador; área de toque de 48x48dp, contraste WCAG AA e modo escuro do sistema.
    >
    > **Regra inicial (a validar com a psicóloga):** humores negativos `triste`, `ansioso` e `comRaiva`; um dia é negativo se o último registro dele é negativo; dispara com 3 dias seguidos, incluindo hoje; no máximo um modal por dia, com a contagem reiniciando depois de exibir.
    >
    > **Entregas:** testes unitários e de widget, `flutter analyze` e `flutter test`, documentação (UC20, RN11, modelagem, CHANGELOG e este registro) e commits pequenos em Conventional Commits, sem push.
  * **Como a IA ajudou:** Encontrou o diário e o modelo `RegistroDiario` no PR #11 (ainda fora da `main`) e fez o gatilho depender só de uma interface compatível com o formato dele. Separou a regra em código Dart puro, testou casos de borda (dia sem registro, virada de dia e de mês, limite diário, reinício da contagem e humor fora do conjunto), calculou o contraste das cores do modal e rodou `flutter analyze` e `flutter test`.
  * **Dificuldades e ajustes manuais:**
    1. **Diário fora da `main`:** O registro de humor e a rota `/diary` só existem no PR #11. O gatilho está pronto, mas a chamada `showSupportModalIfNeeded` depois de salvar o humor ainda precisa ser ligada no `DiaryController`/`DiaryFeelingsView` quando o PR entrar.
    2. **Hive ou SharedPreferences:** A modelagem na `main` fala em Hive criptografado, mas o código (e o PR #11) usa `SharedPreferences` sem criptografia. O estado do gatilho foi para o mesmo lugar do diário, então também fica sem criptografia, o que precisa ser alinhado com a RN02.
    3. **5 imagens de humor e 6 humores:** A Home tem 5 imagens (`happy`, `sad`, `neutral`, `confused`, `angry`) e o enum `Humor` tem 6 valores. O mapeamento ficou configurável, e `confused` ficou sem correspondência até o grupo decidir.
    4. **Contraste:** Texto branco sobre o azul `#00A6F4` tem contraste 2,71:1, abaixo do AA. O botão principal do modal usa `#0069A8` no modo claro (5,86:1). O `CvvButton` atual tem o mesmo problema e 34dp de altura, e não foi alterado nesta tarefa.
    5. **Teste de widget:** O primeiro rascunho do teste do modal usava uma classe inexistente e envolvia o app em um `MediaQuery` sem tamanho de tela; os dois erros foram corrigidos na revisão, antes de rodar os testes.
    6. **Ambiente:** O Flutter não estava no PATH e a máquina não tem Android SDK, então o emulador não foi usado: a validação foi feita só pelos testes automatizados, e o teste em API 24+ (e em modo avião) continua pendente.
