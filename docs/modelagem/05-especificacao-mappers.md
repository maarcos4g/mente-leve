# Especificação dos Mappers: Documento (Firebase / aparelho) ↔ Entidade de domínio

Define como cada entidade de domínio é convertida de e para o seu armazenamento: métodos `toMap()` / `fromMap()`, conversores do Firestore (`fromFirestore` / `toFirestore`), serialização JSON e tratamento de nulos.

Complementa `02-diagrama-de-classes.md` (entidades), `03-modelagem-firestore.md` (documentos) e `04-mapeamento-dart-firestore.md` (destino de cada classe). Este documento descreve o **contrato dos métodos**; a situação de cada um (implementado ou planejado) está na seção 2.

## 1. Convenções

### 1.1 Dois tipos de mapper

| Armazenamento | Métodos na entidade | Formato do documento | Quem chama |
|---|---|---|---|
| Aparelho (`SharedPreferences`) | `Map<String, dynamic> toMap()` e `factory X.fromMap(Map<dynamic, dynamic>)` | JSON em texto, gravado com `jsonEncode(x.toMap())` e lido com `X.fromMap(jsonDecode(raw) as Map)` | `ProfileStore`, `PrefsDiaryRepository`, `SupportTriggerStateStore` |
| Firestore | `factory X.fromFirestore(DocumentSnapshot<Map<String, dynamic>>, SnapshotOptions?)` e, quando há escrita, `Map<String, dynamic> toFirestore()` | `Map` com tipos nativos do Firestore (`Timestamp`, `FieldValue`) | `withConverter<X>(fromFirestore:, toFirestore:)` no repositório |

Regras comuns:

1. O mapper vive **na entidade** (ou ao lado dela), nunca na view nem no controller. A entidade não conhece `SharedPreferences` nem `FirebaseFirestore`; só os tipos de dados (`Timestamp`, `DocumentSnapshot`) no caso dos conversores do Firestore.
2. O `id` do documento Firestore **não é campo**: vem de `snapshot.id` e não entra no `toFirestore()`. No JSON local o `id` é gravado dentro do mapa, e o repositório também o usa como chave (`{id: registro}`).
3. Campos calculados (`isInstitutional`, `temTexto`, `canDial`, `Report.isPending`) e de estado em tempo de execução (`ChatMessage.isPending`) **não são gravados**.
4. A entidade é imutável (`final`, construtor `const` quando possível). Alterações passam por `copyWith`/`editar` e geram novo objeto, que é regravado inteiro.
5. Mapper é função pura: sem I/O, sem `await`, sem relógio, exceto o fallback de `DateTime.now()` descrito na seção 3.2.

### 1.2 Conversão de tipos

| Tipo Dart | JSON local (`toMap`/`fromMap`) | Firestore | Observação |
|---|---|---|---|
| `String` | string | string | `as String` na leitura |
| `int` (`ordem`) | number | number | Firestore devolve `int`; usar `(x as num).toInt()` se o valor puder vir como `double` |
| `bool` | boolean | boolean | Só para campos persistidos |
| `enum` | `enum.name` | `enum.name` | Leitura com `values.byName(texto)`; valor desconhecido lança `ArgumentError` |
| `DateTime` | texto ISO 8601 (`toIso8601String()`); leitura com `DateTime.parse` | `Timestamp.fromDate(d)` / `FieldValue.serverTimestamp()`; leitura com `(x as Timestamp?)?.toDate()` | `DateTime` local sai sem sufixo de fuso; UTC sai com `Z`. Os dois são lidos de volta sem perda |
| `List<String>` | array de strings | array de strings | Leitura com `List<String>.from(x as Iterable)`, que copia a lista |
| `T?` | chave com `null` ou ausente | campo ausente (preferido) | Ver seção 3 |

### 1.3 Serialização JSON

O JSON é só o transporte do `SharedPreferences` (que guarda apenas texto). Fluxo completo:

```
Entidade --toMap()--> Map<String, dynamic> --jsonEncode--> String --setString(chave)--> aparelho
aparelho --getString(chave)--> String --jsonDecode--> Map (dynamic) --fromMap()--> Entidade
```

- `toMap()` só pode devolver valores aceitos por `jsonEncode`: `String`, `num`, `bool`, `null`, `List` e `Map<String, …>`. Por isso `DateTime` e enum são convertidos antes (seção 1.2).
- `fromMap()` recebe `Map<dynamic, dynamic>` porque `jsonDecode` devolve `Map<String, dynamic>` só no topo; mapas aninhados chegam como `Map<dynamic, dynamic>`.
- Um repositório que guarda vários itens grava um único JSON `{id: toMap()}` (`diario`). Um repositório de item único grava o mapa direto (`profile`, `support_trigger_state`).

## 2. Catálogo de mappers

| Entidade (Dart) | Destino | Chave / caminho | Métodos | Situação |
|---|---|---|---|---|
| `UserModel` (Usuario) | Firestore | `users/{uid}` | `fromFirestore` | Implementado, **somente leitura** |
| `LocalUserModel` (PerfilLocal) | Aparelho | `profile` | `toMap`, `fromMap` | Implementado |
| `RegistroDiario` | Aparelho | `diario` | `toMap`, `fromMap` | Implementado |
| `SupportTriggerState` (EstadoGatilhoApoio) | Aparelho | `support_trigger_state` | `toMap`, `fromMap` | Implementado |
| `MoodRecord` | Aparelho (só leitura de `diario`) | `diario` | parser privado `_parse` | Implementado, projeção de `RegistroDiario` |
| `FaqModel` (PerguntaFaq) | Firestore e aparelho | `faq/{id}` e `faq_cache` | `fromFirestore`, `toFirestore`, `toMap`, `fromMap` | Implementado |
| `Report` (Denuncia) | Firestore | `reports/{uid}` | `fromFirestore`, `fromMap(id, data)` | Implementado. A criação é feita por mapa literal no `ChatRepository.send` (ver `04`) |
| `ChatMessage` (MensagemChat) | Firestore | `reports/{uid}/messages/{id}` | `fromMap(id, data, isPending:)` | Implementado. A escrita é feita por mapa literal nos repositórios do chat |
| `GuideModel` (Guia) | Firestore | `guides/{id}` | `fromFirestore`, `toFirestore` | Na branch `feat/parents-home-e-guias-psicologa`, ainda não mesclada |
| `OfficialChannel` (CanalApoio) | Código do app | `officialChannels` | nenhum | Lista constante, sem persistência |

> **Nomenclatura.** Os nomes de coleções e de campos do Firestore estão em inglês (`users`, `role`, `name`, `createdAt`, `faq`, `question`, `answer`, `reports`, `messages`, `guides`), como no código e no `03`. As regras de segurança leem `users/{uid}.role`. Os nomes em português (Usuario, Denuncia etc.) aparecem só no diagrama de classes (`02`), que descreve o domínio.

## 3. Tratamento de nulos

### 3.1 Princípios

1. **Campo obrigatório** (tipo não nulo na entidade): ausente ou `null` no documento é erro. O mapper deixa a exceção subir (`TypeError`/`ArgumentError`/`FormatException`), exceto quando a seção 3.2 prevê fallback. Não se inventa valor para esconder documento inválido.
2. **Campo opcional** (`T?`): ausente e `null` são equivalentes na leitura e resultam em `null`.
3. **Escrita de opcional nulo**:
   - **Firestore**: o campo é **omitido** (`if (x != null) 'campo': x`). Regras de segurança com `keys().hasOnly(...)` e `diff()` ficam previsíveis e o documento não carrega `null`.
   - **JSON local**: ambos são aceitos na leitura. Entidades novas devem omitir a chave (como `SupportTriggerState`). `RegistroDiario` grava `'texto': null` explicitamente; é compatível e não precisa mudar.
4. **Lista**: ausente ou `null` vira lista vazia `const []` (lista nunca é nula na entidade). Na escrita, lista vazia é gravada como `[]`.
5. **Timestamp do servidor**: `FieldValue.serverTimestamp()` só é aceito na escrita. Em leitura local (cache, escrita pendente) o campo vem `null` até o servidor confirmar, por isso `(x as Timestamp?)?.toDate() ?? DateTime.now()`.

### 3.2 Política de falha por tipo de leitura

| Situação | Comportamento | Onde |
|---|---|---|
| Documento Firestore inexistente | `withConverter(...).get()` não chama `fromFirestore`; `snapshot.data()` é `null` e o repositório devolve `null` | `AuthRepository._fetchUser` |
| Campo obrigatório ausente (Firestore) | Exceção sobe até o `AuthNotifier._run`, que mostra mensagem de erro e faz signOut | `UserModel.fromFirestore` |
| Timestamp `null` pendente | Fallback `DateTime.now()` | `createdAt`, `criadoEm`, `atualizadoEm` |
| Enum com valor desconhecido | `ArgumentError` de `byName`; tratado como documento inválido | todos os enums |
| `LocalUserModel` corrompido ou incompleto | `ProfileStore.read()` captura qualquer erro e devolve `null` (volta ao onboarding) | `profile` |
| `SupportTriggerState` corrompido | `SupportTriggerStateStore.read()` captura e devolve `SupportTriggerState.empty` | `support_trigger_state` |
| `RegistroDiario` inválido em `getAll()` | Falha a lista inteira (`jsonDecode`/`fromMap` sem `try`). O gatilho evita isso lendo por `PrefsMoodRecordRepository`, que ignora o registro inválido | `diario` |
| Chave `diario` inteira corrompida | `jsonDecode` lança; o controller do gatilho trata | `PrefsMoodRecordRepository.recordsSince` |

## 4. Especificação por entidade

### 4.1 `UserModel` (`lib/shared/models/user_model.dart`)

Documento: `users/{uid}`. Só psicóloga e responsável; o aluno nunca é gravado.

| Campo Dart | Tipo | Campo no documento | Tipo no documento | Nulo? | Leitura |
|---|---|---|---|---|---|
| `uid` | `String` | (id do documento) | | não | `snapshot.id` |
| `name` | `String` | `name` | string | não | `data['name'] as String` |
| `role` | `Role` | `role` | string | não | `Role.values.byName(data['role'] as String)` |
| `createdAt` | `DateTime` | `createdAt` | timestamp | não (fallback) | `(data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now()` |

Contrato:

- `fromFirestore(snapshot, options)`: `snapshot.data()!` (o conversor só é chamado para documento existente). Se `role == Role.student`, lança `StateError('O Aluno não deve ser registrado como usuário no sistema')`.
- **Sem `toFirestore`.** O documento é criado pela escola, fora do app. Em `AuthRepository`, o conversor passa `toFirestore: (_, _) => throw UnsupportedError('Apenas leitura')`, o que torna qualquer tentativa de escrita um erro explícito.
- Não grava credenciais (ficam no Firebase Auth).

Exemplo de documento válido:

```json
{ "name": "Camila", "role": "psychologist", "createdAt": "<Timestamp>" }
```

### 4.2 `LocalUserModel` (`lib/shared/models/local_user_model.dart`)

Perfil do aluno, só no aparelho, chave `profile`.

| Campo | Tipo | Chave JSON | Nulo? |
|---|---|---|---|
| `nickname` | `String` | `nickname` | não |
| `avatar` | `String` (nome do SVG, ex. `panda.svg`) | `avatar` | não |

```json
{ "nickname": "Estrela", "avatar": "panda.svg" }
```

- `toMap()` devolve exatamente essas duas chaves.
- `fromMap(Map)` usa `as String` nas duas: chave ausente ou de outro tipo lança `TypeError`. Não há fallback; quem lê é o `ProfileStore.read()`, que captura e devolve `null`.
- O `avatar` guarda só o nome do arquivo, nunca o caminho nem o conteúdo do SVG.

### 4.3 `RegistroDiario` (`lib/modules/student/diary/models/registro_diario.dart`)

Registro do diário, só no aparelho, dentro do JSON `{id: registro}` da chave `diario`.

| Campo | Tipo | Chave JSON | Nulo? | Gravação | Leitura |
|---|---|---|---|---|---|
| `id` | `String` | `id` | não | `id` | `map['id']?.toString() ?? ''` |
| `humor` | `Humor` | `humor` | não | `humor.name` | `Humor.values.byName(map['humor'] as String)` |
| `texto` | `String?` | `texto` | sim | valor ou `null` | `map['texto'] as String?` |
| `pontosPositivos` | `List<String>` | `pontosPositivos` | não (lista vazia) | a lista | ausente/`null` → `const []`; senão `List<String>.from(... as Iterable)` |
| `dataHora` | `DateTime` | `dataHora` | não | `toIso8601String()` | `DateTime` já pronto é aceito; senão `DateTime.parse(... as String)` |

```json
{
  "id": "1731974400000",
  "humor": "comRaiva",
  "texto": null,
  "pontosPositivos": ["Conversei com uma amiga"],
  "dataHora": "2026-11-19T14:30:00.000"
}
```

Contrato:

- `fromMap` é o mapper mais tolerante do projeto: aceita `dataHora` como `DateTime` (útil em testes) e `pontosPositivos` ausente.
- `id` ausente vira `''`. Isso evita exceção, mas gera registro com `id` vazio; o repositório sempre grava com o `id` do objeto, então o caso só ocorre com dado externo ou antigo.
- `temTexto` é calculado (`texto` não nulo e não vazio depois de `trim`) e **não** é gravado. Texto vazio e `null` são diferentes no JSON, mas iguais para `temTexto`.
- `copyWith`/`editar` usam `clearTexto: true` para apagar o texto, porque `texto: null` significaria "manter". O mapper não tem essa distinção: grava o que a entidade tem.
- Igualdade (`==`/`hashCode`) compara todos os campos, e as listas com `listEquals`. Serve para testar ida e volta: `RegistroDiario.fromMap(r.toMap()) == r`.

### 4.4 `SupportTriggerState` (`lib/modules/student/support_trigger/models/support_trigger_state.dart`)

Controle do modal de apoio (RN11), só no aparelho, chave `support_trigger_state`.

| Campo | Tipo | Chave JSON | Nulo? | Gravação |
|---|---|---|---|---|
| `lastShownAt` | `DateTime?` | `lastShownAt` | sim | omitida se `null`; senão ISO 8601 |
| `countFrom` | `DateTime?` | `countFrom` | sim | omitida se `null`; senão ISO 8601 |

```json
{ "lastShownAt": "2026-11-19T14:30:00.000", "countFrom": "2026-11-19T14:30:00.000" }
```

Estado vazio: `{}`, equivalente a `SupportTriggerState.empty`.

Contrato:

- `toMap()` usa `if (campo != null)` dentro do literal: é o padrão a seguir para opcionais.
- `fromMap(Map)`: chave ausente ou `null` → `null`. Texto que não seja ISO 8601 lança `FormatException`, e valor de tipo errado lança `TypeError`. O mapper **não** captura: quem lê (`SupportTriggerStateStore.read`) devolve `empty` em qualquer erro.
- Não contém `uid`, humor nem texto do aluno.

### 4.5 `MoodRecord` (projeção de leitura)

`PrefsMoodRecordRepository` lê a chave `diario` sem passar por `RegistroDiario.fromMap`. Cada valor vira `MoodRecord(mood, dateTime)`:

- `humor` é mantido como `String` (sem `byName`), então um humor novo ou desconhecido não derruba o gatilho.
- `dataHora` usa `DateTime.tryParse(valor?.toString() ?? '')`; `null` descarta o registro.
- Valor que não seja `Map`, `humor` que não seja `String` ou data inválida: o registro é **ignorado**, não lança erro.

É a única leitura que descarta dado inválido em vez de falhar, de propósito: o gatilho de apoio não pode ser desligado por um registro ruim.

### 4.6 Entidades do Firestore: FAQ, relato e chat

Os conversores do FAQ, do relato e do chat são **tolerantes**: campo ausente ou de tipo errado vira um valor seguro em vez de lançar erro. É diferente do `UserModel` (seção 4.1), que falha. A escolha é de propósito: um documento malformado não pode esconder o FAQ nem derrubar a triagem.

| Entidade | Leitura | Escrita | Nulos e valores desconhecidos |
|---|---|---|---|
| `FaqModel` (`lib/shared/models/faq_model.dart`) | `fromFirestore`: `question` e `answer` com fallback `''`; datas com fallback `DateTime.now()`; `updatedBy` com fallback `''`. Documento vazio lança `StateError` | `toFirestore()`: `createdAt` preservado, `updatedAt` = `serverTimestamp()`. `toMap()`/`fromMap()` para o cache `faq_cache`, com datas em ISO 8601 | Nenhum campo opcional |
| `Report` (`lib/shared/models/report_model.dart`) | `fromMap(id, data)`: `type` e `status` por `fromName`; `createdAt` nulo (escrita pendente) vira `DateTime.now()`; `severity` ausente é estimada por `ReportSeverity.infer(type, description)` | Não tem `toFirestore`. O `ChatRepository.send` grava `studentUid, type, description, status('pending'), createdAt(serverTimestamp)`, exatamente as chaves que a regra de `create` aceita | `type` desconhecido → `other`; `status` desconhecido → `pending` (nunca some da triagem). `studentUid` é ignorado na leitura |
| `ChatMessage` (`lib/shared/models/chat_message.dart`) | `fromMap(id, data, isPending:)`: `senderRole` por `ChatSender.fromName`; `text` com fallback `''`; `createdAt` com fallback `DateTime.now()` | Mapa literal `{senderRole, text, createdAt(serverTimestamp)}` | `senderRole` desconhecido → `psychologist`, para nunca ser exibido como mensagem do próprio aluno. `isPending` vem de `metadata.hasPendingWrites` e não é gravado |
| `GuideModel` (branch dos guias) | `fromFirestore`; `category` opcional | `toFirestore()` omite `category` e `authorUid` quando vazios | `category`, `authorUid` |

## 5. Critérios de teste dos mappers

Cada mapper implementado deve ter teste de unidade (sem Firebase) cobrindo:

1. **Ida e volta**: `X.fromMap(x.toMap()) == x` para valores típicos (e para `jsonDecode(jsonEncode(x.toMap()))`, que é o caminho real).
2. **Opcionais nulos**: `texto: null`, `lastShownAt: null`, `countFrom: null` voltam como `null`; em `SupportTriggerState` o `toMap()` não contém a chave.
3. **Listas**: `pontosPositivos` vazia, ausente e `null` resultam em lista vazia.
4. **Enum**: todos os valores de `Humor` e `Role` fazem a ida e volta; nome desconhecido lança `ArgumentError`.
5. **Datas**: `DateTime` local e UTC fazem a ida e volta sem perda; texto inválido lança `FormatException`; em `UserModel`, `createdAt` ausente usa o fallback.
6. **Campos obrigatórios ausentes**: `LocalUserModel.fromMap({})` lança erro; `ProfileStore.read()` devolve `null` com JSON corrompido; `SupportTriggerStateStore.read()` devolve `empty`.
7. **Regra de perfil**: `UserModel.fromFirestore` com `role: student` lança `StateError`.
8. **Isolamento**: `PrefsMoodRecordRepository` ignora um registro inválido e mantém os demais.

Para o `UserModel`, use `fake_cloud_firestore` ou um `DocumentSnapshot` simulado, já que `fromFirestore` recebe o snapshot.

## 6. Pontos em aberto

| # | Ponto | Impacto |
|---|---|---|
| 1 | ~~Nomenclatura divergente entre código e documentação~~ | Resolvido: tudo em inglês no Firestore, no código e no `03` (ver seção 2) |
| 2 | `RegistroDiario.getAll()` falha a lista inteira com um registro inválido | Um registro corrompido esconde todo o diário; avaliar tolerância como no `PrefsMoodRecordRepository` |
| 3 | `RegistroDiario.fromMap` aceita `id` ausente como `''` | Pode gerar registro não removível por `delete(id)` |
| 4 | Diário e perfil em `SharedPreferences` sem criptografia | Decisão do grupo, registrada no `03` e no `04`: os dados nunca saem do aparelho e o diário é protegido por PIN (guardado como hash). Criptografar o armazenamento fica como melhoria futura |
| 5 | `GuideModel` ainda não está na `main` | Depende do merge da branch `feat/parents-home-e-guias-psicologa` |
