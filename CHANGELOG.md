## [01/09/2026]

### Adicionado

- Análise inicial do estudo de caso.

## [08/09/2026]

### Adicionado

- PESQUISA, BENCHMARK E PERSONAS

## [15/09/2026]

### Adicionado

- Descrição de Funcionalidades e Requisitos
- Documento para apresentação (Slides)

## [21/09/2026]

### Adicionado

- Protótipo de baixa fidelidade

## [05/10/2026]

### Adicionado

- Apresentação da Unidade I
- Protótipo de Alta Fidelidade
- Justificativas UI/UX

## [02/11/2026]

### Adicionado

- Declaração formal de Escopo do Projeto e Calendário de Sprints (`docs/levantamento/escopo.md`).
- Registro de uso e governança de Inteligência Artificial (`docs/uso-de-ia.md`).
- Arquivo `.gitignore` para proteção de credenciais de ambiente e arquivos de apoio.
- Diagramas de Caso de uso
- Modelagem e mapeamento de Classes
- Esquema Firestore

## [03/11/2026]

### Adicionado

- EAP/WBS simplificada do projeto (`docs/eap.md`): diagrama Mermaid, estrutura hierárquica, dicionário com critérios de aceite e matriz de rastreabilidade RF/RNF x pacotes de trabalho.
- Fluxograma de navegação real do aplicativo, com rotas nomeadas, transições de tela e estados vazio/erro.
  - Fluxo 1: entrada e autenticação (onboarding, codinome, seleção de perfil, login institucional e de responsável).
  - Fluxo 2: aluno, com registro de humor, histórico do diário (criar, editar e excluir) e botão CVV 188.
  - Fluxo 3: aluno, com canais de apoio, FAQ e denúncia anônima (fila offline e leitura da resposta).
  - Fluxo 4: psicóloga (triagem, resposta, gestão de FAQ e guias) e responsável (consulta de guias).
- Legenda de cores (tela, entrada/destino, concluído, erro, vazio/pendente, CVV ou sem protótipo, só no protótipo).
- Estados de erro e vazio mapeados: credencial inválida, sem conexão, falha ao salvar, diário vazio, sem discador, FAQ e guias sem cache, triagem sem denúncias, denúncia aguardando envio e sem resposta.

## [05/11/2026]

### Modificado

- Reorganização da pasta `docs/` com criação de subdiretórios dedicados para apresentações (`docs/apresentacoes/`) e protótipos (`docs/prototipos/`).
- Padronização dos nomes dos fluxogramas (`docs/fluxogramas/`) em formato limpo (*kebab-case*), sem espaços ou caracteres especiais.
- Atualização e simplificação do registro de uso de IA (`docs/uso-de-ia.md`), estruturado por integrante com template rápido e registros das atividades de revisão técnica e governança.
- Registro de uso de IA (`docs/uso-de-ia.md`) reorganizado por sprint e colaborador, com prompts utilizados e problemas e ajustes manuais de cada atividade.
- Criação das subpastas `docs/modelagem/` (casos de uso, diagrama de classes, modelagem Firestore e mapeamento Dart) e `docs/levantamento/` (benchmark, escopo, estudo de caso, funcionalidades, justificativas, pesquisa e requisitos).
- Links internos e referências a documentos atualizados para os novos caminhos (`docs/eap.md`, `docs/levantamento/escopo.md` e imagens dos documentos de modelagem).

### Adicionado

- Estrutura-base do projeto flutter.
- Implementação do Design System (Cores, tipografias, assets).
- Construção das telas de login nos módulos de aluno, psicólogo e responsável familiar.
