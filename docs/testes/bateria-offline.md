# Bateria de testes de falha de conexão (modo avião / offline)

**Épico:** EPIC-09 · **Estimativa:** 3 SP · **Data da execução:** 21/11/2026

**Definition of Done:** o diário e o botão CVV funcionam sem travar em modo offline, e a reconexão sincroniza os dados pendentes.

## O que fica pendente de sincronização

| Recurso | Onde os dados ficam | Sem internet | Na reconexão |
|---|---|---|---|
| Diário de sentimentos e Diário Pessoal | Só no aparelho (`SharedPreferences`, chave `diario`), por decisão de privacidade (RNF03) | Lê e grava normalmente | Nada a sincronizar: o diário nunca vai para a nuvem |
| Botão CVV 188 | Discador do aparelho (`tel:188`) | Abre o discador normalmente | Não usa a internet |
| Entrada do aluno | Sessão local (`profile_local_uid`) | Entra com id local (PR #25) | O login anônimo do Firebase acontece na próxima abertura do app |
| FAQ do aluno | Firestore + cache local (`faq_cache`) | Mostra o cache ou as perguntas padrão | Na próxima abertura, a lista vem do servidor e atualiza o cache |
| Painel de FAQ da psicóloga | Firestore (fila offline do próprio Firestore) + cache local | Criar, editar e excluir terminam em até ~3 s e aparecem na lista | A fila do Firestore envia as escritas ao servidor sozinha |

## Problema encontrado e corrigido

Sem internet, o Firestore guarda a escrita numa fila local e só confirma quando a conexão volta. O `FirestoreFaqRepository` esperava essa confirmação, então **salvar ou excluir uma pergunta no painel da psicóloga deixava o botão em "Salvando…" até a internet voltar**.

A correção está em `lib/shared/faq/faq_repository.dart`:

- A escrita é esperada por no máximo 2 s (`writeWait`). Online a confirmação chega antes, e erros como falta de permissão continuam tratados. Offline, a tela segue em frente e a escrita fica na fila do Firestore.
- A leitura da lista tem limite de 6 s (`readWait`). Logo depois de uma escrita sem resposta, o limite cai para 1 s (`offlineReadWait`), porque o aparelho está quase certamente sem rede.

No emulador, salvar offline levava de 5 a 9 s só com o primeiro item. Com o segundo, passou a levar cerca de 3 s.

## Testes automatizados (`test/offline/`)

Rodar com `flutter test test/offline`. O Firestore é simulado em `test/offline/fakes/fake_firestore.dart`: sem rede, a escrita fica pendente até o teste "reconectar".

| Arquivo | O que prova |
|---|---|
| `faq_offline_test.dart` | Criar, editar e excluir offline terminam sem travar e já aparecem na lista. Sem cache, a leitura mostra as perguntas padrão; com cache, mostra o da última conexão. Rede que não responde não trava a leitura. Depois de salvar offline, a lista volta em menos de 1 s. Na reconexão, as escritas sobem na ordem e a lista vem do servidor sem duplicar |
| `psychologist_faq_offline_test.dart` | No painel da psicóloga, `salvar()` e `excluir()` terminam sem internet (`isSaving` volta a `false`), e a pergunta sobe quando a internet volta |
| `diary_offline_test.dart` | Registrar e ler o humor sem rede, com o app reaberto; um segundo registro no mesmo dia altera o humor do dia |
| `cvv_offline_test.dart` | O botão abre o discador com `tel:188`; sem discador, mostra "Não foi possível abrir o discador." e a tela continua respondendo; `CvvButton.dial()` nunca lança erro |
| `test/shared/auth/auth_repository_test.dart` (PR #25) | Entrada do aluno sem internet com sessão local e login anônimo na volta da rede |

Para provar que os testes pegam o defeito: o teste "salvar sem internet não deixa a tela girando" foi rodado contra o código antigo. Ele estourou o limite de 3 s sem terminar. Com a correção, passa em ~2 s.

## Testes manuais no emulador

**Aparelho:** emulador Pixel com Android 7.0 (API 24), APK debug da branch `feature/bateria-testes-offline`. O modo avião foi ligado com `settings put global airplane_mode_on 1` e `svc wifi/data disable`.

### Aluno (dados do app apagados, modo avião ligado)

| # | Passos | Esperado | Obtido |
|---|---|---|---|
| A1 | Abrir o app → Entrar como aluno → codinome → Continuar | Entra na Home sem internet | ✅ Home "Olá, aluno!"; `profile_local_uid` gravado no aparelho |
| A2 | "Como está sua mente hoje?" → escolher Feliz → salvar → abrir Diário Pessoal | Registro salvo e listado | ✅ "Me senti feliz" listado; `"humor":"feliz"` no `SharedPreferences` |
| A3 | Tocar em "Ajuda (CVV)" | Discador abre com 188 | ✅ Discador do Android com **188** preenchido; ao voltar, o diário estava intacto |
| A4 | Home → "Canais de Apoio & FAQ" | Abre sem travar, com cache ou perguntas padrão | ✅ Abriu em menos de 1 s com as perguntas padrão |

### Psicóloga (login feito com internet, depois modo avião)

| # | Passos | Esperado | Obtido |
|---|---|---|---|
| P1 | Abrir "Editar Perguntas Frequentes (FAQ)" com internet → ligar o modo avião | Lista carregada do servidor | ✅ |
| P2 | Criar "Teste offline bateria" no modo avião | Salva sem travar e aparece na lista | ✅ Antes da otimização, levou de 5 a 9 s e não travou |
| P3 | Ligar a rede e conferir no console do Firestore | O documento chega ao servidor | ✅ Documento na coleção `faq` com `createdAt` 17:04:00 (hora da criação offline) e `updatedAt` 17:04:38 (hora da sincronização) |
| P4 | Criar "Teste rapido" no modo avião (APK com a otimização) | Salva em poucos segundos | ✅ "Pergunta publicada no FAQ!" em ~3 s |
| P5 | Excluir "Teste rapido" e "Teste offline bateria" no modo avião | Somem da lista sem travar | ✅ "Pergunta removida do FAQ." |
| P6 | Ligar a rede e conferir no console do Firestore | A exclusão chega ao servidor | ✅ A coleção `faq` voltou aos 2 documentos originais; "Teste rapido" (criada e excluída offline) nunca chegou ao servidor |

## Observações

- O servidor tem 2 perguntas na coleção `faq`, mas o painel mostra só "O que é bullying?". Provavelmente o outro documento não tem o campo `createdAt`, e a consulta ordenada por esse campo deixa de fora quem não o tem. Isso já existia antes desta task e não foi alterado.
- O emulador de Android 7 não responde a `ping`, mesmo com internet. A volta da rede foi confirmada pela fonte Poppins carregando e pelas escritas chegando ao Firestore.
