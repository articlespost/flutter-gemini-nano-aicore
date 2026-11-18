# Gemini Nano On-Device com Flutter — Android AICore via Method Channels e Event Channels

Projeto de referência do artigo **"Explorando o Android AICore com Flutter: Gemini Nano On-Device via Method Channels e Event Channels"**.

O repositório contém:

- uma **ponte Kotlin** (`GeminiNanoBridge`) sobre a **ML Kit GenAI Prompt API**, com corrotinas, cancelamento, validação de entrada e tradução de erros;
- um **app Flutter** em arquitetura **feature-first** (`core` + `features`), que verifica a disponibilidade do modelo, acompanha o download e exibe a resposta **token a token**;
- **45 testes** (erros, retry, datasource com canais simulados, models, repository, service, controller e tela) que rodam **sem aparelho**.

> ⚠️ Código de exemplo para estudo, sujeito a revisão antes de qualquer uso em produção. A Prompt API ainda está em **beta**: assinaturas e comportamento podem mudar entre versões.

## 📰 Artigo

Este repositório acompanha o artigo **"Explorando o Android AICore com Flutter: Gemini Nano On-Device via Method Channels e Event Channels"**, que explica em detalhes a teoria e cada decisão do código:

- o que é o AICore e como a API evoluiu do AI Edge SDK até o ML Kit GenAI;
- requisitos e limitações reais (aparelhos, quotas, execução apenas em primeiro plano);
- por que `MethodChannel` para request/response e `EventChannel` para streaming;
- a ponte em Kotlin, a arquitetura Flutter e as armadilhas encontradas.

🔗 **Leia o artigo completo no LinkedIn:** *(link em breve)*

---

## Sumário

1. Stack
2. Estrutura do projeto
3. Pré-requisitos
4. Baixar e rodar
5. Testes
6. Contrato da ponte
7. Solução de problemas
8. Assinatura
9. Referências oficiais

---

## 🧱 Stack

| Componente | Versão |
|---|---|
| Flutter / Dart | 3.47.9 / 3.13.7 |
| Android Gradle Plugin | 9.1.0 |
| Kotlin | 2.4.0 (a `genai-prompt` beta5 exige 2.3+) |
| Gradle (wrapper) | 9.3.1 |
| `com.google.mlkit:genai-prompt` | 1.0.0-beta5 |
| `kotlinx-coroutines-android` | 1.10.2 |
| `minSdk` | 26 |
| Dependências Dart de terceiros | nenhuma |

## 🗂️ Estrutura do projeto

```text
gemini_nano_bridge/
├── android/app/src/main/kotlin/com/articlespost/gemini_nano_bridge/
│   ├── MainActivity.kt                    # Cria e descarta a ponte junto com o engine
│   └── ai/
│       ├── ChannelContract.kt             # Canais, métodos, chaves e códigos de erro
│       ├── GenerationRequestParser.kt     # Valida e limita a entrada vinda do Dart
│       ├── BridgeError.kt                 # GenAiException → código estável
│       └── GeminiNanoBridge.kt            # MethodChannel + EventChannels + corrotinas
├── lib/
│   ├── main.dart
│   └── src/
│       ├── app.dart
│       ├── core/
│       │   ├── di/                        # AppContainer e AppScope
│       │   ├── errors/                    # AppError, Result, safeCall e guardStream
│       │   ├── platform/                  # Contrato dos canais (lado Dart)
│       │   ├── router/                    # AppRoutes e RouteGenerator
│       │   ├── theme/                     # Tema e espaçamentos
│       │   └── utils/                     # RetryPolicy (backoff exponencial)
│       └── features/assistant/
│           ├── data/
│           │   ├── datasource/            # GeminiNanoDataSource: só I/O com a plataforma
│           │   ├── domain/entities/       # ModelAvailability, ModelDownloadUpdate
│           │   ├── models/                # Leitura e validação do formato dos canais
│           │   ├── repositories/          # IAssistantRepository + Impl
│           │   └── services/              # Validação do prompt e retry em streaming
│           └── presentation/
│               ├── controllers/           # AssistantController (ValueNotifier)
│               ├── screens/               # Tela + strings
│               ├── state/                 # AssistantState imutável
│               └── widgets/
└── test/                                  # Espelha a estrutura de lib/
```

---

## 📋 Pré-requisitos

| Ferramenta | Versão / observação |
|---|---|
| **Flutter SDK** | 3.47+ (Dart 3.13+) |
| **Android SDK** | Platform-Tools (`adb`) e a plataforma indicada pelo Flutter |
| **JDK** | 17+ |
| **Aparelho físico compatível** | Com **Android AICore e Gemini Nano** (veja abaixo) |

### ⚠️ Emulador não tem Gemini Nano

O Gemini Nano roda no **AICore**, um serviço de sistema presente em **aparelhos físicos compatíveis**. Em emulador, o app abre normalmente, mas mostra **"IA on-device indisponível"**: esse é o comportamento esperado, não um erro.

Pela tabela oficial do ML Kit, a Prompt API funciona, entre outros, em:

- **Gemini Nano 4:** Pixel 10, Galaxy S25/S26, Galaxy Z Fold7/Flip7 e modelos recentes de OnePlus, OPPO, vivo e Motorola;
- **Gemini Nano 3:** linha Pixel 9;
- **Gemini Nano 2:** diversos modelos Xiaomi, Redmi, POCO, realme e vivo.

Consulte a lista completa e atualizada em [ML Kit GenAI](https://developers.google.com/ml-kit/genai). Bootloader desbloqueado não é suportado.

---

## 📥 Baixar e rodar

**1. Clone o repositório e baixe as dependências:**

```bash
git clone https://github.com/articlespost/flutter-gemini-nano-aicore.git
cd flutter-gemini-nano-aicore
flutter pub get
```

**2. Prepare o aparelho:** ative as **Opções do desenvolvedor** (toque 7 vezes em *Número da versão*), ligue a **Depuração USB**, conecte o cabo e confirme com `adb devices`.

**3. Rode o app:**

- **VS Code:** abra a pasta, selecione o aparelho na barra inferior e pressione **F5**.
- **Terminal:** `flutter run`

O que esperar na primeira execução:

| Estado na tela | Significado |
|---|---|
| *Verificando o modelo no aparelho...* | `checkStatus()` em andamento |
| *Baixando o Gemini Nano* + barra de progresso | O modelo é baixado uma única vez pelo AICore; depois fica disponível offline |
| Nome do modelo + chip *On-device* | Pronto: escreva um prompt ou toque em uma sugestão |
| *IA on-device indisponível* | Aparelho (ou emulador) sem Gemini Nano |

> A inferência só é permitida com o app em **primeiro plano**. Ao minimizar o app, a geração em andamento é interrompida de propósito.

---

## 🧪 Testes

```bash
flutter analyze
flutter test
```

Esperado: `No issues found!` e `All tests passed!`. Os testes simulam os canais com `setMockMethodCallHandler` e `setMockStreamHandler`, então **não precisam de aparelho**. O comportamento do modelo em si só pode ser validado em um aparelho compatível.

---

## 🔌 Contrato da ponte

| Canal | Operação | Entrada | Saída |
|---|---|---|---|
| `com.articlespost.gemini_nano/methods` | `checkStatus` | — | `available`, `downloadable`, `downloading` ou `unavailable` |
| `com.articlespost.gemini_nano/methods` | `warmup` | — | `null` |
| `com.articlespost.gemini_nano/methods` | `baseModelName` | — | nome do modelo base |
| `com.articlespost.gemini_nano/download` | `listen` | — | `{type: started \| progress \| completed, bytes}` |
| `com.articlespost.gemini_nano/generation` | `listen` | `prompt`, `temperature`, `topK`, `maxOutputTokens` | trechos de texto até `endOfStream` |

Os nomes ficam centralizados em `ChannelContract.kt` (Android) e `platform_contract.dart` (Flutter).

| Código de erro | Origem | Tratamento no app |
|---|---|---|
| `BUSY` | Quota de curto prazo do AICore | Retry com backoff, só antes do primeiro trecho |
| `QUOTA_EXCEEDED` | Quota de longo prazo (ex.: diária) | Mensagem ao usuário, sem retry |
| `BACKGROUND_USE_BLOCKED` | App fora do primeiro plano | Geração interrompida |
| `REQUEST_TOO_LARGE` / `INVALID_ARGUMENT` | Prompt grande demais ou inválido | Mensagem ao usuário |
| `AICORE_INCOMPATIBLE` | AICore ausente ou desatualizado | Sugere atualizar o AICore |
| `NOT_AVAILABLE` | Recurso indisponível no aparelho | Estado "indisponível" |

---

## 🧯 Solução de problemas

| Sintoma | Causa | Solução |
|---|---|---|
| *IA on-device indisponível* no emulador | Emulador não tem AICore com Gemini Nano | Use um aparelho físico compatível |
| *IA on-device indisponível* em aparelho da lista | AICore ausente, desatualizado ou ainda sem configuração | Atualize o **Android AICore** pela Play Store, reinicie o aparelho e tente de novo |
| Log com `601-BINDING_FAILURE` | Falha ao conectar ao serviço do AICore | Atualize o AICore e reinstale o app |
| Log com `606-FEATURE_NOT_FOUND` | Configuração do recurso ainda não baixada | Aguarde (pode levar de minutos a horas) e reinicie o aparelho |
| Download parado ou com falha | Sem rede, sem espaço ou erro do AICore | Verifique conexão e espaço; toque em **Tentar novamente** |
| *O modelo está ocupado* | Quota de curto prazo (`BUSY`) | Aguarde alguns segundos |
| Erro de versão do Kotlin no build | `genai-prompt` beta5 exige Kotlin 2.3+ | Confira o plugin Kotlin em `android/settings.gradle.kts` |

Para investigar no aparelho, filtre o Logcat pela tag da ponte (o log registra o código do erro, nunca o texto do prompt):

```bash
adb logcat -s GeminiNanoBridge
adb shell pm list packages | grep -i aicore
```

---

## 🔐 Assinatura

A release é assinada com as credenciais de `android/key.properties`, arquivo **fora do Git** (o `.gitignore` já bloqueia `key.properties`, `*.jks` e `*.keystore`). Use `android/key.properties.example` como modelo. Sem o arquivo, a release cai para a chave **debug**, aceitável apenas para testes locais.

O build de release tem **R8** (`isMinifyEnabled` + `isShrinkResources`) ativado e `android:allowBackup="false"`.

## 📚 Referências oficiais

- [ML Kit GenAI — visão geral e aparelhos compatíveis](https://developers.google.com/ml-kit/genai)
- [Prompt API — primeiros passos (Android)](https://developers.google.com/ml-kit/genai/prompt/android/get-started)
- [Referência Kotlin: `GenerativeModel`](https://developers.google.com/android/reference/kotlin/com/google/mlkit/genai/prompt/GenerativeModel)
- [Referência: `GenAiException.ErrorCode`](https://developers.google.com/android/reference/com/google/mlkit/genai/common/GenAiException.ErrorCode)
- [Notas de versão do ML Kit](https://developers.google.com/ml-kit/release-notes)
- [Platform channels (Flutter)](https://docs.flutter.dev/platform-integration/platform-channels)

## 📄 Licença

MIT — veja [LICENSE](LICENSE).
