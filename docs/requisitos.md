# Requisitos do Sistema — MenteLeve


## 1. Requisitos Funcionais (RF)

### 1.1. Perfil do Aluno (Foco em Acolhimento, Pertencimento, Anonimato e Registro)
* **RF01 – Registro Rápido de Emoções:** O sistema deve permitir que o aluno selecione seu estado emocional através de emojis grandes, salvando o registro em até 3 interações.
* **RF02 – Diário Reflexivo e Pontos Positivos:** O sistema deve oferecer ao aluno opções de escrita reflexiva livre e ferramenta de checklist dos pontos positivos do dia.
* **RF03 – Mascote de Acolhimento:** O sistema deve apresentar um personagem interativo que interprete o humor registrado pelo aluno e exiba mensagens imediatas de acolhimento e superação.
* **RF04 – Discagem Rápida de Emergência (CVV 188):** O sistema deve manter um botão fixo para chamada telefônica ao CVV 188 que funcione sem sinal de dados/internet.
* **RF05 – Consulta ao FAQ Educativo:** O sistema deve disponibilizar perguntas e respostas acolhedoras sobre bullying, cyberbullying e saúde mental.
* **RF06 – Envio de Queixas e Denúncias Anônimas:** O sistema deve permitir que o aluno envie relatos ou denúncias à escola sem exigir login ou qualquer dado identificável.
* **RF07 – Histórico Local do Diário:** O sistema deve permitir que o aluno visualize seus registros de sentimentos anteriores diretamente no dispositivo.

### 1.2. Perfil da Psicóloga Escolar (Gestão de Conteúdo e Mediação)
* **RF08 – Autenticação Institucional:** O sistema deve permitir o login restrito para a psicóloga e equipe pedagógica através de credenciais institucionais.
* **RF09 – Publicação e Atualização de Conteúdos:** A psicóloga deve ser capaz de gerir, validar e atualizar os conteúdos de apoio e respostas do FAQ.
* **RF10 – Painel de Triagem de Denúncias e Queixas:** O sistema deve fornecer um painel para leitura e acompanhamento das denúncias e queixas anônimas submetidas pelos alunos.
* **RF11 – Resposta e Acolhimento à Queixa:** A psicóloga deve ser capaz de responder às solicitações dos estudantes prestando aconselhamento e mediação institucional.
* **RF12 - Canal de Contato com responsáveis:** O sistema deve permitir a psicóloga responder e se comunicar com os pais via canal de contato exclusivo para ambos perfis.

### 1.3. Perfil de Pais e Responsáveis (Orientação e Contato)
* **RF13 – Acesso a Conteúdos Informativos:** O sistema deve disponibilizar guias e orientações sobre sintomas, saúde mental juvenil e prevenção para os responsáveis.
* **RF14 – Canal de Comunicação com a Escola:** O sistema deve fornecer aos pais um canal direto de contato com professores e responsáveis pela saúde mental da instituição.
* **RF15 - Autenticação de Responsável:** O sistema deve permitir um login restrito para os pais, baseado em credenciais previamente cadastradas no mesmo.

---

## 2. Requisitos Não Funcionais (RNF)

* **RNF01 – Anonimato Total do Aluno:** O aplicativo não deve solicitar login, cadastro ou dados identificáveis do adolescente.
* **RNF02 – Arquitetura Offline First:** O diário de sentimentos, registro de emoções e o botão de emergência (CVV 188) devem funcionar integralmente sem sinal de internet.
* **RNF03 – Armazenamento Local de Dados Sensíveis:** Os dados do diário de sentimentos do aluno devem ser salvos exclusivamente no armazenamento local do dispositivo.
* **RNF04 – Compatibilidade de Sistema Operacional:** O sistema deve ser compatível com dispositivos móveis rodando Android 7.0 ou superior e com dispositivos IOS.
* **RNF05 – Agilidade de Navegação:** A funcionalidade central (registro de humor) deve ser realizada em até 3 interações (abrir > tocar no emoji > salvar).
* **RNF06 – Limite de Telas:** A interface principal do aplicativo deve ser enxuta, possuindo entre 4 a 8 telas.
* **RNF07 – Tamanho e Otimização do Aplicativo:** A aplicação deve manter um tamanho inicial entre 50 MB e 300 MB, utilizando animações leves que rodem fluidamente em celulares de entrada.
* **RNF08 – Identidade Visual Suave e Acolhedora:** O design deve adotar formas arredondadas, tons de azul-céu e branco, além de modo discreto/noturno adequado para uso em quartos e ambientes reservados.
* **RNF09 – Restrição de Uso da Nuvem:** O uso de serviços em nuvem (como Firebase) deve ser reservado prioritariamente para conteúdo estático.
* **RNF10 - Cadastro Backoffice de Responsáveis:** O aplicativo deve permitir o acesso via cadastro de responsáveis de forma prévia ao uso do mesmo, sendo feito diretamente no sistema e não no app.

---


## 3. CRUD (Criação, Leitura, Atualização e Exclusão de Dados)

Identificação das operações de CRUD associadas a cada requisito funcional, quando aplicável.

* **C - RF01** - Registro de emoção (emoji + data/hora)
* **C - RF02** - Entrada de diário reflexivo (texto livre) e checklist de pontos positivos do dia
* **R - RF03** - Consulta ao registro de humor mais recente, para gerar a mensagem de acolhimento do mascote
* **RF04** - Não aplicável: aciona um recurso do sistema operacional (discagem telefônica ao CVV 188), sem manipulação de dados do aplicativo
* **R - RF05** - Consulta ao conteúdo de perguntas e respostas do FAQ educativo
* **C - RF06** - Denúncia/queixa anônima enviada pelo aluno
* **R - RF07** - Consulta ao histórico local de registros do diário
* **R - RF08** - Consulta às credenciais institucionais para validação do login (não há criação/alteração de credenciais nesta funcionalidade)
* **C - RF09** - Criação de novos conteúdos de apoio e itens do FAQ
* **R - RF09** - Consulta aos conteúdos existentes para validação
* **U - RF09** - Atualização de conteúdos de apoio e respostas do FAQ já publicados
* **R - RF10** - Consulta às denúncias e queixas anônimas submetidas pelos alunos, no painel de triagem
* **C - RF11** - Registro da resposta/aconselhamento da psicóloga à queixa do aluno
* **U - RF11** - Atualização do status da queixa (ex.: de "pendente" para "respondida")
* **C - RF12** - Nova mensagem enviada no canal de contato entre psicóloga e responsáveis
* **R - RF12** - Consulta ao histórico de mensagens trocadas no canal
* **R - RF13** - Consulta aos guias e orientações informativas disponibilizados aos responsáveis
* **C - RF14** - Nova mensagem enviada no canal de comunicação entre pais e escola
* **R - RF14** - Consulta ao histórico de mensagens do canal com a escola
* **R - RF15** - Consulta às credenciais previamente cadastradas para validação do login do responsável

---

## 4. Priorização de Funcionalidades

Classificação dos requisitos funcionais de acordo com sua relevância para a proposta principal do MenteLeve: acolher o adolescente de forma anônima e conectá-lo rapidamente a ajuda em momentos de sofrimento.

### 4.1. Essenciais — indispensáveis para a proposta principal

* **RF01 – Registro Rápido de Emoções:** é a funcionalidade central do app, citada nas restrições do estudo de caso (até 3 interações) e na navegação principal.
* **RF02 – Diário Reflexivo e Pontos Positivos:** compõe, junto ao RF01, o Diário de Sentimentos — um dos quatro pilares descritos na proposta do app.
* **RF03 – Mascote de Acolhimento:** entrega o acolhimento imediato prometido pela proposta de valor, transformando o registro em resposta empática.
* **RF04 – Discagem Rápida de Emergência (CVV 188):** garante o acesso à ajuda em situações de sofrimento intenso, mesmo offline; é um requisito de segurança inegociável.
* **RF05 – Consulta ao FAQ Educativo:** um dos recursos citados desde a descrição do projeto para combater a falta de informação sobre bullying/saúde mental.
* **RF06 – Envio de Queixas e Denúncias Anônimas:** representa os "canais de denúncia", também citados na descrição do app como pilar da proposta.

### 4.2. Importantes — agregam valor, mas não são fundamentais

* **RF07 – Histórico Local do Diário:** enriquece a experiência (permite reler pontos positivos), mas o app cumpriria seu propósito imediato de acolhimento mesmo sem consulta ao histórico.
* **RF08 – Autenticação Institucional:** necessária para viabilizar a gestão de conteúdo e a triagem de denúncias pela escola, mas é suporte de backoffice, não parte da experiência do aluno.
* **RF09 – Publicação e Atualização de Conteúdos:** mantém FAQ e mensagens de acolhimento atualizados e validados, mas o app pode operar inicialmente com um conteúdo estático fixo.
* **RF10 – Painel de Triagem de Denúncias e Queixas:** fecha o ciclo do RF06 permitindo acompanhamento institucional, mas a denúncia em si (RF06) já cumpre a função essencial de dar vazão ao relato do aluno.
* **RF11 – Resposta e Acolhimento à Queixa:** complementa o RF10 com retorno ativo da psicóloga, agregando valor à rede de apoio sem ser indispensável ao MVP do aluno.

### 4.3. Secundárias — podem ser desenvolvidas posteriormente

* **RF12 – Canal de Contato com Responsáveis:** funcionalidade voltada à rede de apoio complementar (psicóloga ↔ pais), citada no estudo de caso como suporte adicional, não como núcleo da proposta.
* **RF13 – Acesso a Conteúdos Informativos (pais):** valor educativo para responsáveis, mas não afeta a experiência de acolhimento imediato do adolescente.
* **RF14 – Canal de Comunicação com a Escola (pais):** amplia a rede de apoio, porém depende de adoção institucional e pode ser incorporada em uma fase posterior.
* **RF15 – Autenticação de Responsável:** só é necessária para viabilizar RF12–RF14; sem essas funcionalidades secundárias, o login de responsáveis não tem uso imediato.
