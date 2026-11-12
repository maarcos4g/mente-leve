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

## Sprint 2


### Rayelen de Jesus Oliveira
* **Documentação do gatilho de apoio emergencial (SCRUM-31) (10/11 a 12/11):**
  * **O que foi feito:** A IA preencheu toda a documentação ligada ao ticket: o caso de uso UC20 e a regra RN11, a entidade local do estado do gatilho nos documentos de classes e de mapeamento, a nota de que o gatilho não usa o Firestore, a entrada do `CHANGELOG.md` e este registro. Também foi usada para escrever o prompt de desenvolvimento do ticket e os comentários de andamento no Jira.
  * **Ferramenta utilizada:** Claude (Claude Sonnet 5.5) e o agente que executou o desenvolvimento.
  * **Como a IA ajudou:** Estruturou o prompt a partir da documentação (escopo, casos de uso, modelagem local e Firestore) e do código existente, e documentou o que foi implementado e as decisões pendentes.
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

