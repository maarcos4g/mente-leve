# MENTE LEVE

## Integrantes 

1. Abraão Luiz Ribeiro da Cruz Dantas
2. Alexandre Pedro de Matos Ferreira
3. Marcos Paulo
4. Mateus Henrique De Araújo Santos
5. Rayelen de Jesus Oliveira

## Turma
PROGRAMAÇÃO PARA DISPOSITIVOS MÓVEIS-GP0029VNO07A 


## Descrição do Projeto
MenteLeve é um aplicativo móvel de apoio à saúde emocional de adolescentes de 10 a 17 anos em situação de bullying, cyberbullying ou baixa autoestima. De forma totalmente anônima e sem login, o app oferece um Diário dos Sentimentos baseado em emojis, acompanhado de um personagem de acolhimento que interpreta o humor registrado e responde com mensagens de escuta ativa, encaminhando o adolescente ao CVV 188 quando os registros indicam sofrimento intenso. Reúne ainda um FAQ empático sobre bullying, canais de denúncia e um botão fixo de emergência que funciona mesmo offline.



## Integrantes e responsabilidades

| Integrante                             | Responsabilidade nesta atividade                                         |
| -------------------------------------- | ------------------------------------------------------------------------ |
| Abraão Luiz Ribeiro da Cruz Dantas     | Arquitetura do app, lógica de negócio - benchmark - funcionalidades - Elaboração da EAP/WBS simplificada do projeto |
| Alexandre Pedro de Matos Ferreira      | Restrições e condições - Pesquisa sobre o problema e benchmark - Slides de apresentação de funcionalidades e requisitos - Protótipo de baixa e alta fidelidade - Justificativas de UI/UX - Declaração de escopo, planejamento das sprints e gerenciamento do backlog no Jira - Governança e registro de uso de IA (`docs/uso-de-ia.md`) e organização da pasta `docs/` - Implementação do Diário de Sentimentos por Emojis (RF01 / SCRUM-28) com disco radial interativo e testes - Implementação do FAQ Empático Dinâmico com cache offline (RF04 / SCRUM-33), Home da Psicóloga integrada ao Firestore e Painel de gestão do FAQ com CRUD e swipe-left (RF08 / SCRUM-36) - Auditoria de acessibilidade WCAG AA e suíte de testes automatizados (SCRUM-41 / SCRUM-44) - Revisão técnica de Pull Requests (#5, #9, #13 e #28). |
| Marcos Paulo                           | Restrições e condições - Desenvolvimento do protótipo - benchmark - Prototipo de Baixa e alta Fidelidade - Setup do projeto Flutter, instalação e configuração do Firebase Auth, Firebase Core e Cloud Firestore - Implementação do Design System - Regras de segurança do Firebase (firebase.rules) - Construção da pipeline de CI/CD para compilação e envio do app ao Firebase App Distribution - Revisão e aprovação dos Pull Requests de todos os integrantes do grupo                                                             |
| Mateus Henrique de Araújo Santos       |       Desenvolvimento da documentação, estruturação e desenvolvimento de requisitos e Personas, Orquestração e desenvolvimento do Conteúdo da Apresentação final Unidade I, Diagramas de Caso de Uso, Modelagem e mapeamento de Classes, Modelagem do esquema Firestore, Implementação da tela Home e Discagem CVV 188, Modal e perfil para logout na plataforma, Mascote de acolhimento com mood dinâmico, explanação de bibliotecas, mapeamento object firebase              |
| Rayelen de Jesus Oliveira              | Desenvolvimento Pesquisa e do problema e revisão final do readme - Pesquisa sobre necessidades e dificuldades do usuário, dados que possam influenciar o aplicativo e md da pesquisa - Priorização das funcionalidades - Justificativas da tipografia - Mapeamento do fluxo de navegação real do aplicativo: fluxograma de rotas, transições de tela e estados vazio/erro dos perfis Aluno, Psicóloga e Responsável - Documentação do gatilho de apoio emergencial (caso de uso UC20, regra RN11 e modelagem do estado local do gatilho) - Implementação do guia de canais oficiais de denúncia e apoio (Disque 100, Conselho Tutelar e Ouvidoria Escolar). |
