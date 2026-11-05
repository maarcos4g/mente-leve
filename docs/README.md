# 📚 Documentação do Projeto MenteLeve

Este diretório centraliza toda a documentação técnica, pesquisas de produto, diagramas de modelagem e artefatos de governança do aplicativo **MenteLeve**.

---

## 📁 Estrutura de Pastas

* **[`diagramas/`](diagramas/)**: Modelagens visuais do sistema (Casos de Uso, Diagrama de Classes e Modelagem do Firestore).
* **[`fluxogramas/`](fluxogramas/)**: Fluxogramas completos de navegação e telas dos perfis Aluno, Psicóloga e Responsável.
* **[`prototipos/`](prototipos/)**: Protótipos navegáveis e conceituais do app em PDF (baixa e alta fidelidade).
* **[`apresentacoes/`](apresentacoes/)**: Slides e materiais de apresentação das etapas do projeto.

---

## 📑 Índice dos Documentos

### 1. Pesquisa, Requisitos e Design UI/UX
* **[Estudo de Caso](estudo-de-caso.md)**: Contextualização do problema, público-alvo de 10 a 17 anos e objetivos do app.
* **[Pesquisa e Dados](pesquisa.md)**: Levantamento de dados sobre bullying, cyberbullying e impacto emocional em jovens.
* **[Personas](personas.md)**: Perfis detalhados dos usuários (Aluno, Psicóloga e Responsável).
* **[Benchmark](benchmark.md)**: Análise de concorrentes e diferenciais da proposta anônima do MenteLeve.
* **[Requisitos do Sistema](requisitos.md)**: Especificação completa de Requisitos Funcionais (RF) e Não Funcionais (RNF).
* **[Funcionalidades](funcionalidades.md)**: Descrição detalhada dos recursos por módulo de usuário.
* **[Justificativas de Design](justificativas.md)**: Fundamentação das escolhas de paleta de cores (Tailwind Sky/Slate), tipografia Poppins e acessibilidade.

---

### 2. Modelagem Técnica e Engenharia de Software
* **[01. Casos de Uso](01-casos-de-uso.md)**: Atores, casos de uso principais e diagrama visual do fluxo do aluno e perfis institucionais.
* **[02. Diagrama de Classes](02-diagrama-de-classes.md)**: Entidades de domínio Dart (`UserStudent`, `EmotionalEntry`, `FaqItem`, etc.).
* **[03. Modelagem do Firestore](03-modelagem-firestore.md)**: Estrutura de coleções NoSQL, documentos e regras de privacidade.
* **[04. Mapeamento Dart ↔ Firestore](04-mapeamento-dart-firestore.md)**: Serialização de dados (`toMap`, `fromMap`) e persistência local/remota.

---

### 3. Governança Ágil e Gestão do Projeto
* **[Escopo e Sprints](escopo.md)**: Detalhamento do backlog, estimativas de Story Points e cronograma das 4 sprints.
* **[Estrutura Analítica do Projeto (EAP)](eap.md)**: Decomposição hierárquica das entregas e pacotes de trabalho do projeto.
* **[Registro de Uso de IA](uso-de-ia.md)**: Documentação transparente sobre como cada integrante do grupo utiliza ferramentas de IA como suporte técnico.
