# 📱 ProScript — Teleprompter Inteligente

ProScript é um aplicativo de teleprompter inteligente, ideal para criadores de conteúdo, professores, jornalistas e apresentadores. Desenvolvido em Flutter com Clean Architecture.

## ✨ Funcionalidades

### 🏠 Tela Inicial
- Lista de roteiros salvos localmente
- Busca por título ou conteúdo
- Filtro de favoritos
- Visualização de data de modificação e contagem de palavras

### ✍️ Editor de Roteiro
- Editor de texto completo
- Auto-salvamento a cada 3 segundos
- Contador de palavras em tempo real
- Acesso direto ao modo teleprompter

### 🎥 Modo Teleprompter
- Rolagem automática e ajustável
- Controle de velocidade em tempo real
- Espelhamento horizontal e vertical
- Contagem regressiva antes de iniciar (3 segundos)
- Controles de play/pause e reset
- Interface imersiva em tela cheia

### ⚙️ Configurações
- Tema claro/escuro
- Velocidade de rolagem (10-200)
- Tamanho da fonte (12-72)
- Margens ajustáveis (0-100)
- Espelhamento horizontal/vertical

### 💰 Monetização
- Banner ads nas telas Home e Editor
- Interstitial ads ao iniciar o Teleprompter

## 🏗️ Arquitetura

O projeto segue **Clean Architecture** com separação em camadas:

```
lib/
├── core/               # Constantes, temas, utils e serviços
├── data/               # Models, repositórios e persistência local
├── domain/             # Entities e use cases (lógica de negócio)
├── presentation/       # Screens, widgets e Blocs (UI)
└── di/                 # Injeção de dependências (GetIt)
```

### Tecnologias Utilizadas

- **Framework**: Flutter
- **Linguagem**: Dart
- **State Management**: `flutter_bloc`
- **Dependency Injection**: `get_it`
- **Local Storage**: `hive` + `hive_flutter`
- **Ads**: `google_mobile_ads`
- **UI**: Material 3 com `google_fonts`
- **Utils**: `uuid`, `intl`, `equatable`

## 🚀 Como Rodar o Projeto

### Pré-requisitos

- Flutter SDK (3.9.2 ou superior)
- Dart SDK
- Android Studio / VS Code
- Emulador ou dispositivo físico

### Instalação

1. Clone o repositório:
```bash
git clone <seu-repositorio>
cd pro_script
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Gere os arquivos do Hive:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **IMPORTANTE**: Configure suas chaves do AdMob
   - Abra `lib/core/constants/app_constants.dart`
   - Substitua os IDs de teste pelos seus IDs reais do AdMob:
     - `androidBannerId`
     - `iosBannerId`
     - `androidInterstitialId`
     - `iosInterstitialId`

5. Para Android, adicione seu App ID do AdMob em `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
```

6. Para iOS, adicione em `ios/Runner/Info.plist`:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
```

7. Execute o app:
```bash
flutter run
```

## 📋 Comandos Úteis

```bash
# Análise estática
flutter analyze

# Testes
flutter test

# Build para Android
flutter build apk --release

# Build para iOS
flutter build ios --release

# Limpar build
flutter clean

# Regenerar arquivos do Hive
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🗄️ Estrutura de Dados

### Script Entity
```dart
{
  id: String,
  title: String,
  content: String,
  createdAt: DateTime,
  updatedAt: DateTime,
  isFavorite: bool
}
```

### Settings Entity
```dart
{
  isDarkMode: bool,
  scrollSpeed: double,
  fontSize: double,
  margin: double,
  countdown: int,
  horizontalMirror: bool,
  verticalMirror: bool,
  fontFamily: String
}
```

## 🎨 Design System

### Cores
- **Primary Dark**: `#1A1A1A`
- **Primary Gray**: `#2E2E2E`
- **Accent Teal**: `#00838F`
- **Background Dark**: `#121212`
- **Surface Dark**: `#1E1E1E`

### Fontes
- **Títulos e UI**: Poppins
- **Código/Mono**: Roboto Mono

## 🔮 Funcionalidades Futuras

- [ ] Controle por voz (comandos: pausar, continuar, velocidade)
- [ ] Gravação de vídeo simultânea com câmera frontal
- [ ] Importação de arquivos (.txt, .docx, .pdf)
- [ ] Exportação/backup em JSON
- [ ] Suporte a Markdown
- [ ] IA para sugestões de pausa e ritmo
- [ ] Tempo estimado de leitura
- [ ] Versão Premium sem anúncios
- [ ] Temas personalizados
- [ ] Controle por Bluetooth

## 📱 Plataformas Suportadas

- ✅ Android
- ✅ iOS
- ⏳ Web (futuro)
- ⏳ Desktop (Windows, macOS, Linux) (futuro)

## 📄 Licença

Este projeto é de código aberto. Sinta-se livre para usar e modificar conforme necessário.

## 👨‍💻 Desenvolvedor

Desenvolvido com ❤️ usando Flutter

---

**ProScript** - Seu teleprompter de bolso profissional! 🎬
