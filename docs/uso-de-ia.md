# Registro de Uso de Inteligência Artificial — MenteLeve

Este documento registra como a equipe do **MenteLeve** utiliza ferramentas de Inteligência Artificial Generativa como apoio ao desenvolvimento do projeto.

Nosso objetivo é utilizar a IA de forma ética, prática e transparente: como uma ferramenta de suporte para tirar dúvidas de sintaxe, revisar código, sugerir melhorias de organização e acelerar tarefas repetitivas. Toda a arquitetura, lógica do aplicativo e decisões de projeto continuam sendo avaliadas, testadas e implementadas diretamente pelos membros da equipe.

---

## 1. Registros de Uso por Integrante

### 👤 Alexandre Pedro de Matos Ferreira

* **Automação e Integração com Jira:**
  * **O que foi feito:** Apoio na estruturação inicial das tarefas do projeto e escrita de um script em Python para cadastrar os itens na API do Jira.
  * **Como a IA ajudou:** Ajudou na montagem básica da requisição HTTP e na formatação das descrições.
  * **Dificuldades e ajustes manuais:** A IA indicou um código de campo incorreto para as estimativas (`customfield_10026`), que causava erro `400` na API do Jira. Foi necessário consultar a documentação para achar o campo certo (`customfield_10016`). Além disso, ela sugeriu nomes de sprint com mais de 30 caracteres, que foram reduzidos manualmente.

* **Revisão Técnica de Código (Pull Request #5 — 05/11):**
  * **O que foi feito:** Revisão do PR com o setup inicial do Flutter, temas e telas de login/avatar.
  * **Como a IA ajudou:** Ajudou a analisar o código em busca de possíveis problemas visuais antes do merge na `main`. Apontou o risco de *overflow* (quando o teclado do celular sobe e estoura a tela) na tela de identificação do aluno por falta de scroll, e sugeriu unificar cores soltas para o padrão do tema.
  * **Dificuldades e ajustes manuais:** A IA inicialmente considerou recursos muito recentes do Flutter (como `spacing` em Row/Column), mas optamos por manter `SizedBox` para evitar problemas de compilação em computadores com versões anteriores do SDK.

* **Organização do Repositório e Documentação (05/11):**
  * **O que foi feito:** Reorganização da pasta `docs/`, padronização das imagens de fluxograma e simplificação dos registros de documentação.
  * **Como a IA ajudou:** Sugeriu uma divisão limpa de pastas para apresentações, protótipos e diagramas, facilitando a navegação de quem visita o projeto no GitHub.

---

### 👤 Abraão Luiz Ribeiro da Cruz Dantas
* **Foco:** Arquitetura do app, lógica de negócio e EAP.
* **Registros de uso:**
  * **Atividade:** Apoio na estruturação e revisão dos tópicos da EAP (Estrutura Analítica do Projeto).
  * **Ferramenta:** ChatGPT / Gemini.
  * **Como ajudou:** Sugestão de divisão de pacotes de trabalho para organizar as entregas do projeto.
  * *(Espaço reservado para o integrante detalhar novos usos)*

---

### 👤 Marcos Paulo
* **Foco:** Prototipação e desenvolvimento de telas e componentes Flutter.
* **Registros de uso:**
  * **Atividade:** Apoio na estruturação de widgets e telas iniciais do aplicativo.
  * **Ferramenta:** ChatGPT / Copilot.
  * **Como ajudou:** Dúvidas pontuais sobre widgets de layout e renderização de arquivos SVG.
  * *(Espaço reservado para o integrante detalhar novos usos)*

---

### 👤 Mateus Henrique de Araújo Santos
* **Foco:** Documentação técnica, requisitos, casos de uso e modelagem de dados.
* **Registros de uso:**
  * **Atividade:** Apoio na formatação e conferência dos diagramas de caso de uso e classes de domínio.
  * **Ferramenta:** ChatGPT / Claude.
  * **Como ajudou:** Revisão textual das descrições dos casos de uso e checagem de tipos de dados nos diagramas.
  * *(Espaço reservado para o integrante detalhar novos usos)*

---

### 👤 Rayelen de Jesus Oliveira
* **Foco:** Pesquisa com usuários, dados de impacto e fluxo de navegação do app.
* **Registros de uso:**
  * **Atividade:** Apoio no levantamento de referências e organização do fluxo de navegação entre telas.
  * **Ferramenta:** ChatGPT / Gemini.
  * **Como ajudou:** Estruturação de ideias para os estados de tela (vazio, sucesso e erro) nos fluxogramas dos perfis de usuário.
  * *(Espaço reservado para o integrante detalhar novos usos)*

---

## 2. Como Registrar Novos Usos (Guia Rápido para a Equipe)

Sempre que utilizar IA para apoiar alguma atividade do projeto, adicione um item na sua seção seguindo este modelo simples:

```markdown
* **Data / Atividade:** [Ex: 10/11 - Criação da tela de diário com emojis]
* **Ferramenta utilizada:** [Ex: ChatGPT, Copilot, Gemini]
* **Como ajudou / Prompt principal:** [Ex: Ajudei a montar a lista de emojis e capturar o clique]
* **O que precisou ser corrigido ou ajustado:** [Ex: A IA sugeriu um pacote desatualizado, trocamos pela implementação nativa do Flutter]
```
