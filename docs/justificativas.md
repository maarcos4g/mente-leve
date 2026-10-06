# Justificativas de Design — MenteLeve

## 1. Cores

### Paleta adotada

| Papel                         | Token Figma          | Hex       |
|-------------------------------|----------------------|-----------|
| Primária (fundo principal)    | `colors/sky/500`     | `#00A6F4` |
| Primária variante clara       | `colors/sky/400`     | `#00BCFF` |
| Botão de ação principal       | `colors/sky/600`     | `#0084D1` |
| Texto em botão light          | `colors/sky/700`     | `#0069A8` |
| Superfície / painel claro     | `colors/zinc/50`     | `#FAFAFA` |
| Fundo de cards secundários    | `colors/zinc/100`    | `#F4F4F5` |
| Borda de inputs               | `colors/zinc/400`    | `#9F9FA9` |
| Placeholder / texto leve      | `colors/zinc/500`    | `#71717B` |
| Texto de seção (home)         | `colors/zinc/950`    | `#09090B` |
| Destaque rosa (logo/acento)   | —                    | `#FDADC1` |
| Card de humor (home)          | `colors/slate/600`   | `#45556C` |
| Elementos estruturais escuros | —                    | `#263238` |

### Justificativa

A paleta foi estruturada em torno do **azul-céu (`#00A6F4`)** como cor primária, apoiada por variantes mais claras e escuras da mesma matiz para criar profundidade e hierarquia visual. O azul foi escolhido por duas razões principais:

1. **Psicologia das cores:** Tons de azul estão associados a calma, confiança e segurança. Para um público de adolescentes emocionalmente vulneráveis, essa escolha reforça a proposta central do app de ser um ambiente acolhedor e livre de julgamentos.

2. **Contraste e acessibilidade:** A combinação do azul primário com o branco-gelo (`#FAFAFA`) como superfície garante contraste suficiente para leitura confortável em múltiplos ambientes de uso (escolas, ambientes externos, quartos à noite), atendendo ao contexto mapeado no estudo de caso.

O **rosa `#FDADC1`** foi utilizado como acento no logotipo (segundo círculo da marca) e em elementos decorativos das ilustrações, criando um toque afetivo e diferenciador sem concorrer com a hierarquia da cor primária. Essa cor remete a acolhimento e cuidado, reforçando o tom emocional do app.

A escolha de **`#FAFAFA`** (e não branco puro `#FFFFFF`) para os painéis e superfícies reduz o contraste agressivo, entregando uma experiência visual mais suave e confortável, especialmente em uso prolongado ou em ambientes com iluminação reduzida.

---

## 2. Tipografia

### Fontes adotadas

| Papel                    | Família     | Peso       | Tamanho |
|--------------------------|-------------|------------|---------|
| Logotipo / marca         | `Noto Sans` | SemiBold (600) | 24sp |
| Títulos de tela          | `Poppins`   | SemiBold (600) | 24sp |
| Subtítulos / labels      | `Poppins`   | Medium (500)   | 14sp |
| Corpo de texto / FAQ     | `Poppins`   | Light (275)    | 16sp |
| Rótulos de botão         | `Poppins`   | SemiBold (600) | 16sp |
| Placeholder de input     | `Poppins`   | Regular (400)  | 14sp |

### Justificativa

**Poppins** foi adotada como fonte principal da interface por ser uma sans-serif geométrica com formas arredondadas e características humanistas, transmitindo ao mesmo tempo **modernidade e acolhimento** — valores centrais da identidade do MenteLeve. Sua ampla gama de pesos (Light 275 até SemiBold 600) permite criar uma hierarquia tipográfica clara sem precisar recorrer a uma segunda família.

**Noto Sans** foi usada exclusivamente no logotipo por sua neutralidade e legibilidade em qualquer tamanho, garantindo que a marca seja reconhecível mesmo em dimensões reduzidas (ex.: dentro do cabeçalho das telas).

A utilização do peso **Light (275)** para textos de corpo e descrições mais longas (como os subtítulos de onboarding) contribui para uma leitura leve e não intimidante, alinhada ao perfil emocional do usuário. O contraste entre o Light do corpo e o SemiBold dos botões e títulos orienta o olhar do usuário com clareza, reduzindo o esforço cognitivo em momentos de vulnerabilidade emocional.

O tamanho mínimo de 14sp para inputs e rótulos garante **legibilidade em celulares de entrada**, e o contraste entre texto e fundo respeita as diretrizes de acessibilidade WCAG AA.

---

## 3. Organização das Informações

### Estrutura adotada

O app foi organizado em até **5 a 8 telas principais** (conforme restrição RNF06), com uma navegação por abas na parte inferior:

| Aba             | Funcionalidade principal                   |
|-----------------|---------------------------------------------|
| Início / Diário | Registro de humor com emojis (RF01)         |
| Escrever        | Diário reflexivo e pontos positivos (RF02)  |
| Ajuda           | FAQ e canais de denúncia (RF03 / RF04)      |
| Emergência      | Botão CVV e contatos de apoio (RF05)        |

### Justificativa

A organização das informações priorizou a **funcionalidade central na tela de abertura** (registro de humor via emojis), de modo que o usuário possa completar a ação principal em até 3 interações: abrir o app → tocar no emoji → salvar. Isso atende diretamente à restrição RNF05 e ao padrão de comportamento da persona Lucas, que usa o app de forma rápida e discreta.

A separação em abas garante que funcionalidades secundárias (FAQ, canais de denúncia) não poluam a tela principal, mantendo a interface enxuta e evitando sobrecarga cognitiva para um usuário em estado de vulnerabilidade emocional.

---

## 4. Navegação e Fluxo

### Telas identificadas no protótipo

| Tela           | Descrição                                                                             |
|----------------|---------------------------------------------------------------------------------------|
| `onboarding`   | Tela de entrada com ilustração, tagline e CTA principal do aluno                      |
| `multi-login`  | Bottom sheet para seleção de perfil institucional                                     |
| `auth (aluno)` | Escolha de codinome anônimo (ex.: "Panda"), sem e-mail ou senha                       |
| `psychologist` | Login com e-mail institucional e senha para psicólogos e equipe pedagógica            |
| `parents`      | Login com número de identificação e senha fornecida pela escola para responsáveis     |
| `home`         | Tela principal do aluno: saudação, seletor de humor, resumo semanal e botão CVV       |

### Fluxos de navegação

**Fluxo do Aluno:**
```
Onboarding → [Entrar como aluno] → Auth (codinome) → Home (tela principal)
```

**Fluxo Institucional (Psicóloga / Equipe pedagógica):**
```
Onboarding → [Acessar com outro tipo de perfil] → Bottom sheet (multi-login)
    └── [Gestão Educacional] → Login (e-mail + senha) → Painel institucional
```

**Fluxo Responsável:**
```
Onboarding → [Acessar com outro tipo de perfil] → Bottom sheet (multi-login)
    └── [Responsável] → Login (número de ID + senha da escola) → Painel
```

### Decisões de navegação

- **Separação de perfis na entrada:** A tela de onboarding apresenta apenas o acesso do aluno como CTA principal (botão em destaque), com o acesso institucional como link secundário ("Acessar com outro tipo de perfil"). Isso reduz a fricção para o usuário central (o adolescente) e evita que ele precise interpretar opções de perfis no primeiro contato com o app.

- **Bottom sheet para multi-login:** O seletor de perfil institucional foi implementado como um **modal deslizante (bottom sheet)** em vez de uma tela separada, pois é um passo transitório e não merece uma tela dedicada. O padrão bottom sheet é familiar no Android e mantém o usuário contextualizado na tela de onboarding.

- **Codinome no lugar de login para o aluno:** A tela de autenticação do aluno não solicita e-mail, senha ou qualquer dado identificável. O usuário apenas escolhe um **codinome** (ex.: "Panda") que é salvo localmente, atendendo ao requisito de anonimato total (RNF01) e criando um vínculo leve com o app sem exposição.

- **Credenciais diferenciadas por perfil:** O login do psicólogo usa e-mail institucional + senha; o do responsável usa número de identificação + senha fornecida pela escola. Essa diferença elimina o cadastro manual pelo usuário e garante que só pessoas autorizadas pela instituição acessem os painéis.

- **Botão CVV 188 persistente na home:** O botão "Ajuda (CVV)" é um pill button fixo no canto inferior direito da `home` (`border-radius: 32px`, cor `#00A6F4`), acionável com 1 toque, sem depender de navegação (requisito RF03 / RF05).

- **Profundidade máxima de 2 níveis:** Nenhuma funcionalidade essencial está a mais de 2 cliques da tela inicial, reduzindo o risco de o usuário se perder com atenção reduzida.

---

## 5. Componentes de UI

### Componentes principais utilizados

| Componente                  | Onde é usado                             | Justificativa                                                                          |
|-----------------------------|------------------------------------------|----------------------------------------------------------------------------------------|
| Seletor de humor (cérebros) | Home — "Como está sua mente hoje?"       | 5 ícones de cérebro com glow colorido expressam emoções sem exigir leitura            |
| Card de humor (`#45556C`)   | Home — prompt de registro                | Fundo slate/600 destaca a ação principal sobre o header azul                           |
| Pill button CVV             | Home — canto inferior direito            | Compacto e persistente (`border-radius: 32px`, `#00A6F4`) com ícone de telefone        |
| Card FAQ (`#F4F4F5` + borda)| Home — prévia do FAQ                     | Fundo zinc/100 com borda sky/700 diferencia conteúdo informativo do interativo         |
| Codinome + avatar panda     | Auth (aluno)                             | Identidade leve e anônima; reforça o vínculo emocional sem dados pessoais              |
| Bottom sheet                | Multi-login                              | Modal transitório evita tela dedicada e mantém o usuário contextualizado               |
| Input com ícone (lucide)    | Auth, Psychologist, Parents              | Ícone identifica visualmente o tipo de dado esperado (e-mail, senha, ID)               |
| Cartões arredondados        | FAQ, pontos positivos, canais            | `border-radius: 16px` reforça a identidade visual acolhedora                           |
| Text Field (codinome)       | Auth (aluno)                             | Input mínimo com placeholder "Ex: Panda", sem campos obrigatórios pesados              |

### Justificativa geral

A seleção de componentes priorizou **elementos compatíveis com Material Design** (padrão Android) para garantir familiaridade imediata com o público-alvo. O seletor de humor usa **ícones de cérebro com glows coloridos** em vez de emojis convencionais, criando uma linguagem visual própria do MenteLeve que é simultaneamente expressiva e discreta (sem emojis de rosto que possam ser reconhecidos por terceiros ao olharem a tela).

O mascote panda cumpre dois papéis: (1) representar o codinome do aluno de forma lúdica e não identificável, e (2) substituir notificações push que poderiam expor o usuário. Sua presença tanto na tela de auth quanto na home reforça a continuidade da identidade do usuário ao longo da sessão.



### Funcionalidade descontinuada — Pet interativo

Durante o processo de ideação, o grupo planejou um **pet virtual interativo** como elemento central de engajamento do adolescente com o app. A proposta ia além do mascote estático: o pet teria estados visuais dinâmicos (feliz, triste, cansado, animado) que refletiriam o humor acumulado registrado pelo usuário no diário de sentimentos, criando um vínculo emocional progressivo e incentivando o uso contínuo do app sem a necessidade de notificações.

**Conceito original:**
- O pet reagiria aos emojis registrados no diário, exibindo animações correspondentes ao estado emocional do usuário.
- Registros positivos consecutivos fariam o pet evoluir visualmente (crescer, ganhar acessórios), funcionando como um sistema leve de recompensa.
- Em registros de sofrimento intenso, o pet exibiria uma animação de acolhimento e acionaria o encaminhamento ao CVV 188 ou ao canal de denúncia.

**Motivo da descontinuação:** A funcionalidade foi descontinuada por **restrições de prazo** na entrega da Unidade I. O desenvolvimento das animações e da lógica de estado do pet demandaria tempo de implementação incompatível com o cronograma disponível.

---

## 6. Acessibilidade

### Medidas adotadas

- **Tamanho mínimo de área de toque:** 48×48dp em todos os botões e emojis, seguindo a diretriz do Material Design.
- **Contraste de cor:** relação mínima de 4.5:1 entre texto e fundo (WCAG AA) tanto no modo claro quanto no modo noturno.
- **Tamanho mínimo de fonte:** 14sp para texto de corpo, com suporte ao redimensionamento de fonte do sistema operacional (`sp` em vez de `dp`).
- **Modo noturno:** reduz o brilho da tela em ambientes escuros, protegendo a visão e a discrição do usuário.
- **Emojis como linguagem universal:** permitem que usuários com dificuldade de expressão verbal ou escrita comuniquem seu estado emocional de forma eficaz.
- **Sem necessidade de leitura longa para funcionalidade principal:** o registro de humor pode ser feito inteiramente sem leitura de texto.

### Justificativa

O público-alvo inclui adolescentes de 10 a 17 anos, podendo abranger usuários com dificuldades de leitura, atenção reduzida por estado emocional ou limitações de hardware (celulares de entrada com telas menores). As medidas de acessibilidade foram pensadas para garantir que **nenhuma barreira técnica ou sensorial impeça o acesso ao app em um momento de necessidade**.

O suporte ao redimensionamento de fonte (`sp`) garante que usuários que configuraram fontes maiores no sistema não tenham a interface quebrada.

---

## 7. Contexto de Uso

O MenteLeve foi projetado para ser utilizado em **condições extremas de uso**: pouca luz, atenção reduzida, dispositivos de entrada, conexão instável e necessidade de discrição. As principais decisões de design que respondem a esse contexto são:

| Condição de uso                    | Decisão de design correspondente                                          |
|------------------------------------|---------------------------------------------------------------------------|
| Uso em ambiente escuro (quarto)    | Modo noturno com fundo escuro e baixo brilho                             |
| Uso discreto (banheiro, escola)    | Interface limpa, sem logotipos chamativos, sem notificações visíveis      |
| Atenção reduzida / fragilidade     | Máximo 3 interações para função principal, sem texto excessivo na home    |
| Conexão instável / offline         | Diário e CVV funcionam 100% offline; Firebase só para conteúdo estático   |
| Celular de entrada (Android 7.0+)  | Animações leves, app entre 50–300 MB, sem dependência de GPU avançada    |
| Uso com uma mão                    | Elementos interativos na metade inferior da tela, FAB acessível           |

---

## 8. Arquitetura do Sistema

### Arquitetura adotada

O MenteLeve adota uma arquitetura em camadas com separação entre **apresentação**, **lógica de negócio** e **dados**, seguindo os princípios do **MVVM (Model-View-ViewModel)** adaptado para o contexto mobile Android.

### Componentes principais

```
┌─────────────────────────────────────────────┐
│               UI / View                      │
│   (Telas: Diário, FAQ, Ajuda, Emergência)    │
└───────────────────┬─────────────────────────┘
                    │
┌───────────────────▼─────────────────────────┐
│             ViewModel / Controller           │
│  (Lógica de estado, regras de navegação)     │
└───────────────────┬─────────────────────────┘
                    │
       ┌────────────┴────────────┐
       │                         │
┌──────▼──────┐         ┌────────▼────────┐
│ Local DB    │         │   Firebase      │
│ (SQLite /   │         │ (Conteúdo FAQ,  │
│  Room)      │         │  denúncias)     │
│ Diário,     │         │  — somente      │
│ histórico   │         │  quando online  │
└─────────────┘         └─────────────────┘
```

### Justificativa

A separação entre UI e lógica de negócio facilita a **manutenção e testabilidade** do código, além de permitir que diferentes membros da equipe trabalhem em camadas distintas sem conflito.

A divisão entre **armazenamento local (Room/SQLite)** e **Firebase** responde diretamente às restrições do projeto:

- **Room (local):** garante o funcionamento offline do diário de sentimentos e o anonimato total do aluno, já que os dados nunca saem do dispositivo (RNF01, RNF02, RNF03).
- **Firebase:** utilizado apenas para conteúdo estático — respostas do FAQ, mensagens do mascote e denúncias anônimas — conforme a restrição RNF09. A sincronização ocorre apenas quando há conexão disponível.

Essa arquitetura é compatível com o **Android 7.0+** (RNF04) e permite que o app opere dentro do limite de 50–300 MB (RNF07), sem dependência de processamento pesado no cliente.
