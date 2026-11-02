# Declaração de Escopo do Projeto e Calendário de Sprints — MenteLeve

## 1. Visão Geral e Justificativa do Projeto

O **MenteLeve** é uma solução móvel desenvolvida em **Flutter/Dart** com integração ao ecossistema em nuvem **Firebase**, voltada ao apoio emocional e prevenção ao bullying, cyberbullying e baixa autoestima entre adolescentes de 10 a 17 anos no ambiente escolar.

Em momentos de crise ou sofrimento emocional, o medo da exposição e do julgamento social impede que os jovens procurem ajuda diretamente com responsáveis ou professores. O projeto responde a essa lacuna atuando como um refúgio digital discreto, empático e de acesso imediato, preservando o anonimato absoluto do estudante, enquanto provê canais seguros e estruturados para que a escola (psicólogos e orientadores pedagógicos) e a família possam intervir de maneira preventiva e assertiva.

---

## 2. Escopo do Produto (Product Scope)

O escopo do produto foi delimitado a partir dos requisitos funcionais (RF), requisitos não funcionais (RNF), regras de negócio e aditivos validados na Unidade I:

### 2.1. Funcionalidades Incluídas (In-Scope)

#### A. Perfil do Estudante / Adolescente (Usuário Central — Anonimato Estrito)
* **Sem Exigência de Login:** Acesso direto às ferramentas essenciais sem formulários de cadastro, login ou coleta de dados biográficos/identificadores.
* **Diário de Sentimentos Rápido (RF01):** Registro diário do humor através de emojis grandes e amigáveis, com interação simplificada completada em até 3 toques.
* **Diário Reflexivo e Pontos Positivos (RF02):** Área de expressão livre com escrita aberta e ferramenta de checklist dos pontos positivos do dia.
* **Mascote de Acolhimento Interativo (RF03):** Elemento de UI dinâmico que interpreta o humor selecionado e oferece devolutivas com linguagem acolhedora e escuta ativa.
* **Gatilho de Apoio Emergencial para Sofrimento Intenso:** Reconhecimento automático de registros recorrentes de angústia grave com disparo de modal discreto incentivando a busca por ajuda.
* **Botão Fixo de Emergência CVV 188 (RF05):** Botão persistente em destaque em todas as telas centrais, executando discagem telefônica direta para o 188 via discador nativo do sistema operacional sem demandar pacote de dados móveis ou internet ativa.
* **FAQ Educativo Empático (RF04):** Conteúdo curado sobre identificação de bullying, cyberbullying, ansiedade e autocuidado, com sincronização em nuvem e suporte a leitura em cache offline.
* **Canais Oficiais de Denúncia e Apoio (RF06):** Centralização de contatos institucionais e canais de proteção (Disque 100, Conselho Tutelar, Ouvidoria Escolar).
* **Envio de Relatos e Queixas Anônimas (RF07):** Canal de comunicação unidirecional permitindo que o aluno relate episódios sofridos ou testemunhados na escola sem identificação de autoria.

#### B. Perfil Institucional — Psicóloga Escolar e Equipe Pedagógica (Acesso Autenticado)
* **Autenticação Institucional Segura (RF08):** Login com e-mail institucional e senha via **Firebase Authentication** restrito a profissionais cadastrados.
* **Painel de Triagem e Gestão de Relatos (RF10):** Visualização e categorização por nível de criticidade dos relatos e queixas anônimas submetidos pelos alunos.
* **Painel de Curadoria e Publicação do FAQ (RF09):** Módulo administrativo (CRUD) conectado ao **Cloud Firestore** para cadastrar, editar e remover perguntas e orientações educativas validadas psicologicamente.
* **Mediação e Resposta Institucional (RF11):** Mecanismo de despacho de orientações gerais de acolhimento para o mural coletivo do aplicativo.

#### C. Perfil de Pais e Responsáveis
* **Autenticação de Responsável (RF14):** Login para responsáveis legais com credenciais fornecidas pela escola.
* **Módulo Informativo e Sinais de Alerta (RF12):** Guia de orientação familiar sobre sinais precoces de sofrimento emocional, bullying e condutas preventivas.

---

## 3. Escopo do Projeto e Entregáveis Técnicos (Project Scope)

Em estrita observância à folha de avaliação da II Avaliação da disciplina, o projeto abrange a entrega dos seguintes artefatos de engenharia de software e código:

### 3.1. Artefatos de Software e Infraestrutura
1. **Aplicativo Móvel Flutter:**
   - Implementado obrigatoriamente em **Flutter** e **Dart**.
   - Arquitetura limpa e modular (separação em camadas de Apresentação, Domínio, Dados e Core).
   - Fidelidade visual estrita aos protótipos de alta fidelidade desenhados no Figma e aprovados na Unidade I (paleta azul-céu `#00A6F4`, superfícies `#FAFAFA`, acento rosa `#FDADC1` e tipografia `Poppins`/`Noto Sans`).
   - Aderência às diretrizes de acessibilidade **WCAG AA** (contraste e área mínima de toque de 48x48dp).
   - Compatibilidade mínima garantida: **Android 7.0 (API 24)** ou superior.
   - **Critério Eliminatório:** Execução limpa e estável no emulador Android sem crashes ou travamentos.
2. **Integração com Nuvem Firebase:**
   - **Firebase Authentication** para perfis institucionais.
   - **Cloud Firestore** para conteúdos dinâmicos do FAQ, relatórios de triagem e murais.
   - **Regras de Segurança (`firestore.rules`):** Controle rigoroso de RBAC, permitindo gravação cega anônima em denúncias e proibindo a leitura indiscriminada por clientes não autenticados.
   - **Persistência Offline-First:** Armazenamento local de sentimentos e cache local (Hive / SharedPreferences / Firestore offline persistence).

### 3.2. Artefatos de Modelagem e Documentação Técnica (`docs/`)
1. **Diagrama de Casos de Uso:** Atualizado cobrindo perfis (Adolescente, Psicóloga, Pais).
2. **Diagrama de Classes (Modelos de Domínio Dart):** Especificação das entidades centrais com atributos, tipos estritos Dart, métodos e relacionamentos.
3. **Modelagem do Banco de Dados Firestore:** Dicionário de dados, coleções, subcoleções e campos do Cloud Firestore.
4. **Mapeamento Entidade-Documento:** Documentação dos conversores `toMap()`, `fromMap()` e serializadores Dart <-> Firestore.
5. **Mapeamento de Navegação Real:** Fluxograma técnico das rotas nomeadas e transições do app.
6. **Registro de Uso de Inteligência Artificial (`docs/uso-de-ia.md`):** Registro formal com os prompts mais eficientes, erros e alucinações de IA mitigados e justificativas técnicas das bibliotecas do `pubspec.yaml`.
7. **Governança do Repositório:** Histórico de commits individuais consistentes (Conventional Commits), rastreabilidade de responsabilidades no `README.md` e histórico no `CHANGELOG.md`.

---

## 4. Limites do Projeto — O que NÃO está no Escopo (Out-of-Scope)

Para garantir o cumprimento rigoroso dos prazos acadêmicos e a conformidade técnica, os seguintes itens estão explicitamente **fora do escopo**:

* **Login para Adolescentes:** Não será implementada autenticação por biometria, e-mail, telefone ou redes sociais para o estudante, preservando o princípio inegociável de anonimato do estudo de caso.
* **Chat Síncrono Bidirecional Aberto (WebSockets):** O aplicativo não incluirá salas de bate-papo abertas entre adolescentes, prevenindo novos cenários de cyberbullying.
* **Diagnósticos Médicos ou Psiquiátricos por IA:** O mascote e o app não emitem laudos, prescrições ou diagnósticos clínicos; seu papel é estritamente de acolhimento empático inicial e encaminhamento para serviços humanos capacitados (CVV 188 e psicóloga).
* **Compilação e Suporte a iOS / Web / Desktop:** O foco exclusivo de validação para a Unidade II é a plataforma móvel **Android**.
* **Processamento de Pagamentos ou Monetização:** O projeto possui escopo puramente socioeducativo e assistencial.

---

## 5. Premissas e Restrições do Projeto

### Premissas (Assumptions)
* Os alunos avaliadores e docentes possuem ambiente de emulação Android Studio configurado (API 24+) para testar o APK gerado.
* A infraestrutura do Firebase permanecerá no plano gratuito (Spark Plan) durante toda a fase de avaliação acadêmica.
* Os protótipos de alta fidelidade desenhados na Unidade I representam a referência contratual de design de interface.

### Restrições (Constraints)
* **Prazo Fatal de Apresentação:** Checkpoints e apresentações nos dias **24/11/2026** e **01/12/2026**.
* **Tecnologias Obrigatórias:** Linguagem Dart, framework Flutter e ecossistema Firebase.
* **Critério de Compilação:** Aplicativo com erro de compilação ou incompatibilidade no emulador receberá nota zero na componente prática.
* **Conectividade Intermitente:** O app deve prever quedas de conexão sem que ocorra perda do registro do diário ou travamento de telas.

---

## 6. Calendário e Planejamento de Sprints

O cronograma de desenvolvimento foi estruturado em **4 Sprints semanais**, totalizando **121 Story Points** gerenciados no Jira:

### Planejamento Detalhado por Box de Sprint

#### 🟦 Box Sprint 1: Fundação, EAP & Modelagem de Domínio
> **Período:** 01/11/2026 a 08/11/2026 &nbsp;|&nbsp; **Carga:** 39 Story Points (13 Tarefas) &nbsp;|&nbsp; **Status:** Ativa no Quadro  
> **Meta da Sprint (*Sprint Goal*):** Estruturar a governança ágil, formalizar EAP e escopo, produzir diagramas de classe e banco Firestore, e configurar o ambiente Flutter com Design System.
> 
> * **Entregáveis Técnicos:**
>   - [x] Declaração de Escopo do Projeto formalizada (`docs/escopo.md`)
>   - [ ] Estrutura Analítica do Projeto simplificada (`docs/eap.md`)
>   - [ ] Diagrama de Casos de Uso com novas regras de negócio (`docs/casos-de-uso.md`)
>   - [ ] Diagrama de Classes e Modelos de Domínio Dart (`docs/diagrama-classes.md`)
>   - [ ] Modelagem do Banco Firestore e Mapeamento Objeto-Documento (`docs/modelagem-firestore.md`)
>   - [ ] Setup do projeto Flutter, arquitetura em camadas e `ThemeData` (paleta azul-céu e Poppins)
>   - [ ] Telas iniciais (Home com card de humor e Login Institucional)

#### 🟩 Box Sprint 2: Core Features, Autenticação & Diário Offline
> **Período:** 08/11/2026 a 15/11/2026 &nbsp;|&nbsp; **Carga:** 38 Story Points (8 Tarefas) &nbsp;|&nbsp; **Status:** Planejada  
> **Meta da Sprint (*Sprint Goal*):** Conectar serviços Firebase Core, implementar login restrito da equipe e entregar o núcleo do Diário de Emoções com suporte a funcionamento offline.
> 
> * **Entregáveis Técnicos:**
>   - [ ] Configuração do Firebase Core e inicialização segura no Android
>   - [ ] Autenticação Firebase Auth (e-mail institucional para psicóloga e pais)
>   - [ ] Camada de persistência local offline (Hive / SharedPreferences)
>   - [ ] Interface do Diário de Sentimentos por Emojis grandes (registro em até 3 toques)
>   - [ ] Diário reflexivo livre e checklist de pontos positivos
>   - [ ] Mascote de acolhimento interativo com devolutivas empáticas ao humor

#### 🟨 Box Sprint 3: Suporte, Informação & Mediação Institucional
> **Período:** 15/11/2026 a 22/11/2026 &nbsp;|&nbsp; **Carga:** 24 Story Points (6 Tarefas) &nbsp;|&nbsp; **Status:** Planejada  
> **Meta da Sprint (*Sprint Goal*):** Desenvolver o Botão de Emergência CVV 188 offline, o FAQ dinâmico sincronizado via Firestore e o painel de triagem de relatos da psicóloga.
> 
> * **Entregáveis Técnicos:**
>   - [ ] Botão flutuante de emergência CVV 188 com discagem nativa sem internet (`url_launcher`)
>   - [ ] FAQ empático com cards expansíveis sincronizados com o Firestore e fallback offline
>   - [ ] Tela de contatos e canais oficiais de denúncia e proteção
>   - [ ] Painel administrativo de triagem e visualização de relatos anônimos recebidos
>   - [ ] CRUD no Firestore para a psicóloga gerenciar perguntas do FAQ
>   - [ ] Regras de segurança de banco de dados (`firestore.rules`) com controle RBAC

#### 🟧 Box Sprint 4: Homologação no Emulador, Governança de IA & Defesa Oral
> **Período:** 22/11/2026 a 01/12/2026 &nbsp;|&nbsp; **Carga:** 20 Story Points (7 Tarefas) &nbsp;|&nbsp; **Status:** Planejada  
> **Meta da Sprint (*Sprint Goal*):** Homologar a execução limpa no emulador Android, documentar formalmente o uso de IA (`docs/uso-de-ia.md`) e preparar a apresentação da defesa oral.
> 
> * **Entregáveis Técnicos:**
>   - [ ] Registro completo de uso de IA generativa (`docs/uso-de-ia.md`) com prompts, erros mitigados e justificativas de bibliotecas
>   - [ ] Auditoria de código para garantir ausência de bugs de IA que impeçam compilação
>   - [ ] Homologação de build APK limpa e execução no emulador Android (API 24+)
>   - [ ] Bateria de testes de conexão intermitente e modo offline
>   - [ ] Elaboração dos slides de apresentação e ensaio da defesa oral (2,0 pts)
>   - [ ] Fechamento do repositório no GitHub, `README.md`, `CHANGELOG.md` e submissão no Teams

---

### 📊 Resumo Executivo das Sprints

| Sprint | Período | Meta da Sprint (*Sprint Goal*) | Carga (SP) | Entregáveis Principais |
| :--- | :--- | :--- | :---: | :--- |
| **Sprint 1** | **01/11 a 08/11** | Estruturação de Governança, EAP, Modelagem de Dados, Setup do Projeto Flutter e Telas Base. | **39 SP** | `docs/eap.md`, `docs/escopo.md`, Diagramas UML (Casos de Uso e Classes), Esquema Firestore, Setup Flutter, Design System (`ThemeData`), Home e Login. |
| **Sprint 2** | **08/11 a 15/11** | Implementação do Firebase Core, Autenticação Institucional, Diário de Sentimentos e Mascote. | **38 SP** | `firebase_core`, `firebase_auth`, Cache local do Diário (Hive), Seletor de Emojis em 3 toques, Diário Reflexivo e Mascote com mensagens empáticas. |
| **Sprint 3** | **15/11 a 22/11** | Funcionalidades de Suporte, Botão CVV 188, FAQ Sincronizado e Painel da Psicóloga. | **24 SP** | Integração `url_launcher` para discagem offline 188, CRUD do FAQ no Firestore, Painel de Triagem com filtros de queixas e Regras de Segurança RBAC. |
| **Sprint 4** | **22/11 a 01/12** | QA Rigoroso, Homologação no Emulador Android, Governança de IA e Preparação para a Defesa Oral. | **20 SP** | `docs/uso-de-ia.md`, APK validado sem erros no emulador, testes de falha de conexão (offline), slides da apresentação e consolidação final do README/CHANGELOG. |
| **Total** | **4 Semanas** | **Ciclo Completo de Desenvolvimento e Homologação** | **121 SP** | **100% dos Requisitos da II Avaliação UNIT Atendidos** |

---

## 7. Critérios de Homologação e Conclusão (Definition of Done — DoD)

Uma tarefa ou entrega só é considerada concluída (*Done*) se cumprir cumulativamente:

1. **Compilação e Execução Limpa:** O código compila sem warnings críticos no Flutter Analyzer e executa sem falhas no emulador Android (API 24+).
2. **Resiliência Offline:** Recursos essenciais (Diário e CVV) respondem perfeitamente mesmo com o dispositivo em Modo Avião.
3. **Padrão de Código:** Código Dart formatado (`dart format`), documentado e seguindo os princípios de Clean Code e responsabilidade única.
4. **Rastreabilidade Git:** Commits individuais associados à funcionalidade, com mensagens claras no padrão Conventional Commits.
5. **Atualização da Documentação:** Arquivos `README.md`, `CHANGELOG.md` e referências em `docs/` atualizados.

