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

## 3. Requisitos de Domínio (RD)

* **RD01 – Privacidade Crítica de Dados de Menores:** O aplicativo deve tratar dados de saúde emocional de menores como críticos, sendo vedado o armazenamento centralizado que comprometa o anonimato.
* **RD02 – Validação Psicológica Oficial:** As respostas do FAQ e os conteúdos psicoeducativos devem ser formalmente validados por psicólogos ou baseados em material oficial do Ministério da Educação e UNICEF.
* **RD03 – Caráter de Acolhimento e Não Clínico:** O aplicativo atua como guia interativo de enfrentamento e apoio, servindo como ponte de acolhimento e não substituindo serviços formais de psicoterapia.
* **RD04 – Encaminhamento Prioritário de Urgência:** Em situações de sofrimento intenso relatadas ou identificadas, o fluxo de uso deve encaminhar o adolescente prontamente para canais de urgência (CVV 188, Ouvidoria, Disque 100).
* **RD05 – Discrição de Interface:** As opções de denúncia e busca de apoio devem respeitar a necessidade de discrição visual para evitar medo de exposição caso o jovem esteja em público na escola.
* **RD06 - Notificações Discretas:** Visando o anonimato, o app não deve enviar notificações com conteúdos declarativos com a temática do app e nem nada que denote o uso do mesmo.
