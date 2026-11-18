# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projeto

MenteLeve: app Flutter (projeto acadêmico em equipe) de apoio emocional a adolescentes de 10 a 17 anos. Três perfis: **aluno** (anônimo, sem login), **psicóloga** e **responsável** (login institucional por e-mail/senha). Código, UI, commits e docs em PT-BR.

## Comandos

```bash
flutter pub get          # dependências
flutter run              # rodar (Firebase só está configurado para Android, ver abaixo)
flutter analyze          # lint (flutter_lints; android/ios/web/windows/macos/linux excluídos)
flutter test             # testes (ainda não existe pasta test/)
flutter test test/arquivo_test.dart --plain-name "nome do teste"   # um teste
```

## Firebase

- `Firebase.initializeApp()` é chamado **sem `options`** e não existe `firebase_options.dart`: depende de `android/app/google-services.json`, que está no `.gitignore` (cada dev precisa do seu). Não há `GoogleService-Info.plist`, então iOS/web/desktop não inicializam o Firebase.
- O código lê o papel institucional na coleção `users/{uid}` (`auth_repository.dart`), enquanto `docs/modelagem/03-modelagem-firestore.md` documenta `usuarios/{uid}`. Conferir qual vale antes de mexer em coleções.
- Pela modelagem, o diário e o codinome do aluno ficam **só no aparelho**, nunca no Firestore. O Firestore guarda FAQ, guias, canais e denúncias.

## Arquitetura

- `main.dart`: `FutureBuilder` faz o bootstrap (Firebase + `SharedPreferences`), monta `AuthNotifier(AuthRepository(FirebaseAuth, FirebaseFirestore, ProfileStore))` e o injeta com `ChangeNotifierProvider` acima do `AppWidget`. Injeção de dependência é manual, no bootstrap.
- `app_widget.dart`: `MaterialApp` com rotas nomeadas (`/splash`, `/onboarding`, `/auth/<perfil>`, `/<perfil>/home`). Rota nova é registrada aqui.
- `SplashView` chama `auth.restore()` e redireciona pelo `Role` da sessão (`homeFor`) ou para `/onboarding`.
- `lib/modules/<perfil>/<feature>/`: cada tela tem `*_view.dart` e, quando há formulário, um `*_controller.dart` (classe simples com `GlobalKey<FormState>`, validação e estado do form, sem `ChangeNotifier`). Perfis: `student`, `psychologist`, `parents`, mais `splash` e `onboarding`.
- `lib/shared/`: `auth/`, `models/`, `themes/` (`TailwindColors` com a paleta do Tailwind v3.4 e `AppTextStyles` com Poppins via google_fonts) e `widgets/` reutilizáveis (`ProfileAuthScaffold`, botão, campo de texto).

### Fluxo de autenticação

- `SessionModel` é `sealed`: `StudentSessionModel` (uid anônimo + `LocalUserModel` com codinome/avatar) ou `InstitutionalSession` (`UserModel` vindo do Firestore). Use `switch` exaustivo.
- Aluno: `signInAnonymously()` + perfil salvo localmente em `ProfileStore` (SharedPreferences, chave `profile`). O aluno **nunca** é gravado em `users`; `UserModel.fromFirestore` lança erro se `role == student`.
- Institucional: login por e-mail/senha, depois lê `users/{uid}`; se o documento não existe ou o `role` difere do perfil escolhido, faz signOut e lança `AccessDenied`.
- `AuthNotifier._run` controla `isLoading` e devolve `String?` (mensagem de erro em PT-BR ou `null` em caso de sucesso); as views mostram essa mensagem. Novos códigos de erro entram em `_messageFor`.
- Avatares são SVGs em `assets/avatars/` (o perfil guarda só o nome do arquivo, ex. `panda.svg`); `SelectAvatarView` devolve o nome via `Navigator.pop`.

## Documentação e processo

- `docs/` tem levantamento (requisitos, escopo e sprints em `levantamento/escopo.md`), modelagem (casos de uso, classes, Firestore, mapeamento Dart↔Firestore), fluxogramas e protótipos. Consultar antes de implementar uma feature.
- `CHANGELOG.md` é organizado por data (`## [dd/mm/aaaa]` + `### Adicionado`).
- `docs/uso-de-ia.md` registra o uso de IA por sprint e por integrante. Ao terminar uma tarefa feita com IA, perguntar ao Abraão se deve registrá-la ali, na sprint atual e na seção dele, seguindo o formato existente: o que foi feito, ferramenta utilizada (ex.: Claude Code, com o modelo), prompts utilizados, como a IA ajudou e dificuldades/ajustes manuais.
- Tarefas vêm do Jira (chaves `SCRUM-<n>`), que costumam aparecer no nome da branch e no commit. Commits no estilo Conventional Commits (`feat:`, `docs(escopo):`, `refactor:`). Trabalho entra em `main` via PR no GitHub (`maarcos4g/mente-leve`).
