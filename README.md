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
| Abraão Luiz Ribeiro da Cruz Dantas     | Arquitetura do app e lógica de negócio - Benchmark - Levantamento de funcionalidades e requisitos - Elaboração da EAP/WBS simplificada do projeto - Implementação do Diário Reflexivo e Checklist de Pontos Positivos (RF02) com persistência local em SharedPreferences - Histórico no calendário do diário e mascote Breno com a cara de cada emoção no seletor e no Diário Pessoal (RF01 / RF02) - Regra de um sentimento por dia, com alteração do humor do dia (RF01) - Proteção por PIN no Diário Pessoal (hash SHA-256 com salt, só no aparelho) - Persistência offline do diário e entrada do aluno sem internet com sessão local (EPIC-03) - Bateria de testes de falha de conexão e correção do FAQ que travava sem internet (EPIC-09), com homologação em emulador Android 7.0 (API 24) - Ajustes na pipeline de CI para o diário reflexivo |
| Alexandre Pedro de Matos Ferreira      | Restrições e condições - Pesquisa sobre o problema e benchmark - Slides de apresentação de funcionalidades e requisitos - Protótipo de baixa e alta fidelidade - Justificativas de UI/UX - Declaração de escopo, planejamento das sprints e gerenciamento do backlog no Jira - Governança e registro de uso de IA (`docs/uso-de-ia.md`) e organização da pasta `docs/` - Implementação do Diário de Sentimentos por Emojis (RF01 / SCRUM-28) com disco radial interativo e testes - Implementação do FAQ Empático Dinâmico com cache offline (RF04 / SCRUM-33), Home da Psicóloga integrada ao Firestore e Painel de gestão do FAQ com CRUD e swipe-left (RF08 / SCRUM-36) - Auditoria de acessibilidade WCAG AA e suíte de testes automatizados (SCRUM-41 / SCRUM-44) - Revisão técnica de Pull Requests (#5, #9, #13 e #28). |
| Marcos Paulo                           | Restrições e condições - Desenvolvimento do protótipo - benchmark - Prototipo de Baixa e alta Fidelidade - Setup do projeto Flutter, instalação e configuração do Firebase Auth, Firebase Core e Cloud Firestore - Implementação do Design System - Regras de segurança do Cloud Firestore (publicadas no console do Firebase) - Construção da pipeline de CI/CD para compilação e envio do app ao Firebase App Distribution - Implementação do Painel de Gestão e Triagem de Relatos Anônimos da psicóloga, (RF09 / EPIC-06) - Implementação do chat anônimo do aluno com a escola em tempo real, com envio de relatos e fila offline (RF05) - Implementação do chat da psicóloga com o aluno em tempo real (RF10) - Implementação da atualização in-app anônima via GitHub Releases (verificação na inicialização, modal acolhedor com barra de progresso, download do APK com conferência de integridade e instalador nativo do Android) e publicação automática da Release com o APK na pipeline de CI/CD - Revisão e aprovação dos Pull Requests de todos os integrantes do grupo                                                             |
| Mateus Henrique de Araújo Santos       |       Desenvolvimento da documentação, estruturação e desenvolvimento de requisitos e Personas, Orquestração e desenvolvimento do Conteúdo da Apresentação final Unidade I, Diagramas de Caso de Uso, Modelagem e mapeamento de Classes, Modelagem do esquema Firestore, Implementação da tela Home e Discagem CVV 188, Modal e perfil para logout na plataforma, Mascote de acolhimento com mood dinâmico, explanação de bibliotecas, mapeamento object firebase              |
| Rayelen de Jesus Oliveira              | Desenvolvimento Pesquisa e do problema e revisão final do readme - Pesquisa sobre necessidades e dificuldades do usuário, dados que possam influenciar o aplicativo e md da pesquisa - Priorização das funcionalidades - Justificativas da tipografia - Mapeamento do fluxo de navegação real do aplicativo: fluxograma de rotas, transições de tela e estados vazio/erro dos perfis Aluno, Psicóloga e Responsável - Implementação e documentação do gatilho de apoio emergencial (modal acolhedor com o CVV 188 após registros de sofrimento intenso no diário, caso de uso UC20, regra RN11 e modelagem do estado local do gatilho) - Implementação do guia de canais oficiais de denúncia e apoio (Disque 100, Conselho Tutelar e Ouvidoria Escolar) - Revisão final de consistência entre Jira, documentação e código (SCRUM-48) e alinhamento da documentação à versão final do app (modelagem, EAP, escopo, justificativas, registro de uso de IA e CHANGELOG). |

## Atualização do app (GitHub Releases)

O app Android verifica sozinho, ao abrir, se existe uma versão nova na API pública de Releases do repositório (`/releases/latest`), sem login e sem token. Se houver, mostra um modal, baixa o APK com barra de progresso e abre o instalador do Android. Sem internet ou com falha na API, a verificação é ignorada e o app abre normalmente. O repositório precisa continuar **público**.

A publicação é **automática**: não é preciso editar o `pubspec.yaml`, criar tag ou subir arquivo à mão.

- A cada push na `main` que altere arquivos do app (`lib/`, `assets/`, `android/`, `pubspec.yaml` ou `pubspec.lock`) desde a última tag, a pipeline (`.github/workflows/ci_cd.yml`) calcula a próxima versão, compila o APK assinado, cria a tag `vX.Y.Z` e publica a Release com o arquivo `mente-leve-vX.Y.Z.apk`. Mudanças só em docs, testes ou CI não geram Release nem oferecem atualização aos usuários.
- O incremento vem das mensagens de commit (Conventional Commits) desde a última tag: `feat!:` ou `BREAKING CHANGE` sobe o **major**, `feat:` sobe o **minor** e qualquer outro (`fix:`, `refactor:` etc.) sobe o **patch**.
- Para testar antes do PR, rode o workflow na branch (Actions → CI/CD → Run workflow) escolhendo `patch`, `minor` ou `major`. Com `nenhum`, só gera o build e envia ao Firebase.
- O app só oferece a atualização se a tag da Release for maior que o `versionName` instalado. Builds da branch ou da `main` sem Release usam a versão da última tag, então não mostram o modal.
- O `versionName` do APK vem da tag, não do `pubspec.yaml` (o campo `version` do pubspec só vale para builds locais). O `versionCode` é calculado como `(MAJOR*10000 + MINOR*100 + PATCH) * 10000 + run_number`, para que uma versão maior nunca seja recusada pelo Android como downgrade. Versões aceitas: até `20.99.99`.

Código em `lib/shared/app_update/`.
