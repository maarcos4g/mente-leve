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

*(A preencher pelo integrante)*

### Rayelen de Jesus Oliveira

*(A preencher pelo integrante)*

---

## Sprint 2

### Alexandre Pedro de Matos Ferreira

*(A preencher pelo integrante)*

### Abraão Luiz Ribeiro da Cruz Dantas

* **Diário Reflexivo e Checklist de Pontos Positivos — RF02 (09/11):**
  * **O que foi feito:** Criação da tela `DiaryReflectionView` (escolha de humor, escrita livre e checklist de pontos positivos com sugestões e itens personalizados), do `DiaryReflectionController` e do `HiveDiaryRepository`, que salva o diário no aparelho com Hive CE em caixa criptografada (AES-256). O card "Diário Pessoal" da Home passou a abrir a nova tela. Também foram criados os testes do controller, da tela e do repositório. Depois, a tela foi refeita seguindo as telas "personal diary" e "personal diary / add" do Figma (semana atual, botão "Anotar no Diário", lista de registros recentes com exclusão ao arrastar e folha de escrita com "Registrar"), com o checklist em chips vindo do protótipo de baixa fidelidade "diario-reflexivo".
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
  * **Como a IA ajudou:** Estruturou a regra de completar o registro de humor do dia em vez de duplicá-lo, configurou o Hive CE com criptografia AES-256 guardando a chave no armazenamento seguro do Android (`flutter_secure_storage`) e escreveu os testes, incluindo um que confere se o arquivo salvo fica de fato criptografado. Também leu as medidas, cores e fontes direto do Figma e reaproveitou componentes já existentes no projeto (ícones Lucide e o rostinho de emoção do RF01).
  * **Dificuldades e ajustes manuais:**
    1. **Falha ao abrir o armazenamento:** Para o app não travar se o Hive não abrir, o `main.dart` passou a usar o diário em memória nesse caso, garantindo que o botão do CVV continue disponível.
    2. **Repositório nos testes:** Foi criado o `DiaryController.defaultRepository`, para que o app use o Hive e os testes continuem usando o repositório em memória.
    3. **Arquivo do Firebase:** O `android/app/google-services.json` não estava no `.gitignore` e precisou ser deixado de fora do commit manualmente.
    4. **Checklist fora do protótipo final:** O Figma final não tinha o checklist de pontos positivos exigido pela task; ele foi encaixado na folha de escrita usando os chips do protótipo de baixa fidelidade.
    5. **Bug encontrado pelos testes:** O diálogo de "Novo ponto positivo" descartava o campo de texto antes de terminar a animação de fechamento, o que quebrava o app. O diálogo virou um widget com estado próprio.
    6. **Ambiente:** O `flutter analyze` e o build Android falhavam com o "ç/ã" no nome da pasta (`Programação`), que foi renomeada para `Programacao`. O emulador Android 37 reiniciava sozinho por um bug gráfico com a GPU Intel, então o teste manual foi feito na versão web.

### Marcos Paulo

*(A preencher pelo integrante)*

### Mateus Henrique de Araújo Santos

*(A preencher pelo integrante)*

### Rayelen de Jesus Oliveira

*(A preencher pelo integrante)*
