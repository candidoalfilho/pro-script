# 🚀 ProScript - Quick Start Guide

## Começar a usar o app AGORA (5 minutos)

### 1️⃣ Verificar Instalação (já feito ✅)
```bash
flutter pub get              # ✅ Dependências instaladas
build_runner                 # ✅ Arquivos .g.dart gerados
flutter analyze              # ✅ Código analisado (1 info apenas)
```

### 2️⃣ Rodar o App

#### Opção A: Emulador Android
```bash
# Abrir emulador Android
flutter emulators --launch <emulator_id>

# Ou abrir pelo Android Studio

# Rodar o app
flutter run
```

#### Opção B: Emulador iOS (só macOS)
```bash
# Listar simuladores
xcrun simctl list devices

# Abrir simulador
open -a Simulator

# Rodar o app
flutter run
```

#### Opção C: Dispositivo Físico

**Android:**
1. Ativar "Opções do Desenvolvedor" no telefone
2. Ativar "Depuração USB"
3. Conectar via USB
4. `flutter run`

**iOS:**
1. Conectar iPhone via USB
2. Confiar no computador
3. `flutter run`

### 3️⃣ Testar Funcionalidades

#### Home Screen
- ✅ Criar novo roteiro (botão +)
- ✅ Buscar roteiros
- ✅ Adicionar aos favoritos (estrela)
- ✅ Filtrar favoritos (estrela no topo)
- ✅ Deletar roteiro

#### Editor Screen
- ✅ Escrever título e conteúdo
- ✅ Ver auto-save funcionando (3s)
- ✅ Ver contador de palavras
- ✅ Abrir teleprompter (▶️)

#### Teleprompter Screen
- ✅ Ver contagem regressiva (3, 2, 1)
- ✅ Rolagem automática iniciando
- ✅ Pausar/retomar (tap na tela)
- ✅ Ajustar velocidade (+/-)
- ✅ Reset (↻)
- ✅ Fechar (X)

#### Settings Screen
- ✅ Trocar tema (dark/light)
- ✅ Ajustar velocidade
- ✅ Ajustar fonte
- ✅ Ajustar margens
- ✅ Ativar espelhamento

### 4️⃣ Testar Anúncios

Os anúncios estão configurados com IDs de teste do Google:

- **Home/Editor**: Banner no rodapé (deve aparecer "Test Ad")
- **Teleprompter**: Interstitial ao abrir (pode não aparecer sempre em teste)

> ⚠️ **Nota**: Em ambiente de desenvolvimento, os anúncios de teste nem sempre carregam imediatamente. Isso é normal!

### 5️⃣ Persistência de Dados

Teste se os dados estão sendo salvos:

1. Criar um roteiro
2. Escrever conteúdo
3. Fechar o app completamente
4. Abrir novamente
5. ✅ Roteiro deve estar lá!

### 6️⃣ Hot Reload

Durante o desenvolvimento, você pode fazer mudanças no código e ver na hora:

```bash
# No terminal onde o app está rodando:
r  # Hot reload (mais rápido)
R  # Hot restart (reinicia o app)
q  # Quit (sair)
```

## 🎨 Personalizações Rápidas

### Mudar cores do tema
Edite: `lib/core/constants/app_colors.dart`

### Mudar velocidade padrão
Edite: `lib/core/constants/app_constants.dart`
```dart
static const double defaultScrollSpeed = 50.0; // Mude este valor
```

### Mudar fonte padrão
Edite: `lib/domain/entities/settings_entity.dart`
```dart
final String fontFamily; // Mude o valor padrão
```

## 🐛 Troubleshooting

### App não compila
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Anúncios não aparecem
- Normal em ambiente de teste
- Verifique a conexão com internet
- Aguarde alguns minutos após iniciar o app

### Erro de Hive
```bash
# Deletar dados do Hive e recomeçar
flutter clean
# No emulador: Settings > Apps > ProScript > Clear Data
```

### Erro de build no iOS
```bash
cd ios
pod install
cd ..
flutter run
```

## 📱 Build para Produção

### Android (APK)
```bash
flutter build apk --release
# APK em: build/app/outputs/flutter-apk/app-release.apk
```

### Android (App Bundle - para Play Store)
```bash
flutter build appbundle --release
# AAB em: build/app/outputs/bundle/release/app-release.aab
```

### iOS (para App Store)
```bash
flutter build ios --release
# Depois abrir no Xcode para assinar e fazer upload
```

## ⚙️ Configuração para Produção

### Antes de publicar:

1. **Configurar AdMob IDs reais**
   - Ver: `ADMOB_SETUP.md`

2. **Mudar app name**
   - Android: `android/app/src/main/AndroidManifest.xml`
   - iOS: `ios/Runner/Info.plist`

3. **Configurar bundle ID**
   - Android: `android/app/build.gradle.kts` (applicationId)
   - iOS: Xcode > Runner > General > Bundle Identifier

4. **Adicionar ícones**
   - Use: [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)

5. **Criar Política de Privacidade**
   - Necessário para apps com anúncios!

## 🎯 Próximos Passos

- [ ] Testar todas as funcionalidades
- [ ] Configurar AdMob real
- [ ] Adicionar ícone personalizado
- [ ] Criar splash screen
- [ ] Escrever política de privacidade
- [ ] Testar em dispositivos reais
- [ ] Publicar na Play Store / App Store

## 💡 Dicas

1. **Use Hot Reload** durante desenvolvimento (tecla `r`)
2. **Teste em dispositivos reais** antes de publicar
3. **Monitore o console** para ver logs e erros
4. **Use Flutter DevTools** para debugging avançado

## 📚 Recursos Úteis

- [Flutter Docs](https://docs.flutter.dev)
- [BLoC Pattern](https://bloclibrary.dev)
- [AdMob Flutter](https://pub.dev/packages/google_mobile_ads)
- [Hive Database](https://docs.hivedb.dev)

---

## ✅ Checklist Rápido

- [x] Dependências instaladas
- [x] Build runner executado
- [x] Código sem erros
- [ ] App rodando no emulador
- [ ] Testado todas as telas
- [ ] Testado persistência
- [ ] Anúncios funcionando

## 🎉 Pronto!

Seu app ProScript está pronto para uso! 

Execute `flutter run` e comece a testar! 🚀

