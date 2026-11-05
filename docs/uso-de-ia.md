# Registro de Uso de Inteligência Artificial — MenteLeve

Este documento registra como a equipe do **MenteLeve** utiliza ferramentas de Inteligência Artificial Generativa como apoio ao desenvolvimento do projeto.

O objetivo é manter o registro transparente: a IA é utilizada como suporte técnico para tirar dúvidas, revisar código e auxiliar em tarefas operacionais, sendo que todo o trabalho é revisado e validado pelos integrantes.

---

## 1. Registros de Uso por Integrante

### Alexandre Pedro de Matos Ferreira

* **Automação e Integração com Jira:**
  * **O que foi feito:** Apoio na estruturação inicial das tarefas do projeto e escrita de um script em Python para cadastrar os itens na API do Jira.
  * **Como a IA ajudou:** Ajudou na montagem da requisição HTTP e na formatação das descrições.
  * **Dificuldades e ajustes manuais:** A IA indicou um código de campo incorreto para as estimativas (`customfield_10026`), que causava erro `400` na API do Jira. Foi necessário consultar a documentação para achar o campo certo (`customfield_10016`). Além disso, sugeriu nomes de sprint com mais de 30 caracteres, que precisaram ser reduzidos manualmente.

* **Revisão Técnica de Código (Pull Request #5 — 05/11):**
  * **O que foi feito:** Revisão do PR com o setup inicial do Flutter, temas e telas de login/avatar.
  * **Como a IA ajudou:** Ajudou a analisar o código em busca de possíveis problemas visuais antes do merge na `main`. Apontou o risco de *overflow* (quando o teclado do celular sobe e estoura a tela) na tela de identificação do aluno por falta de scroll, e sugeriu unificar cores soltas para o padrão do tema.
  * **Dificuldades e ajustes manuais:** A IA considerou recursos muito recentes do Flutter (como `spacing` em Row/Column), mas mantivemos o uso de `SizedBox` para evitar problemas de compilação em computadores com versões anteriores do SDK.

* **Organização do Repositório e Documentação (05/11):**
  * **O que foi feito:** Reorganização da pasta `docs/`, padronização dos nomes dos fluxogramas e criação do sumário (`docs/README.md`).
  * **Como a IA ajudou:** Auxiliou na estrutura de pastas para apresentações, protótipos e diagramas, facilitando a navegação no GitHub.

---

### Abraão Luiz Ribeiro da Cruz Dantas

*(A preencher pelo integrante)*

---

### Marcos Paulo

*(A preencher pelo integrante)*

---

### Mateus Henrique de Araújo Santos

*(A preencher pelo integrante)*

---

### Rayelen de Jesus Oliveira

*(A preencher pelo integrante)*

---

## 2. Como Registrar Novos Usos (Modelo para a Equipe)

Cada integrante deve preencher sua seção seguindo este formato simples:

```markdown
* **Data / Atividade:** 
* **Ferramenta utilizada:** 
* **Como ajudou / Prompt:** 
* **O que precisou ser corrigido ou ajustado:** 
```
