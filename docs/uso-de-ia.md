# Registro de Uso de Inteligência Artificial — MenteLeve

## 1. Contexto e Abordagem

O uso de Inteligência Artificial Generativa no projeto vem sendo adotado como ferramenta de apoio técnico para acelerar tarefas operacionais de engenharia e planejamento, servindo como suporte nas tomadas de decisão e na escrita de scripts auxiliares.

Até o presente momento, o trabalho esteve concentrado na **estruturação do backlog ágil, integração com o Jira Cloud e planejamento das entregas**. Nenhum código do aplicativo móvel foi implementado ainda nesta etapa.

---

## 2. Atividades em que a IA foi Utilizada

### 2.1. Planejamento Ágil e Divisão do Backlog
- Auxílio na divisão do projeto em Épicos temáticos e decomposição em Stories e Tasks.
- Apoio na formulação de Critérios de Aceite para cada tarefa.
- Estruturação do calendário e da distribuição de carga de trabalho entre as 4 sprints planejadas.

### 2.2. Automação e Integração com a API do Jira
- Desenvolvimento de scripts em Python para automatizar a criação em lote das tarefas e épicos na API do Jira Cloud.
- Montagem da estrutura de dados em *Atlassian Document Format* (ADF) para formatação de texto das descrições.
- Criação de rotinas para vinculação hierárquica (tarefas filhas conectadas aos seus respectivos épicos pais) e alocação de tarefas dentro de cada Sprint.

---

## 3. Prompts Utilizados

### Prompt 1: Estruturação de Script para API do Jira
> *"Crie um script em Python que conecte à API do Jira Cloud para cadastrar épicos e tarefas no projeto SCRUM."*

### Prompt 2: Organização e Escopo das Sprints
> *"Com base nas funcionalidades do projeto MenteLeve, estruture uma proposta de calendário de 4 sprints de desenvolvimento, organizando o que deve ser prioridade inicial até as fases finais, distribuindo o backlog de forma equilibrada."*

---

## 4. Problemas Encontrados na IA e Correções Realizadas

Durante o desenvolvimento das automações e configurações com o Jira, a IA gerou respostas com erros técnicos que precisaram ser identificados e corrigidos manualmente:

### 1. Seleção Incorreta do Campo de Story Points
* **O problema:** A IA sugeriu utilizar o campo `customfield_10026` para estimativas, baseando-se em uma busca por aproximação. A API do Jira rejeitou as requisições com erro `HTTP 400`, pois esse campo correspondia a outro tipo de dado da instância.
* **A solução:** Foi feita uma consulta aos metadados de campos da API (`/rest/api/3/field`), identificando que o campo real de estimativa era o `customfield_10016` (*Story point estimate*). O script foi corrigido para apontar para o identificador correto.

### 2. Limite de Caracteres no Nome das Sprints
* **O problema:** Ao tentar criar sprints com títulos longos descritivos sugeridos pela IA, a API do Jira retornou erro informando que o nome da sprint deve ter menos de 30 caracteres.
* **A solução:** Os nomes das sprints foram simplificados para um padrão conciso (ex.: `Sprint 1 (01/11 - 08/11)`), e as informações descritivas foram transferidas para o campo de metas (*goal*).

### 3. Falha de Encoding de Caracteres Acentuados no Windows
* **O problema:** Em rotinas de leitura e manipulação de textos gerados pela API, o uso padrão de `json.dumps()` transformou caracteres acentuados da língua portuguesa (como `Responsável` e `Épico`) em sequências de escape Unicode (`\u00e1`), fazendo com que verificações condicionais falhassem silenciosamente.
* **A solução:** Foi adicionado o parâmetro `ensure_ascii=False` na serialização e ajustado o encoding do ambiente para UTF-8.

### 4. Conflito entre Campos de Vínculo Hierárquico
* **O problema:** A IA tentou enviar simultaneamente o campo moderno `parent` e o campo legado `customfield_10014` (*Epic Link*), gerando redundância e avisos de campo inválido na API.
* **A solução:** A estrutura do payload foi ajustada para utilizar exclusivamente o campo `parent`, que é o padrão suportado para projetos no Jira Cloud.

---