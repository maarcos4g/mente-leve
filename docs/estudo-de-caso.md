# Análise do Estudo de Caso — MenteLeve
## 1. Objetivo 

Desenvolver um aplicativo móvel destinado a acolher adolescentes de 10 a 17 anos que enfrentam bullying, cyberbullying ou baixa autoestima, que acabam gerando quadros de ansiedade e depressão e que raramente são reveladas, já que o medo de ser exposto impede o adolescente de pedir ajuda. A solução tem como usuário central o adolescente em sofrimento e conta, de forma complementar, com professores, psicólogos escolares e responsáveis como rede de prevenção e apoio para os usuários. O aplicativo é pensado para ser utilizado em momentos de crises, muitas vezes a noite e em ambientes reservados como quartos, escolas e banheiros, por um usuário que esteja emocionalmente fragilizado, buscando acolher o sofrimento de forma imediata, simples e livre de julgamento, por meio de um personagem de acolhimento que interpreta o humor registrado pelo adolescente e lhe responde com mensagens positivas e de superação, e ao mesmo tempo servir de ponte para canais de denuncia e ajuda profissional, encaminhando o usuário para ao CVV 188, número ou chat de um responsável da escola sempre que os registro indicarem que o usuário esteja passando por um sofrimento intenso ou porque ele sentiu que precisava pedir ajuda. Para cumprir esse propósito com responsabilidade, a solução preserva o anonimato total de usuário, sem login e com o diário de sentimentos armazenado localmente, reservando o Firebase apenas a conteúdo estático, que funciona em contexto offline, garante o acesso à emergência, mesmo sem sinal de dados, limita-se até quatro telas principais e três interações na função central e mantém compatibilidade com Android 7.0 ou superior. Essas diretrizes irão se materializar em um diário de sentimentos baseado em emojis grandes e acompanhado de um personagem que transforma o registro em acolhimento, um FAQ empático sobre bullying, uma lista de canais de denuncia e um botão fixo de discagem para o CVV 188, tudo revestido por uma identidade suave, que demonstre proteção e transpareça confiança. 

## 2. O que o grupo deverá fazer 
O grupo deverá analisar o estudo de caso fornecido e produzir uma síntese crítica do projeto. 

## 2.1. Problema

O aplicativo pretende ajudar a solucionar a falta de comunicação entre jovens e responsáveis em situações relacionadas a **bullying, cyberbullying e problemas recorrentes de saúde mental**. A proposta é oferecer rotinas, guias, práticas e FAQs baseados em exercícios validados por psiquiatras e psicólogos.

Esse problema é relevante porque muitos adolescentes enfrentam situações de sofrimento emocional, mas têm medo de se expor ou não se sentem confortáveis para conversar com outras pessoas. As diversas circunstâncias do ambiente escolar podem fazer com que os jovens tenham dificuldade para se abrir e pedir ajuda.

Além disso, a saúde mental é uma pauta cada vez mais presente na sociedade. Oferecer um espaço seguro e discreto pode representar uma forma de demonstrar cuidado e apoio por parte dos pais e das instituições de ensino.

A principal necessidade que a solução deverá atender é funcionar como um **refúgio seguro para que o adolescente possa compartilhar seus problemas**, além de fornecer alternativas para situações relacionadas a transtornos mentais e às dificuldades do cotidiano estudantil. O aplicativo também deverá funcionar como uma porta de entrada para o cuidado com a saúde mental e para a conscientização sobre sua importância.

## 2.2. Público e usuários

### Adolescentes e pré-adolescentes — 10 a 17 anos

- São os principais usuários do aplicativo, em sua maioria estudantes. Essa faixa etária pode apresentar dificuldade para falar sobre situações de bullying, cyberbullying e problemas emocionais.

- O aplicativo deverá servir como uma ponte entre os estudantes que buscam ajuda, seus responsáveis e as pessoas competentes da instituição de ensino.

- Os adolescentes poderão utilizar a solução diariamente para registrar seus sentimentos, reportar situações de bullying e cyberbullying e buscar informações ou apoio durante momentos difíceis.

### Professores e orientadores

Possuem relação com o aplicativo como parte da rede de prevenção e apoio aos estudantes. Podem utilizar a solução para acompanhar situações relacionadas ao ambiente escolar e oferecer suporte aos alunos.

Também podem contribuir para a conscientização da comunidade estudantil sobre saúde mental.

### Psicólogos escolares

Atuam como profissionais de apoio dentro da rede relacionada ao aplicativo. Sua participação está relacionada ao suporte aos estudantes e à validação de conteúdos e práticas voltados à saúde mental.

### Pais e responsáveis

Fazem parte da rede de apoio do estudante. O aplicativo busca aproximá-los da situação dos alunos e fornecer informações sobre possíveis sintomas e formas de lidar com situações relacionadas à saúde mental.

## 2.3. Contexto de uso

O aplicativo será utilizado principalmente no ambiente escolar, mas poderá ser acessado em qualquer momento e local, incluindo **quartos, banheiros e ambientes abertos**.

O principal contexto de utilização envolve usuários em condições de vulnerabilidade emocional, especialmente durante momentos de fragilidade ou sofrimento.

### Características do contexto

* **Ambiente:** escola, quarto, banheiro e ambientes abertos.
* **Momento de utilização:** principalmente durante a rotina escolar, mas podendo ocorrer a qualquer momento.
* **Condição do usuário:** situação de vulnerabilidade ou sofrimento emocional.
* **Dispositivo:** celular.
* **Conectividade:** funcionamento offline para o diário e acesso ao CVV; conteúdo de FAQ validado por psicólogos pode utilizar conexão online.
* **Iluminação:** o aplicativo pode ser utilizado sob alta iluminação solar.
* **Nível de atenção:** baixo, considerando que o usuário pode estar emocionalmente fragilizado.
* **Situação de urgência:** pode ser utilizado em momentos de sofrimento ou fragilidade.

Essas condições influenciam diretamente o desenvolvimento do aplicativo. A interface precisa ser simples, discreta e rápida de utilizar, permitindo que o usuário consiga registrar seus sentimentos com poucas interações.

A necessidade de funcionamento offline também é importante, pois o usuário deve conseguir acessar recursos essenciais mesmo sem conexão de dados. O aplicativo deve ainda apresentar uma experiência acolhedora e sem julgamentos.

## 2.4. Objetivo e proposta de valor

O **MenteLeve** pretende ser um portal estudantil voltado à conscientização e ao suporte de estudantes e pais, além de auxiliar os profissionais da escola.

Seu principal objetivo é aproximar os alunos de uma rede de apoio e atuar como um pilar de sustentação relacionado à saúde mental. A solução também busca informar os responsáveis sobre possíveis sintomas e formas de lidar com essas situações.

Um dos principais benefícios é permitir que o estudante busque apoio **sem precisar se expor diretamente**, proporcionando um ambiente confortável e seguro.

O aplicativo também incentiva a prática de hábitos saudáveis relacionados à saúde mental e busca contribuir para que os estudantes se sintam mais seguros durante sua jornada acadêmica e em seu cotidiano.

## 2.5. Personalidade, identidade e experiência

A identidade do aplicativo está relacionada aos conceitos de:

- Bullying;
- Cyberbullying;
- Autoestima;
- Ansiedade;
- Depressão juvenil;
- Escuta ativa;
- CVV;
- Rede de apoio;
- Denúncia escolar.

A personalidade da solução deverá ser **suave, acolhedora e protetora**. A interface deve utilizar cores claras, como azul-céu e branco, além de formas arredondadas.

A experiência deve transmitir uma sensação de calma e empatia, sem julgamentos. O aplicativo deve proporcionar ao usuário a sensação de estar em um ambiente seguro e acolhedor.

A solução deverá ser lembrada principalmente como um aplicativo **discreto e acolhedor**, capaz de oferecer apoio sem aumentar a sensação de exposição do adolescente.

## 2.6. Funcionalidades e características já definidas

### Diário de sentimentos

Permite que o usuário registre seus sentimentos diariamente por meio de emojis e textos.

**Necessidade atendida:** oferece um espaço privado para o adolescente expressar seus sentimentos sem precisar conversar diretamente com outra pessoa.

### Respostas de acolhimento

O personagem de acolhimento interpreta o humor registrado pelo adolescente e apresenta mensagens positivas e de superação.

**Necessidade atendida:** proporciona acolhimento imediato e uma experiência empática e sem julgamentos.

### Canais de denúncia

Disponibiliza informações e caminhos para realizar denúncias relacionadas a bullying e cyberbullying.

**Necessidade atendida:** facilita o acesso às informações necessárias para buscar ajuda em situações de violência ou assédio.

### Rede de apoio

Funciona como uma ponte entre o estudante, a escola, os profissionais responsáveis e os pais.

**Necessidade atendida:** aproxima o adolescente das pessoas que podem oferecer suporte quando ele precisar de ajuda.

### FAQ sobre bullying e saúde mental

Apresenta informações e orientações relacionadas aos problemas enfrentados pelos estudantes.

**Necessidade atendida:** combate a falta de informação e ajuda o usuário a compreender melhor situações relacionadas à saúde mental e ao bullying.

### Acesso ao CVV 188

Disponibiliza um botão fixo para acesso ao CVV 188.

**Necessidade atendida:** permite acesso rápido a um canal de apoio em situações de sofrimento intenso ou quando o usuário sentir necessidade de pedir ajuda.

### Funcionamento offline

Permite que recursos essenciais, como o diário e o acesso à emergência, continuem disponíveis sem conexão de dados.

**Necessidade atendida:** garante acesso às funcionalidades essenciais mesmo em situações de pouca ou nenhuma conectividade.

## 2.7. Restrições e condições

O desenvolvimento deverá respeitar as seguintes restrições:

| Restrição                 | Condição                                                                      |
| ------------------------- | ----------------------------------------------------------------------------- |
| **Quantidade de telas**   | Aproximadamente 5 a 8 telas                                                   |
| **Interações**            | Até 3 interações na funcionalidade principal e menos de 10 no total           |
| **Dispositivos**          | Smartphones compatíveis com Android 7.0 ou superior                           |
| **Sistema operacional**   | Android 7.0 ou superior                                                       |
| **Tamanho do aplicativo** | Previsão inicial entre 50 e 300 MB, podendo aumentar devido a cache e memória |
| **Privacidade**           | Anonimato total do usuário e interface discreta                               |
| **Armazenamento**         | Offline First                                                                 |
| **Conectividade**         | Pouca dependência de conexão, priorizando o funcionamento offline             |
| **Navegação**             | Abrir → tocar no emoji ou digitar algo → salvar                               |
| **Acessibilidade**        | Tons claros, sensação de acolhimento e proteção e elementos arredondados      |
| **Ambiente**              | Escola, banheiro, quarto ou ambientes abertos                                 |

Essas restrições tornam necessário priorizar uma interface objetiva e com poucas etapas. Como o usuário pode estar em uma situação de vulnerabilidade, a navegação não deve exigir muitas ações para acessar os recursos principais.

A privacidade também é um aspecto fundamental, já que o estudo de caso estabelece o anonimato total do usuário. O armazenamento local do diário contribui para essa característica.

## 2.8. Pontos de atenção

Os três aspectos considerados mais importantes para o sucesso do aplicativo são:

### 1. Descrição

A discrição é essencial porque muitos adolescentes têm medo de serem expostos ao buscar ajuda. O aplicativo precisa permitir que o usuário registre seus sentimentos e procure informações sem chamar atenção ou revelar desnecessariamente sua situação.

### 2. Acolhimento

O aplicativo deve transmitir uma experiência empática, calma e livre de julgamentos. Como o usuário poderá acessar a solução em momentos de sofrimento, a interface e as respostas precisam transmitir segurança e conforto.

### 3. Acesso à ajuda

O aplicativo não deve se limitar ao registro dos sentimentos. É importante que ele funcione como uma ponte para canais de denúncia, responsáveis da escola, profissionais de apoio e o CVV 188.

Dessa forma, quando o usuário estiver enfrentando uma situação mais grave ou sentir necessidade de ajuda, deverá conseguir encontrar rapidamente um caminho para buscar suporte.


### 4. Relação com o estudo de caso 

  A nossa análise chegou a conclusão de que o MenteLeve deve ser um app como seu nome, leve. O aplicativo deve conter uma forma de comunicação opcionalmente anônima e segura para alunos com responsáveis da saúde mental na instituição, o requisito de não login expositivo para os alunos motivou a tomada de decisão para que apenas professores tivessem login institucional, mas levantou uma dúvida quanto a distribuição do app. Os servições de hotline e emergência deverão permacer disponíveis para o modo offline, assim como o diário, que não será armazenado pelo servidor do app. O diário deve ter diferentes modos, escrita livre, pontos positivos do dia. Visando engajar e manter a usabilidade do app e uma espécie de “Tratamento constante”, O grupo também entrou em consenso para criação de um mascote, o mesmo sendo interativo e representando a usabilidade do app de forma não sufucante, como uma alternativa às não notificação como requisitos. O design deve ser amigável e com uma atmosfera aconchegante, para isso decidimos o uso de cores suaves e tonalidades que reforcem conforto azul-céu e branco.  
