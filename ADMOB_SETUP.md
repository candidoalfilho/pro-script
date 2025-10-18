# 📢 Configuração do AdMob para ProScript

Este guia ajudará você a configurar o Google AdMob no seu aplicativo ProScript.

## 1️⃣ Criar Conta no AdMob

1. Acesse [admob.google.com](https://admob.google.com)
2. Faça login com sua conta Google
3. Siga as instruções para criar uma conta AdMob

## 2️⃣ Criar um App no AdMob

1. No painel do AdMob, clique em **"Apps"** → **"Adicionar app"**
2. Escolha a plataforma (Android ou iOS)
3. Informe o nome do app: **ProScript**
4. Anote o **App ID** gerado (formato: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`)

## 3️⃣ Criar Unidades de Anúncio

### Banner Ad (para Home e Editor)

1. No app criado, vá em **"Unidades de anúncio"**
2. Clique em **"Adicionar unidade de anúncio"** → **"Banner"**
3. Configure:
   - Nome: `ProScript Banner`
   - Tamanho: Banner padrão (320x50)
4. Anote o **Unit ID** (formato: `ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ`)
5. Repita para iOS se necessário

### Interstitial Ad (para Teleprompter)

1. Clique em **"Adicionar unidade de anúncio"** → **"Intersticial"**
2. Configure:
   - Nome: `ProScript Interstitial`
3. Anote o **Unit ID**
4. Repita para iOS se necessário

## 4️⃣ Configurar no Código

### Passo 1: Atualizar IDs no Código

Abra `lib/core/constants/app_constants.dart` e substitua:

```dart
// Banner IDs
static const String androidBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ';
static const String iosBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ';

// Interstitial IDs
static const String androidInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ';
static const String iosInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ';
```

### Passo 2: Android - Adicionar App ID

Edite `android/app/src/main/AndroidManifest.xml` e adicione dentro de `<application>`:

```xml
<application>
    <!-- ... outros conteúdos ... -->
    
    <!-- AdMob App ID -->
    <meta-data
        android:name="com.google.android.gms.ads.APPLICATION_ID"
        android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
</application>
```

**⚠️ Substitua** `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY` pelo seu App ID real!

### Passo 3: iOS - Adicionar App ID

Edite `ios/Runner/Info.plist` e adicione:

```xml
<dict>
    <!-- ... outros conteúdos ... -->
    
    <!-- AdMob App ID -->
    <key>GADApplicationIdentifier</key>
    <string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
    
    <!-- Para iOS 14+ (App Tracking Transparency) -->
    <key>NSUserTrackingUsageDescription</key>
    <string>Este app usa identificadores para fornecer anúncios personalizados.</string>
</dict>
```

### Passo 4: iOS - Adicionar SKAdNetworkIdentifier

Ainda no `Info.plist`, adicione:

```xml
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <!-- Adicione outros identificadores conforme necessário -->
</array>
```

## 5️⃣ Testar os Anúncios

### Durante o Desenvolvimento

O app já está configurado com IDs de teste do Google. Você verá anúncios de teste com a marca "Test Ad".

### Para Produção

1. Substitua todos os IDs de teste pelos IDs reais
2. Faça build do app: `flutter build apk --release` (Android) ou `flutter build ios --release` (iOS)
3. Teste em um dispositivo físico
4. **⚠️ NUNCA** clique nos seus próprios anúncios em produção (pode resultar em banimento)

## 6️⃣ Verificar Implementação

Execute o app e verifique:

- ✅ Banner aparece na parte inferior da tela Home
- ✅ Banner aparece na parte inferior da tela Editor
- ✅ Interstitial aparece ao abrir o Teleprompter (após alguns segundos de delay)

## 7️⃣ Política de Privacidade

**⚠️ IMPORTANTE**: Apps com anúncios precisam de uma Política de Privacidade!

1. Crie uma página web com sua política de privacidade
2. Inclua informações sobre:
   - Coleta de dados para anúncios
   - Uso do Google AdMob
   - Cookies e identificadores
3. Adicione o link nas lojas de apps (Play Store / App Store)

### Template Básico

```
# Política de Privacidade do ProScript

## Anúncios

Este aplicativo exibe anúncios fornecidos pelo Google AdMob. O AdMob pode coletar e usar:
- Identificador de publicidade do dispositivo
- Endereço IP
- Informações sobre interações com anúncios

Para mais informações, consulte a Política de Privacidade do Google:
https://policies.google.com/privacy
```

## 8️⃣ Dicas e Melhores Práticas

### ✅ Fazer

- Teste com IDs de teste durante o desenvolvimento
- Use anúncios nativos para melhor UX
- Respeite a experiência do usuário (não exagere nos anúncios)
- Monitore o desempenho no painel do AdMob

### ❌ Não Fazer

- Nunca clique nos seus próprios anúncios
- Não incentive cliques em anúncios
- Não coloque muitos anúncios (pode irritar usuários)
- Não use IDs de teste em produção

## 🆘 Troubleshooting

### Anúncios não aparecem

1. Verifique se os IDs estão corretos
2. Confirme que o App ID está no manifest (Android) ou Info.plist (iOS)
3. Aguarde algumas horas após criar as unidades de anúncio
4. Verifique os logs: `flutter run --verbose`

### Erro: "The ad request was successful but no ad was returned"

- Normal durante testes
- Pode acontecer se não há anúncios disponíveis para sua região
- Aguarde algumas horas após configuração inicial

### iOS: Anúncios não carregam

- Verifique se o App ID está correto no Info.plist
- Confirme que adicionou o SKAdNetworkItems
- Em iOS 14+, pode precisar solicitar permissão de tracking

## 📊 Monetização

### Expectativas Realistas

- **eCPM** (custo por mil impressões): $0.50 - $5.00 (varia muito)
- Depende de: país, categoria do app, qualidade dos anúncios
- Interstitials geralmente pagam mais que banners
- Lembre-se: precisa de MUITOS usuários para ganhos significativos

### Estratégia Recomendada

1. Foque primeiro em crescer a base de usuários
2. Mantenha o app com boa performance
3. Considere oferecer versão Premium sem anúncios
4. Monitore métricas no AdMob Dashboard

## 📚 Recursos Adicionais

- [Documentação oficial do AdMob](https://developers.google.com/admob)
- [Plugin google_mobile_ads](https://pub.dev/packages/google_mobile_ads)
- [Centro de Ajuda do AdMob](https://support.google.com/admob)

---

✅ Após seguir todos os passos, seu app estará pronto para monetização com AdMob!

