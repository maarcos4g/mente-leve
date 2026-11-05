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

*(A preencher pelo integrante)*

### Mateus Henrique de Araújo Santos

*(A preencher pelo integrante)*

### Rayelen de Jesus Oliveira

*(A preencher pelo integrante)*
